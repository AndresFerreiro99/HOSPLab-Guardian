# ==========================================
# HOSPLab Guardian v1
# Herramienta de diagnostico del hospital
# ==========================================

# CONFIGURACION
$Servidor = "10.10.10.10"
$NombreServidor = "SRV-AD01.hosplab.local"
$IPCorrecta = "10.10.10.10"

Write-Host "====================================="
Write-Host "         HOSPLab Guardian v1"
Write-Host "====================================="
Write-Host ""

# ==========================================
# PRUEBA 1 - CONECTIVIDAD
# ==========================================

Write-Host "[1] Comprobando conexion con SRV-AD01..."

if (Test-Connection -ComputerName $Servidor -Count 2 -Quiet) {
    Write-Host "[OK] Servidor accesible" -ForegroundColor Green
}
else {
    Write-Host "[ERROR] No hay conexion con el servidor" -ForegroundColor Red
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
Write-Host "====================================="
Write-Host "       Diagnostico finalizado"
Write-Host "====================================="
