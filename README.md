# 🔍 Entorno de Práctica ELK Stack Completo con Docker

Este repositorio contiene un **entorno de laboratorio completo** del **ELK Stack** (Elasticsearch, Kibana) dockerizado con **Elastic Beats** para monitoreo integral del sistema.

## 📋 Descripción

Es un entorno de práctica configurado con:
- **Elasticsearch 9.2.1** - Motor de búsqueda y análisis
- **Kibana 9.2.1** - Visualización de datos
- **Nginx** - Servidor web con endpoint de métricas
- **Filebeat 9.2.1** - Recolector de logs
- **Metricbeat 9.2.1** - Monitoreo de métricas del sistema
- **Packetbeat 9.2.1** - Análisis de tráfico de red
- **Auditbeat 9.2.1** - Auditoría del sistema
- **Heartbeat 9.2.1** - Monitoreo de disponibilidad
- **SSL/TLS** - Comunicación encriptada entre servicios
- **Docker Compose** - Orquestación de contenedores

Todos los servicios están en una **red Docker privada** y utilizan certificados autofirmados para seguridad.

## 🚀 Inicio Rápido

### Requisitos Previos
- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS (también funciona en Windows con WSL2)
- Mínimo 4GB de RAM disponible
- Al menos 10GB de espacio en disco

### 1. Clonar el Repositorio

```bash
git clone <repo-url>
cd ELK
```

### 2. Configurar Variables de Entorno

Edita el archivo `.env` con tus valores:

```bash
nano .env
```

**Variables importantes a modificar:**

```bash
# ⚠️ CAMBIA ESTAS CONTRASEÑAS EN PRODUCCIÓN
ELASTIC_PASSWORD=admin.2025!           # Contraseña usuario 'elastic'
KIBANA_PASSWORD=admin.2025!            # Contraseña usuario 'kibana_system'

# Versión del Stack
STACK_VERSION=9.2.1

# Puertos (cambia si hay conflictos)
ES_PORT=9200                           # Puerto Elasticsearch
KIBANA_PORT=5601                       # Puerto Kibana

# Memoria (ajusta según tu máquina)
MEM_LIMIT=2g                           # Máximo de RAM para servicios

# Claves de encriptación (IMPORTANTE para alertas en Kibana)
ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=changeitchangeitchangeitchangeit
SECURITY_ENCRYPTIONKEY=changeitchangeitchangeitchangeit
REPORTING_ENCRYPTIONKEY=changeitchangeitchangeitchangeit
```

### 3. Levantar el Entorno

```bash
docker compose up -d
```

Espera 2-3 minutos a que todo se inicie. El proceso incluye:
1. Generación de certificados SSL/TLS (30 segundos)
2. Inicio de Elasticsearch (1-2 minutos)
3. Configuración de contraseñas
4. Inicio de Kibana (1-2 minutos)
5. Inicio de todos los Beats

**Verifica el estado:**

```bash
docker compose ps
```

**Deberías ver todos los servicios "Up" o "Up (healthy)"**

### 4. Acceder a Kibana

- URL: `https://localhost:5601`
- Usuario: `elastic`
- Contraseña: (la del `.env` - por defecto: `admin.2025!`)

**⚠️ Nota:** Aceptar certificado autofirmado (normal en desarrollo)

### 5. Explorar los Dashboards

Una vez en Kibana:

1. Ve a **Menu → Analytics → Dashboards**
2. Busca los dashboards precargados:
   - **[Filebeat Nginx] Overview** - Logs de Nginx
   - **[Metricbeat System] Overview** - Métricas del sistema
   - **[Metricbeat Docker] Overview** - Métricas de contenedores
   - **[Packetbeat] Overview** - Tráfico de red
   - **[Auditbeat System] Overview** - Auditoría del sistema

## 📂 Estructura del Proyecto

```
ELK/
├── docker-compose.yml          # Orquestación de servicios
├── .env                         # Variables de entorno (EDITAR ESTO)
├── README.md                    # Este archivo
├── nginx/
│   ├── Dockerfile              # Imagen personalizada de Nginx
│   └── nginx.conf              # Configuración de Nginx
├── filebeat/
│   └── filebeat.yml            # Configuración de Filebeat
├── metricbeat/
│   └── metricbeat.yml          # Configuración de Metricbeat
├── packetbeat/
│   └── packetbeat.yml          # Configuración de Packetbeat
├── auditbeat/
│   └── auditbeat.yml           # Configuración de Auditbeat
├── heartbeat/
│   └── heartbeat.yml           # Configuración de Heartbeat
└── certs/                       # Certificados autofirmados (auto-generados)
    ├── ca/
    ├── es01/
    └── kibana/
```

