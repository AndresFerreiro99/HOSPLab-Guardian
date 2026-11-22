
# ==========================================
# HOSPLab Guardian v1.3
# Herramienta de diagnostico del hospital
# ==========================================

# CONFIGURACION DEL LABORATORIO
$Servidor = '10.10.10.10'
$NombreServidor = 'SRV-AD01.hosplab.local'
$NombreEquipo = 'SRV-AD01'
$RutaCompartida = '\\SRV-AD01\Hospital'
$Servicios = @('DNS', 'NTDS', 'Netlogon')

# GUARDAR INFORMES JUNTO AL SCRIPT
$DirectorioScript = Split-Path -Parent $MyInvocation.MyCommand.Path
$CarpetaInformes = Join-Path $DirectorioScript 'Informes'
$Resultados = New-Object System.Collections.Generic.List[object]

function Registrar-Resultado {
    param(
        [string]$Prueba,
        [ValidateSet('OK', 'ALERTA', 'ERROR', 'SIN PERMISOS')]
        [string]$Estado,
        [string]$Detalle
    )

    $Color = switch ($Estado) {
        'OK'           { 'Green' }
        'ALERTA'       { 'Yellow' }
        'SIN PERMISOS' { 'Yellow' }
        'ERROR'        { 'Red' }
    }

    Write-Host "[$Estado] $Detalle" -ForegroundColor $Color

    $Resultados.Add([pscustomobject]@{
        Prueba = $Prueba
        Estado = $Estado
        Detalle = $Detalle
    })
}

Write-Host '====================================='
Write-Host '        HOSPLab Guardian v1.3'
Write-Host '====================================='
Write-Host ''

# ==========================================
# PRUEBA 1 - CONECTIVIDAD
# ==========================================

Write-Host '[1] Comprobando conexion con SRV-AD01...'

try {
    if (Test-Connection -ComputerName $Servidor -Count 2 -Quiet -ErrorAction Stop) {
        Registrar-Resultado 'Conectividad' 'OK' "Servidor accesible ($Servidor)"
    }
    else {
        Registrar-Resultado 'Conectividad' 'ERROR' "El servidor no responde ($Servidor)"
    }
}
catch {
    Registrar-Resultado 'Conectividad' 'ERROR' "No se pudo comprobar la conexion: $($_.Exception.Message)"
}

Write-Host ''

# ==========================================
# PRUEBA 2 - RESOLUCION DNS
# ==========================================

Write-Host '[2] Comprobando DNS de SRV-AD01...'

try {
    $IPs = @(
        Resolve-DnsName -Name $NombreServidor -Type A -Server $Servidor -DnsOnly -ErrorAction Stop |
        Select-Object -ExpandProperty IPAddress
    )

    $IPs = @($IPs | Sort-Object -Unique)

    if ($IPs.Count -eq 1 -and $IPs[0] -eq $Servidor) {
        Registrar-Resultado 'DNS' 'OK' "DNS configurado correctamente: $Servidor"
    }
    else {
        Registrar-Resultado 'DNS' 'ALERTA' "Registros DNS inesperados: $($IPs -join ', ') (esperado: $Servidor)"
    }
}
catch {
    Registrar-Resultado 'DNS' 'ERROR' "No se pudo resolver $NombreServidor : $($_.Exception.Message)"
}

Write-Host ''

# ==========================================
# PRUEBA 3 - SERVICIOS REMOTOS DEL DOMINIO
# ==========================================

# Consulta los servicios del servidor remoto mediante sc.exe.
# Si el usuario no tiene permisos, no indica que el servicio este detenido.

Write-Host '[3] Comprobando servicios de SRV-AD01...'

