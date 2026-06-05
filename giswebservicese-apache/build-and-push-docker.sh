#!/bin/bash
set -e

echo "=========================================="
echo "Сборка и публикация Docker образа"
echo "=========================================="

# Параметры
BUILD_NUMBER="${BUILD_NUMBER:-0}"
IMAGE_NAME="giswebservicese-apache"
REGISTRY="192.168.1.166:80"
REGISTRY_PATH="${REGISTRY}/giswebservicese"
REGISTRY_TAG="${REGISTRY_PATH}/${IMAGE_NAME}:${BUILD_NUMBER}"

# Путь к deb пакету для Astra Linux (только deb)
DEB_PACKAGE_PATH=".build/astra-1.6/Install/giswebservicese/giswebservicese.deb"

echo "Номер сборки: ${BUILD_NUMBER}"
echo "Итоговый тег образа: ${REGISTRY_TAG}"
echo "Путь к deb пакету: ${DEB_PACKAGE_PATH}"

# Проверяем существование deb пакета
if [ ! -f "${DEB_PACKAGE_PATH}" ]; then
    echo "ОШИБКА: deb пакет не найден: ${DEB_PACKAGE_PATH}"
    echo "Доступные файлы:"
    ls -la .build/astra-1.6/Install/giswebservicese/ 2>/dev/null || echo "Директория не существует"
    exit 1
fi

# Создаем временную директорию для Docker контекста
echo "Подготовка Docker контекста..."
mkdir -p docker-build-context
cp "${DEB_PACKAGE_PATH}" docker-build-context/giswebservicese.deb
cp .docker/Dockerfile docker-build-context/

# Собираем Docker образ сразу с тегом для registry
echo "Сборка Docker образа..."
cd docker-build-context
docker build -t "${REGISTRY_TAG}" .

# Логин в registry
echo "Логин в Docker registry..."
echo "${DOCKER_REGISTRY_PASSWORD}" | docker login "http://${REGISTRY}" \
    --username "${DOCKER_REGISTRY_USER}" \
    --password-stdin

# Публикуем
echo "Публикуем образ в registry..."
docker push "${REGISTRY_TAG}"

# Очистка
cd ..
rm -rf docker-build-context
docker rmi "${REGISTRY_TAG}" 2>/dev/null || true

echo "=========================================="
echo "Успешно!"
echo "Образ опубликован: ${REGISTRY_TAG}"
echo "=========================================="