## 🔧 Servicios Incluidos

### Elasticsearch (es01)
- **Puerto:** 9200 (HTTPS)
- **Modo:** Nodo único
- **Almacenamiento:** Volumen `esdata01`
- **Seguridad:** SSL/TLS + autenticación
- **Función:** Motor de búsqueda y almacenamiento de datos

### Kibana
- **Puerto:** 5601 (HTTPS)
- **Conexión:** Elasticsearch en `https://es01:9200`
- **Almacenamiento:** Volumen `kibanadata`
- **Claves de encriptación:** Para alertas y reglas
- **Función:** Visualización y análisis de datos

### Nginx (nginx-app)
- **Puerto:** 8080 (HTTP)
- **Logs:** `/var/log/nginx/access.log` y `error.log`
- **Métricas:** Endpoint `/nginx-status` (puerto 8080)
- **Almacenamiento:** Volumen `nginx-data`
- **Función:** Servidor web de ejemplo para generar logs y métricas

### Filebeat (filebeat01)
- **Función:** Recolecta logs de Nginx y contenedores Docker
- **Módulos:** nginx (access, error)
- **Destino:** Elasticsearch en `https://es01:9200`
- **Descubrimiento:** Docker autodiscover activado
- **Almacenamiento:** Volumen `filebeatdata01`
- **Dashboards:** Automáticamente cargados en Kibana

### Metricbeat (metricbeat01)
- **Función:** Monitorea métricas del sistema y servicios
- **Módulos activos:**
  - **elasticsearch** - Métricas del cluster ES
  - **kibana** - Métricas de Kibana
  - **docker** - Métricas de contenedores
  - **nginx** - Métricas del servidor web (stub_status)
- **Destino:** Elasticsearch en `https://es01:9200`
- **Almacenamiento:** Volumen `metricbeatdata01`
- **Frecuencia:** Cada 10 segundos
- **Dashboards:** Automáticamente cargados en Kibana

### Packetbeat (packetbeat01)
- **Función:** Captura y analiza tráfico de red
- **Protocolos monitoreados:**
  - **HTTP** (puertos 80, 8080, 8000, 5000, 8002)
  - **TLS** (puertos 443, 993, 995, 5601, 9200)
  - **DNS** (puerto 53)
  - **ICMP** (ping)
  - **DHCP** (puertos 67, 68)
  - **MySQL** (puertos 3306, 3307)
  - **Redis** (puerto 6379)
  - **PostgreSQL** (puerto 5432)
  - **MongoDB** (puerto 27017)
- **Modo de red:** Host (para capturar tráfico del sistema)
- **Destino:** Elasticsearch en `https://localhost:9200`
- **Almacenamiento:** Volumen `packetbeatdata01`
- **Dashboards:** Automáticamente cargados en Kibana

### Auditbeat (auditbeat01)
- **Función:** Auditoría de cambios en archivos y sistema
- **Módulos activos:**
  - **file_integrity** - Monitorea cambios en `/var/log/nginx`
  - **system** - Información de paquetes y host
- **Destino:** Elasticsearch en `https://es01:9200`
- **Almacenamiento:** Volumen `auditbeatdata01`
- **Frecuencia:** Cada 1 minuto
- **Dashboards:** Automáticamente cargados en Kibana

### Heartbeat (heartbeat01)
- **Función:** Monitorea disponibilidad de servicios
- **Monitores configurados:**
  - **HTTP** - Nginx en `http://nginx-app:80` (cada 10s)
  - **ICMP** - Nginx (ping cada 10s)
- **Destino:** Elasticsearch en `https://es01:9200`
- **Almacenamiento:** Volumen `heartbeatdata01`
- **Alertas:** Configurable en Kibana

### Setup
- **Función:** Genera certificados SSL/TLS
- **Ejecución:** Una sola vez al iniciar
- **Certificados:** CA + certificados para es01 y kibana
- **Tareas:**
  1. Crea CA (Certificate Authority)
  2. Genera certificados para Elasticsearch
  3. Genera certificados para Kibana
  4. Configura permisos
  5. Espera disponibilidad de Elasticsearch
  6. Configura contraseña de kibana_system

