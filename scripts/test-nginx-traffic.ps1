# Script PowerShell para generar tráfico HTTP hacia Nginx
# Uso: .\test-nginx-traffic.ps1 [-Requests 100] [-Concurrency 10]

param(
    [int]$Requests = 100,
    [int]$Concurrency = 10
)

$NginxUrl = "http://localhost:8080"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Generando tráfico HTTP hacia Nginx" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "URL: $NginxUrl"
Write-Host "Total peticiones: $Requests"
Write-Host "Concurrencia: $Concurrency"
Write-Host "======================================" -ForegroundColor Cyan

# Función para hacer peticiones concurrentes
function Send-ConcurrentRequests {
    param($Count, $Concurrent)

    $jobs = @()
    $completed = 0

    for ($i = 1; $i -le $Count; $i++) {
        $jobs += Start-Job -ScriptBlock {
            param($url)
            try {
                $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
                return $response.StatusCode
            } catch {
                return "Error: $($_.Exception.Message)"
            }
        } -ArgumentList $NginxUrl

        # Limitar concurrencia
        if ($jobs.Count -ge $Concurrent) {
            $jobs | Wait-Job -Any | Out-Null
            $completedJobs = $jobs | Where-Object { $_.State -eq 'Completed' }
            $completed += $completedJobs.Count
            $completedJobs | Remove-Job
            $jobs = @($jobs | Where-Object { $_.State -ne 'Completed' })

            if ($completed % 10 -eq 0) {
                Write-Host "Progreso: $completed/$Count peticiones completadas" -ForegroundColor Yellow
            }
        }
    }

    # Esperar a que terminen todos los jobs
    $jobs | Wait-Job | Out-Null
    $jobs | Remove-Job

    Write-Host "✓ $Count peticiones completadas" -ForegroundColor Green
}

# Generar peticiones exitosas
Write-Host "`nGenerando peticiones exitosas..." -ForegroundColor Yellow
Send-ConcurrentRequests -Count $Requests -Concurrent $Concurrency

# Generar algunos errores 404
Write-Host "`nGenerando algunos errores 404..." -ForegroundColor Yellow
for ($i = 1; $i -le 20; $i++) {
    Start-Job -ScriptBlock {
        param($url)
        try {
            Invoke-WebRequest -Uri "$url/error$((Get-Random))" -UseBasicParsing -ErrorAction Stop | Out-Null
        } catch {
            # Error esperado 404
        }
    } -ArgumentList $NginxUrl | Out-Null
}

Get-Job | Wait-Job | Out-Null
Get-Job | Remove-Job

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "✓ Tráfico generado exitosamente" -ForegroundColor Green
Write-Host "  Puedes verificar los logs en Kibana" -ForegroundColor Gray
Write-Host "======================================" -ForegroundColor Cyan
