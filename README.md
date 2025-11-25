# 🔍 Entorno de Práctica ELK Stack con Docker

Este repositorio contiene un **entorno de laboratorio completo** del **ELK Stack** (Elasticsearch, Logstash, Kibana) dockerizado con **Filebeat** para recopilar logs de Nginx.

## 📋 Descripción

Es un entorno de práctica configurado con:
- **Elasticsearch 9.2.1** - Motor de búsqueda y análisis
- **Kibana 9.2.1** - Visualización de datos
- **Nginx** - Servidor web con endpoint de métricas
- **Filebeat 9.2.1** - Recolector de logs
- **SSL/TLS** - Comunicación encriptada entre servicios
- **Docker Compose** - Orquestación de contenedores

Todos los servicios están en una **red Docker privada** y utilizan certificados autofirmados para seguridad.

## 🚀 Inicio Rápido

### Requisitos Previos
- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux/macOS (también funciona en Windows con WSL2)

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

### 3. Levantaral Entorno

```bash
docker compose up -d
```

Espera 1-2 minutos a que todo se inicie:

```bash
docker compose ps
```

**Verifica que todos muestren "Up" o "Up (healthy)"**

### 4. Acceder a Kibana

- URL: `https://localhost:5601`
- Usuario: `elastic`
- Contraseña: (la del `.env`)

**⚠️ Nota:** Aceptar certificado autofirmado (no es de confianza en desarrollo)

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

### Kibana
- **Puerto:** 5601 (HTTPS)
- **Conexión:** Elasticsearch en `https://es01:9200`
- **Almacenamiento:** Volumen `kibanadata`
- **Claves de encriptación:** Para alertas y reglas

### Nginx (nginx-app)
- **Puerto:** 8080 (HTTP)
- **Logs:** `/var/log/nginx/access.log` y `error.log`
- **Métricas:** Endpoint `/nginx-status` (puerto 8080)
- **Almacenamiento:** Volumen `nginx-data`

### Filebeat (filebeat01)
- **Función:** Recolecta logs de Nginx
- **Módulos:** nginx (access, error)
- **Destino:** Elasticsearch en `https://es01:9200`
- **Descubrimiento:** Docker autodiscover activado
- **Almacenamiento:** Volumen `filebeatdata01`

### Setup
- **Función:** Genera certificados SSL/TLS
- **Ejecución:** Una sola vez al iniciar
- **Certificados:** CA + certificados para es01 y kibana

## 🌐 Red Docker

Todos los servicios están conectados a la red `elastic_network` (bridge):
- `es01` ↔ `kibana` ↔ `filebeat01` ↔ `nginx-app`
- Resolución de nombres automática

## 📝 Configuración de Variables

### `.env` - Variables Críticas

| Variable | Valor Actual | Descripción |
|----------|-------------|-------------|
| `ELASTIC_PASSWORD` | `admin.2025!` | Contraseña de usuario `elastic` |
| `KIBANA_PASSWORD` | `admin.2025!` | Contraseña de usuario `kibana_system` |
| `STACK_VERSION` | `9.2.1` | Versión de Elasticsearch/Kibana |
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
docker compose logs -f es01
```

### Ver logs de Filebeat internos

```bash
docker exec elk-filebeat01-1 tail -100 /var/log/filebeat/filebeat-*.ndjson
```

## 🔍 Verificar que Funciona

### 1. Elasticsearch está corriendo

```bash
curl -u elastic:admin.2025! https://localhost:9200 -k
```

Deberías ver: `"cluster_name" : "docker-cluster"`

### 2. Kibana está accesible

```bash
curl -s https://localhost:5601 -k | grep -i kibana
```

### 3. Filebeat está enviando datos

```bash
curl -u elastic:admin.2025! https://localhost:9200/_cat/indices -k | grep filebeat
```

Deberías ver un índice tipo `.ds-filebeat-9.2.1-*`

### 4. Nginx está corriendo

```bash
curl http://localhost:8080
curl http://localhost:8080/nginx-status
```

## ⏸️ Parar el Entorno

Detiene contenedores pero **conserva todos los datos** (volúmenes):

```bash
docker compose down
```

## ▶️ Reiniciar el Entorno

Mañana (o cuando quieras), reinicia con:

```bash
docker compose up -d
```

## 🗑️ Limpiar TODO (⚠️ Borra datos)

Elimina contenedores Y volúmenes (datos):

```bash
docker compose down -v
```

## 🐛 Troubleshooting

### "Filebeat no resuelve es01"
- ✅ Asegúrate de que `es01` tiene `networks: - elastic_network`
- ✅ Reinicia Filebeat: `docker compose restart filebeat01`

### "Kibana no inicia"
- ✅ Espera 60 segundos, tarda en inicializar
- ✅ Ver logs: `docker compose logs kibana`

### "Puerto 9200/5601 ya está en uso"
- ✅ Cambia los puertos en `.env`: `ES_PORT=9201`, `KIBANA_PORT=5602`
- ✅ Luego: `docker compose up -d`

### "No hay datos en Kibana"
- ✅ Verifica que Filebeat se conecta a Elasticsearch
- ✅ Genera tráfico en Nginx: `curl http://localhost:8080`
- ✅ Espera 10-20 segundos y refresca Kibana

## 📚 Recursos Útiles

- [Documentación Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Documentación Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Documentación Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)

## 📝 Notas Importantes

- **SSL/TLS:** Los certificados son autofirmados. En producción, usa certificados válidos.
- **Contraseñas:** No uses `admin.2025!` en producción. Genera contraseñas fuertes.
- **Memoria:** Ajusta `MEM_LIMIT` según los recursos de tu máquina.
- **Persistencia:** Los volúmenes Docker persisten datos aunque pares los contenedores.

## ✅ Checklist para Producción

- [ ] Cambiar todas las contraseñas en `.env`
- [ ] Usar certificados válidos (no autofirmados)
- [ ] Ajustar `MEM_LIMIT` según servidor
- [ ] Configurar backups de volúmenes
- [ ] Habilitar autenticación HTTPS en Nginx
- [ ] Revisar políticas de índices de Elasticsearch
- [ ] Configurar alertas en Kibana

---

**Creado:** 25 de Noviembre de 2025  
**Stack:** Elasticsearch 9.2.1 + Kibana 9.2.1 + Filebeat 9.2.1  
**Entorno:** Docker Compose v2.0+