## 🌐 Red Docker

Casi todos los servicios están conectados a la red `elastic_network` (bridge):
- `setup` ↔ `es01` ↔ `kibana` ↔ `filebeat01` ↔ `metricbeat01` ↔ `auditbeat01` ↔ `heartbeat01` ↔ `nginx-app`
- Resolución de nombres automática
- **Excepción:** Packetbeat usa `network_mode: host` para capturar tráfico del sistema

## 📝 Configuración de Variables

### `.env` - Variables Críticas

| Variable | Valor Actual | Descripción |
|----------|-------------|-------------|
| `ELASTIC_PASSWORD` | `admin.2025!` | Contraseña de usuario `elastic` |
| `KIBANA_PASSWORD` | `admin.2025!` | Contraseña de usuario `kibana_system` |
| `STACK_VERSION` | `9.2.1` | Versión de Elasticsearch/Kibana/Beats |
| `ES_PORT` | `9200` | Puerto expuesto de Elasticsearch |
| `KIBANA_PORT` | `5601` | Puerto expuesto de Kibana |
| `MEM_LIMIT` | `2g` | Máximo de memoria RAM por servicio |
| `LICENSE` | `basic` | Tipo de licencia (basic/trial) |
| `ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY` | `changeit...` | Clave para guardar objetos encriptados |
| `SECURITY_ENCRYPTIONKEY` | `changeit...` | Clave para seguridad |
| `REPORTING_ENCRYPTIONKEY` | `changeit...` | Clave para reportes |

**⚠️ IMPORTANTE:** Cambia todas las contraseñas antes de desplegar en producción.

## 📊 Monitoreo y Logs

### Ver estado de los contenedores

```bash
docker compose ps
```

### Ver logs en tiempo real

```bash
# Todos los servicios
docker compose logs -f

# Servicio específico
docker compose logs -f kibana
docker compose logs -f filebeat01
docker compose logs -f metricbeat01
docker compose logs -f packetbeat01
docker compose logs -f auditbeat01
docker compose logs -f heartbeat01
docker compose logs -f es01
```

### Ver logs internos de los Beats

```bash
# Filebeat
docker exec elk-filebeat01-1 tail -100 /var/log/filebeat/filebeat-*.ndjson

# Metricbeat
docker exec elk-metricbeat01-1 tail -100 /var/log/metricbeat/metricbeat-*.ndjson

# Packetbeat
docker logs elk-packetbeat01-1 --tail 50

# Auditbeat
docker logs elk-auditbeat01-1 --tail 50

# Heartbeat
docker logs elk-heartbeat01-1 --tail 50
```

## 🔍 Verificar que Funciona

### 1. Elasticsearch está corriendo

```bash
curl -u elastic:admin.2025! https://localhost:9200 -k
```

Deberías ver: `"cluster_name" : "docker-cluster"`

### 2. Kibana está accesible

```bash
curl -s -k https://localhost:5601/api/status | grep available
```

Deberías ver: `"level":"available"`

### 3. Verificar índices de Beats

```bash
curl -u elastic:admin.2025! https://localhost:9200/_cat/indices -k | grep beat
```

Deberías ver índices:
- `.ds-filebeat-9.2.1-*`
- `.ds-metricbeat-9.2.1-*`
- `.ds-packetbeat-9.2.1-*`
- `.ds-auditbeat-9.2.1-*`
- `.ds-heartbeat-9.2.1-*`

### 4. Nginx está corriendo

```bash
# Página principal
curl http://localhost:8080

# Endpoint de métricas
curl http://localhost:8080/nginx-status
```

### 5. Generar tráfico de prueba

```bash
# Genera algunos logs en Nginx
for i in {1..10}; do curl http://localhost:8080; done

# Genera tráfico ICMP
ping -c 10 localhost

# Genera tráfico DNS
nslookup google.com
```

Espera 10-20 segundos y verifica en Kibana los dashboards.

## 📈 Casos de Uso

### 1. Monitoreo de Logs
- **Herramienta:** Filebeat
- **Dashboard:** [Filebeat Nginx] Overview
- **Casos:**
  - Analizar patrones de acceso HTTP
  - Detectar errores 4xx/5xx
  - Identificar IPs sospechosas
  - Analizar tiempos de respuesta

