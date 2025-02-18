#!/bin/bash

# Habilitar modo estricto para detectar errores
set -e

echo "Iniciando contenedor Docker en modo DinD..."
docker run --privileged --name dind-container -d docker:20.10-dind

echo "Esperando que el contenedor esté listo..."
sleep 5  # Esperar unos segundos para asegurar que el contenedor está en ejecución

echo "Instalando Git dentro del contenedor..."
docker exec -it dind-container sh -c "apk add git"

echo "Clonando repositorios..."
docker exec -it dind-container sh -c "
    mkdir -p app && git clone https://github.com/SantiagoHoyosJS/base.git app &&
    mkdir -p repo && git clone https://github.com/JesusC25/Soluciones.git repo &&
    mv repo/* app/
"

echo "Construyendo y levantando la aplicación con Docker Compose..."
docker exec -it dind-container sh -c "
    cd app &&
    docker-compose build &&
    docker-compose up -d
"

echo "Mostrando logs de la aplicación..."
docker exec -it dind-container sh -c "
    cd app &&
    timeout 1 docker-compose logs -f --no-color
"
