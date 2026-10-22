#!/bin/bash

# Bash script to build Docker images locally for testing
# Usage: ./build-local.sh

set -e

echo "========================================"
echo "Healthapp Local Docker Build"
echo "========================================"
echo ""

# Service configurations
declare -A SERVICES
SERVICES["healthapp-frontend"]="bbhealthapp-frontend:healthapp-frontend"
SERVICES["healthapp-master-service"]="bbhealthapp-backend/bbhealthapp-api-master:healthapp-master-service"
SERVICES["healthapp-register-service"]="bbhealthapp-backend/bbhealthapp-api-register:healthapp-register-service"
SERVICES["healthapp-document-service"]="bbhealthapp-backend/bbhealthapp-api-document:healthapp-document-service"

# Build each service
for SERVICE_KEY in "${!SERVICES[@]}"; do
    IFS=':' read -r SERVICE_PATH IMAGE_NAME <<< "${SERVICES[$SERVICE_KEY]}"

    echo "========================================"
    echo "Building: $SERVICE_KEY"
    echo "========================================"

    # Check if service directory exists
    if [ ! -d "$SERVICE_PATH" ]; then
        echo "Warning: Service path not found: $SERVICE_PATH"
        echo "Skipping $SERVICE_KEY"
        echo ""
        continue
    fi

    # Build image
    echo "Building Docker image..."
    cd "$SERVICE_PATH"
    docker build -t "${IMAGE_NAME}:latest" -f Dockerfile .

    if [ $? -ne 0 ]; then
        echo "Error: Failed to build $SERVICE_KEY"
        cd -
        continue
    fi

    echo "Successfully built $SERVICE_KEY"
    echo "Image: ${IMAGE_NAME}:latest"
    echo ""

    cd -
done

echo "========================================"
echo "Local Build Complete!"
echo "========================================"
echo ""
echo "Built images:"
for SERVICE_KEY in "${!SERVICES[@]}"; do
    IFS=':' read -r SERVICE_PATH IMAGE_NAME <<< "${SERVICES[$SERVICE_KEY]}"
    echo "  - ${IMAGE_NAME}:latest"
done
echo ""
echo "To test images, you can run:"
echo "  docker run -p 80:80 healthapp-frontend"
echo "  docker run -p 8081:8081 healthapp-master-service"
echo "  docker run -p 8082:8082 healthapp-register-service"
echo "  docker run -p 8083:8083 healthapp-document-service"
echo ""