### 2. Monitoreo de Infraestructura
- **Herramienta:** Metricbeat
- **Dashboards:**
  - [Metricbeat System] Overview - CPU, memoria, disco
  - [Metricbeat Docker] Overview - Contenedores
  - [Metricbeat Elasticsearch] Overview - Cluster health
- **Casos:**
  - Detectar picos de CPU/memoria
  - Monitorear espacio en disco
  - Alertas de contenedores caídos
  - Performance del cluster ES

### 3. Análisis de Tráfico de Red
- **Herramienta:** Packetbeat
- **Dashboard:** [Packetbeat] Overview
- **Casos:**
  - Analizar flujos de red
  - Detectar protocolos no autorizados
  - Identificar comunicaciones anómalas
  - Monitorear latencias de red

### 4. Auditoría de Seguridad
- **Herramienta:** Auditbeat
- **Dashboard:** [Auditbeat System] Overview
- **Casos:**
  - Detectar cambios en archivos críticos
  - Auditar instalación/desinstalación de paquetes
  - Monitorear modificaciones de configuración
  - Compliance y seguridad

### 5. Monitoreo de Disponibilidad
- **Herramienta:** Heartbeat
- **Uptime App:** Menu → Observability → Uptime
- **Casos:**
  - Monitorear disponibilidad de servicios
  - Alertas de downtime
  - SLA monitoring
  - Latencias de respuesta

## ⏸️ Parar el Entorno

Detiene contenedores pero **conserva todos los datos** (volúmenes):

```bash
docker compose down
```

## ▶️ Reiniciar el Entorno

Reinicia con:

```bash
docker compose up -d
```

## 🗑️ Limpiar TODO (⚠️ Borra datos)

Elimina contenedores Y volúmenes (datos):

```bash
docker compose down -v
```

## 🐛 Troubleshooting

### "Beats no resuelven es01 o kibana"
- ✅ Asegúrate de que todos los servicios tienen `networks: - elastic_network`
- ✅ Verifica que el servicio `setup` completó exitosamente: `docker logs elk-setup-1`
- ✅ Reinicia el stack: `docker compose restart`

### "Kibana no inicia o tarda mucho"
- ✅ Espera al menos 2-3 minutos, Kibana tarda en inicializar
- ✅ Ver logs: `docker compose logs kibana | tail -50`
- ✅ Verifica que Elasticsearch está healthy: `docker compose ps es01`
- ✅ Verifica que setup completó: `docker logs elk-setup-1 --tail 5`

### "Puerto 9200/5601 ya está en uso"
- ✅ Cambia los puertos en `.env`: `ES_PORT=9201`, `KIBANA_PORT=5602`
- ✅ Luego: `docker compose down && docker compose up -d`

### "No hay datos en Kibana"
- ✅ Verifica que los Beats se conectaron: `docker compose logs filebeat01 | grep -i error`
- ✅ Genera tráfico: `for i in {1..20}; do curl http://localhost:8080; done`
- ✅ Espera 30 segundos y refresca Kibana
- ✅ Verifica índices: `curl -u elastic:admin.2025! https://localhost:9200/_cat/indices -k | grep beat`

### "Packetbeat se cae constantemente"
- ✅ Packetbeat necesita `network_mode: host` para funcionar
- ✅ En Windows/Mac con Docker Desktop, puede tener limitaciones
- ✅ Verifica logs: `docker logs elk-packetbeat01-1 --tail 20`
- ✅ Si no es crítico, puedes comentar el servicio en docker-compose.yml

### "Setup container failed"
- ✅ Ver logs: `docker logs elk-setup-1`
- ✅ Verifica que las variables `.env` están correctamente configuradas
- ✅ Elimina volumen de certificados y reinicia: `docker volume rm elk_certs && docker compose up -d`

### "Out of memory errors"
- ✅ Aumenta `MEM_LIMIT` en `.env` (por ejemplo, `MEM_LIMIT=4g`)
- ✅ Cierra servicios no esenciales en tu máquina
- ✅ Considera deshabilitar algunos Beats si no son necesarios

### "Certificados SSL no válidos"
- ✅ Los certificados son autofirmados, es normal
- ✅ Usa `-k` con curl: `curl -k https://localhost:9200`
- ✅ En el navegador, acepta el riesgo y continúa

