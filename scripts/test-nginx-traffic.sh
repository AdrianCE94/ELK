#!/bin/bash

# Script para generar tráfico HTTP hacia Nginx
# Uso: ./test-nginx-traffic.sh [numero_de_peticiones] [concurrencia]

REQUESTS=${1:-100}  # Por defecto 100 peticiones
CONCURRENCY=${2:-10}  # Por defecto 10 peticiones concurrentes
NGINX_URL="http://localhost:8080"

echo "======================================"
echo "Generando tráfico HTTP hacia Nginx"
echo "======================================"
echo "URL: $NGINX_URL"
echo "Total peticiones: $REQUESTS"
echo "Concurrencia: $CONCURRENCY"
echo "======================================"

# Verificar si ab (Apache Benchmark) está instalado
if command -v ab &> /dev/null; then
    echo "Usando Apache Benchmark (ab)..."
    ab -n $REQUESTS -c $CONCURRENCY $NGINX_URL/
elif command -v hey &> /dev/null; then
    echo "Usando hey..."
    hey -n $REQUESTS -c $CONCURRENCY $NGINX_URL/
else
    echo "Usando curl (método alternativo)..."
    echo "Para mejores resultados, instala 'ab' o 'hey'"
    for i in $(seq 1 $REQUESTS); do
        curl -s -o /dev/null -w "%{http_code}\n" $NGINX_URL/ &
        if [ $((i % CONCURRENCY)) -eq 0 ]; then
            wait
        fi
    done
    wait
fi

echo ""
echo "======================================"
echo "Generando algunos errores 404..."
echo "======================================"

# Generar algunos errores 404 para tener variedad en los logs
for i in {1..20}; do
    curl -s -o /dev/null -w "%{http_code}\n" $NGINX_URL/error$i &
done
wait

echo ""
echo "✓ Tráfico generado exitosamente"
echo "  Puedes verificar los logs en Kibana"
