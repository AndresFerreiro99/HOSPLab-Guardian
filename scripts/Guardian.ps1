
# ==========================================
# HOSPLab Guardian v1.1
# Herramienta de diagnostico del hospital
# ==========================================

# CONFIGURACION
$Servidor = "10.10.10.10"
$NombreServidor = "SRV-AD01.hosplab.local"
$IPCorrecta = "10.10.10.10"

Write-Host "====================================="
Write-Host "        HOSPLab Guardian v1.1"
Write-Host "====================================="
Write-Host ""

# ==========================================
# PRUEBA 1 - CONECTIVIDAD
# ==========================================

Write-Host "[1] Comprobando conexion con SRV-AD01..."

try {
    if (Test-Connection -ComputerName $Servidor -Count 2 -Quiet -ErrorAction Stop) {
        Write-Host "[OK] Servidor accesible" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] No hay conexion con el servidor" -ForegroundColor Red
    }
}
catch {
    Write-Host "[ERROR] No se ha podido comprobar la conectividad" -ForegroundColor Red
}

Write-Host ""

# ==========================================
# PRUEBA 2 - RESOLUCION DNS
# ==========================================

Write-Host "[2] Comprobando DNS de SRV-AD01..."

try {
    $IPs = @(
        Resolve-DnsName -Name $NombreServidor -Type A -Server $Servidor -DnsOnly -ErrorAction Stop |
        Select-Object -ExpandProperty IPAddress
    )

    if ($IPs.Count -eq 1 -and $IPs[0] -eq $IPCorrecta) {
        Write-Host "[OK] DNS configurado correctamente" -ForegroundColor Green
    }
    else {
        Write-Host "[ALERTA] Se han detectado registros DNS incorrectos:" -ForegroundColor Yellow

        foreach ($IP in $IPs) {
            Write-Host " - $IP"
        }
    }
}
catch {
    Write-Host "[ERROR] No se ha podido resolver el nombre del servidor" -ForegroundColor Red
}

Write-Host ""

# ==========================================
# PRUEBA 3 - SERVICIOS DEL DOMINIO
# ==========================================

Write-Host "[3] Comprobando servicios de SRV-AD01..."

$Servicios = @("DNS", "NTDS", "Netlogon")

foreach ($NombreServicio in $Servicios) {
    try {
        $Servicio = Get-Service -ComputerName "SRV-AD01" -Name $NombreServicio -ErrorAction Stop

        if ($Servicio.Status -eq "Running") {
            Write-Host "[OK] $NombreServicio en ejecucion" -ForegroundColor Green
        }
        else {
            Write-Host "[ALERTA] $NombreServicio no esta en ejecucion (Estado: $($Servicio.Status))" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] No se puede consultar $NombreServicio" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "====================================="
Write-Host "       Diagnostico finalizado"
Write-Host "====================================="