## 📚 Recursos Útiles

### Documentación Oficial
- [Elasticsearch Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Beats Platform Reference](https://www.elastic.co/guide/en/beats/libbeat/current/index.html)
- [Filebeat Reference](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Metricbeat Reference](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html)
- [Packetbeat Reference](https://www.elastic.co/guide/en/beats/packetbeat/current/index.html)
- [Auditbeat Reference](https://www.elastic.co/guide/en/beats/auditbeat/current/index.html)
- [Heartbeat Reference](https://www.elastic.co/guide/en/beats/heartbeat/current/index.html)

### Tutoriales y Guías
- [Getting Started with ELK](https://www.elastic.co/what-is/elk-stack)
- [Docker and the Elastic Stack](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html)
- [Security Best Practices](https://www.elastic.co/guide/en/elasticsearch/reference/current/secure-cluster.html)

## 📝 Notas Importantes

- **SSL/TLS:** Los certificados son autofirmados. En producción, usa certificados válidos de una CA.
- **Contraseñas:** No uses `admin.2025!` en producción. Genera contraseñas fuertes y únicas.
- **Memoria:** Ajusta `MEM_LIMIT` según los recursos de tu máquina. Mínimo recomendado: 4GB RAM.
- **Persistencia:** Los volúmenes Docker persisten datos aunque pares los contenedores.
- **Licencia:** Este entorno usa la licencia Basic (gratuita) de Elastic. Para features empresariales, considera la licencia Trial o Enterprise.
- **Rendimiento:** En entornos de producción, considera un cluster multi-nodo para alta disponibilidad.

## 🔒 Seguridad

### Certificados SSL/TLS
- Generados automáticamente por el contenedor `setup`
- Incluye CA propia y certificados para cada servicio
- Válidos para desarrollo y pruebas
- **Producción:** Reemplazar con certificados de CA confiable

### Autenticación
- Usuario principal: `elastic` (superuser)
- Usuario de sistema: `kibana_system` (solo para Kibana)
- Todos los Beats usan el usuario `elastic` para conectarse

### Comunicaciones
- **Elasticsearch ↔ Kibana:** HTTPS con certificado SSL
- **Beats ↔ Elasticsearch:** HTTPS con certificado SSL
- **Nginx ↔ Usuario:** HTTP (solo puerto 8080 local)

### Mejoras Recomendadas para Producción
1. Habilitar audit logging en Elasticsearch
2. Configurar roles y usuarios específicos para cada Beat
3. Implementar firewall rules
4. Rotar contraseñas regularmente
5. Habilitar 2FA para acceso a Kibana
6. Configurar IP whitelisting

## ✅ Checklist para Producción

- [ ] Cambiar todas las contraseñas en `.env`
- [ ] Usar certificados válidos (no autofirmados)
- [ ] Ajustar `MEM_LIMIT` según servidor (mínimo 4GB)
- [ ] Configurar backups automáticos de volúmenes
- [ ] Implementar cluster multi-nodo para HA
- [ ] Habilitar autenticación HTTPS en Nginx
- [ ] Configurar políticas de retención de índices (ILM)
- [ ] Configurar alertas en Kibana
- [ ] Implementar monitoring con Elastic Agent
- [ ] Configurar firewall y seguridad de red
- [ ] Documentar procedimientos de disaster recovery
- [ ] Establecer SLAs y objetivos de monitoreo

## 🎯 Próximos Pasos

1. **Explorar Kibana:** Familiarízate con los dashboards precargados
2. **Crear Visualizaciones:** Crea tus propias visualizaciones personalizadas
3. **Configurar Alertas:** Define alertas para eventos críticos
4. **Integrar Aplicaciones:** Conecta tus propias aplicaciones a Elasticsearch
5. **Optimizar Índices:** Configura ILM policies para gestión de datos
6. **Añadir Más Beats:** Explora Winlogbeat, Functionbeat, etc.

## 📞 Soporte

Para issues, preguntas o contribuciones:
- Abre un issue en el repositorio
- Consulta la documentación oficial de Elastic
- Únete a la comunidad de Elastic en Discuss

---

**Creado:** Diciembre 2025
**Stack:** Elasticsearch 9.2.1 + Kibana 9.2.1 + 5 Beats
**Entorno:** Docker Compose v2.0+
**Arquitectura:** Single-node con observabilidad completa