foreach ($NombreServicio in $Servicios) {
    try {
        $Salida = @(& sc.exe "\\$NombreEquipo" query $NombreServicio 2>&1 | Out-String)
        $Texto = $Salida -join "`n"
        $CodigoSalida = $LASTEXITCODE

        if ($Texto -match '(?i)ACCESO DENEGADO|ACCESS IS DENIED|ERROR\s*5\b|0x80070005') {
            Registrar-Resultado "Servicio $NombreServicio" 'SIN PERMISOS' "Sin permisos para consultar $NombreServicio en $NombreEquipo"
        }
        elseif ($CodigoSalida -eq 0 -and $Texto -match '(?im)^\s*(STATE|ESTADO)\s*:\s*\d+\s+(RUNNING|EN EJECUCI[OÓ]N)\b') {
            Registrar-Resultado "Servicio $NombreServicio" 'OK' "$NombreServicio en ejecucion"
        }
        elseif ($CodigoSalida -eq 0 -and $Texto -match '(?im)^\s*(STATE|ESTADO)\s*:\s*\d+\s+(STOPPED|DETENIDO)\b') {
            Registrar-Resultado "Servicio $NombreServicio" 'ERROR' "$NombreServicio detenido"
        }
        elseif ($CodigoSalida -eq 0) {
            $EstadoDetectado = if ($Texto -match '(?im)^\s*(STATE|ESTADO)\s*:\s*(\d+\s+\S+)') {
                $Matches[2]
            }
            else {
                'desconocido'
            }

            Registrar-Resultado "Servicio $NombreServicio" 'ALERTA' "Estado de $NombreServicio : $EstadoDetectado"
        }
        else {
            $ResumenError = ($Texto.Trim() -replace '\s+', ' ')

            Registrar-Resultado "Servicio $NombreServicio" 'ALERTA' "No se pudo consultar $NombreServicio (codigo $CodigoSalida): $ResumenError"
        }
    }
    catch {
        Registrar-Resultado "Servicio $NombreServicio" 'ALERTA' "No se pudo consultar $NombreServicio : $($_.Exception.Message)"
    }
}

Write-Host ''

# ==========================================
# PRUEBA 4 - RECURSO COMPARTIDO SMB
# ==========================================

Write-Host '[4] Comprobando recursos compartidos...'

try {
    $PuertoSMB = Test-NetConnection -ComputerName $Servidor -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue

    if ($PuertoSMB) {
        Registrar-Resultado 'Puerto SMB 445' 'OK' 'Puerto SMB 445 accesible'

        try {
            if (Test-Path -LiteralPath $RutaCompartida -ErrorAction Stop) {
                Registrar-Resultado 'Recurso Hospital' 'OK' 'Recurso compartido Hospital accesible'
            }
            else {
                Registrar-Resultado 'Recurso Hospital' 'ALERTA' "No se puede acceder a $RutaCompartida (revisar existencia y permisos)"
            }
        }
        catch {
            Registrar-Resultado 'Recurso Hospital' 'ALERTA' "No se pudo comprobar $RutaCompartida : $($_.Exception.Message)"
        }
    }
    else {
        Registrar-Resultado 'Puerto SMB 445' 'ERROR' 'Puerto SMB 445 inaccesible'
        Registrar-Resultado 'Recurso Hospital' 'ALERTA' 'Recurso no comprobado porque el puerto SMB no responde'
    }
}
catch {
    Registrar-Resultado 'Puerto SMB 445' 'ERROR' "No se pudo comprobar SMB: $($_.Exception.Message)"
}

Write-Host ''

# ==========================================
# PRUEBA 5 - INFORME AUTOMATICO
# ==========================================

Write-Host '[5] Generando informe del diagnostico...'

$Correctos = @($Resultados | Where-Object { $_.Estado -eq 'OK' }).Count
$Alertas = @($Resultados | Where-Object { $_.Estado -in @('ALERTA', 'SIN PERMISOS') }).Count
$Errores = @($Resultados | Where-Object { $_.Estado -eq 'ERROR' }).Count

try {
    if (-not (Test-Path -LiteralPath $CarpetaInformes)) {
        New-Item -ItemType Directory -Path $CarpetaInformes -Force -ErrorAction Stop | Out-Null
    }

    $Fecha = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $RutaInforme = Join-Path $CarpetaInformes "Guardian_$Fecha.txt"

    $Lineas = @(
        'HOSPLab Guardian v1.3 - Informe de diagnostico'
        "Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
        "Equipo que ejecuta: $env:COMPUTERNAME"
        "Usuario: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        "Servidor analizado: $NombreEquipo ($Servidor)"
        "Recurso compartido: $RutaCompartida"
        '------------------------------------------'
    )

    foreach ($Resultado in $Resultados) {
        $Lineas += "[$($Resultado.Estado)] $($Resultado.Prueba): $($Resultado.Detalle)"
    }

    $Lineas += '------------------------------------------'
    $Lineas += "Correctos: $Correctos | Alertas (incluye sin permisos): $Alertas | Errores: $Errores"

    $Lineas | Out-File -LiteralPath $RutaInforme -Encoding UTF8 -ErrorAction Stop

    Write-Host '[OK] Informe generado correctamente' -ForegroundColor Green
    Write-Host "Ruta: $RutaInforme"
}
catch {
    Write-Host "[ERROR] No se ha podido guardar el informe: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ''
Write-Host '====================================='
Write-Host '       Diagnostico finalizado'
Write-Host '====================================='
Write-Host "Correctos: $Correctos | Alertas: $Alertas | Errores: $Errores"
