# Scripts de Prueba para ELK Stack

Esta carpeta contiene scripts para generar tráfico de prueba hacia el stack ELK.

## Scripts Disponibles

### 1. test-nginx-traffic.sh (Linux/Mac)
Script Bash para generar tráfico HTTP hacia Nginx.

**Uso:**
```bash
chmod +x test-nginx-traffic.sh
./test-nginx-traffic.sh [numero_peticiones] [concurrencia]
```

**Ejemplos:**
```bash
# 100 peticiones con 10 concurrentes (por defecto)
./test-nginx-traffic.sh

# 500 peticiones con 20 concurrentes
./test-nginx-traffic.sh 500 20

# 1000 peticiones con 50 concurrentes
./test-nginx-traffic.sh 1000 50
```

**Requisitos:**
- `curl` (siempre disponible)
- `ab` (Apache Benchmark) - opcional pero recomendado
- `hey` - opcional

### 2. test-nginx-traffic.ps1 (Windows)
Script PowerShell para generar tráfico HTTP hacia Nginx.

**Uso:**
```powershell
.\test-nginx-traffic.ps1 [-Requests 100] [-Concurrency 10]
```

**Ejemplos:**
```powershell
# 100 peticiones con 10 concurrentes (por defecto)
.\test-nginx-traffic.ps1

# 500 peticiones con 20 concurrentes
.\test-nginx-traffic.ps1 -Requests 500 -Concurrency 20

# 1000 peticiones con 50 concurrentes
.\test-nginx-traffic.ps1 -Requests 1000 -Concurrency 50
```

## Instalación de Herramientas Recomendadas

### Apache Benchmark (ab)

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install apache2-utils
```

**Linux (RHEL/CentOS):**
```bash
sudo yum install httpd-tools
```

**macOS:**
```bash
brew install httpd
```

**Windows:**
Descarga Apache y añade la ruta de `ab.exe` al PATH.

### hey

**Linux/macOS:**
```bash
go install github.com/rakyll/hey@latest
```

**Windows:**
Descarga desde https://github.com/rakyll/hey/releases

## Verificación de Resultados

Después de ejecutar los scripts, puedes verificar los resultados en Kibana:

1. **Logs en Filebeat:**
   - Ve a `Analytics` → `Discover`
   - Selecciona el data view `filebeat-*`
   - Filtra por `event.module: nginx`

2. **Métricas en Metricbeat:**
   - Ve a `Analytics` → `Dashboards`
   - Busca "Nginx" y selecciona el dashboard de Metricbeat

3. **Tráfico en Packetbeat:**
   - Ve a `Analytics` → `Dashboards`
   - Busca "Packetbeat" para ver el análisis de tráfico de red

## Notas

- Los scripts generan tanto peticiones exitosas (200 OK) como errores (404 Not Found) para tener variedad en los logs
- Asegúrate de que Nginx esté ejecutándose en `http://localhost:8080`
- Para generar más tráfico, ejecuta los scripts múltiples veces o aumenta los parámetros
