#!/bin/bash

# Build script for forecasting service
# Usage: ./build.sh [tag]

set -e

SERVICE_NAME="forecasting"
REGISTRY="${DOCKER_REGISTRY:-ghcr.io/dcasati}"  # Default to GitHub Container Registry
TAG="${1:-latest}"
IMAGE_NAME="${REGISTRY}/${SERVICE_NAME}:${TAG}"

echo "Building ${SERVICE_NAME} Docker image..."
echo "Image: ${IMAGE_NAME}"

# Build the image
docker build -t "${IMAGE_NAME}" .

# Push to registry
echo "Pushing to registry..."
docker push "${IMAGE_NAME}"

echo "Successfully built and pushed ${IMAGE_NAME}"
echo ""
echo "To use in Kubernetes:"
echo "  image: ${IMAGE_NAME}"
