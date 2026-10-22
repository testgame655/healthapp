#!/bin/bash

# Bash script to build and push Docker images to AWS ECR
# Usage: ./build-and-push-ecr.sh [REGION] [ACCOUNT_ID]

set -e

# Default values
REGION="${1:-us-west-2}"
ACCOUNT_ID="${2:-$(aws sts get-caller-identity --query Account --output text)}"

echo "========================================"
echo "Healthapp Docker Build and Push to ECR"
echo "========================================"
echo ""

# Get AWS Account ID
if [ -z "$ACCOUNT_ID" ]; then
    echo "Error: Could not determine AWS Account ID. Please provide it as second argument."
    exit 1
fi

echo "AWS Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo ""

# ECR Registry URL
REGISTRY_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
echo "ECR Registry URL: $REGISTRY_URL"
echo ""

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY_URL"
echo "Successfully logged in to ECR"
echo ""

# Service configurations
declare -A SERVICES
SERVICES["healthapp-frontend"]="bbhealthapp-frontend"
SERVICES["healthapp-master-service"]="bbhealthapp-backend/bbhealthapp-api-master"
SERVICES["healthapp-register-service"]="bbhealthapp-backend/bbhealthapp-api-register"
SERVICES["healthapp-document-service"]="bbhealthapp-backend/bbhealthapp-api-document"

# Build and push each service
for SERVICE_NAME in "${!SERVICES[@]}"; do
    SERVICE_PATH="${SERVICES[$SERVICE_NAME]}"
    IMAGE_NAME="${REGISTRY_URL}/${SERVICE_NAME}"

    echo "========================================"
    echo "Processing: $SERVICE_NAME"
    echo "========================================"

    # Check if service directory exists
    if [ ! -d "$SERVICE_PATH" ]; then
        echo "Warning: Service path not found: $SERVICE_PATH"
        echo "Skipping $SERVICE_NAME"
        echo ""
        continue
    fi

    # Build image
    echo "Building Docker image..."
    cd "$SERVICE_PATH"
    docker build -t "${IMAGE_NAME}:latest" -f Dockerfile .

    if [ $? -ne 0 ]; then
        echo "Error: Failed to build $SERVICE_NAME"
        cd -
        continue
    fi

    echo "Successfully built $SERVICE_NAME"

    # Tag image
    echo "Tagging image..."
    docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:latest"

    # Push image
    echo "Pushing image to ECR..."
    docker push "${IMAGE_NAME}:latest"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to push $SERVICE_NAME"
        cd -
        continue
    fi

    echo "Successfully pushed $SERVICE_NAME to ECR"
    echo "Image URL: ${IMAGE_NAME}:latest"
    echo ""

    cd -
done

echo "========================================"
echo "Build and Push Complete!"
echo "========================================"
echo ""
echo "Summary:"
echo "Registry: $REGISTRY_URL"
echo "Images pushed:"
for SERVICE_NAME in "${!SERVICES[@]}"; do
    echo "  - ${REGISTRY_URL}/${SERVICE_NAME}:latest"
done
echo ""
