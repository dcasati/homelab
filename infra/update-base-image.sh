#!/bin/bash

# Script to update base image SHA in service Dockerfiles
# Usage: ./update-base-image.sh <commit-sha>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <commit-sha>"
    echo "Example: $0 abc123"
    echo ""
    echo "This will update all service Dockerfiles to use:"
    echo "  FROM ghcr.io/dcasati/python-base:sha-abc123"
    exit 1
fi

COMMIT_SHA="$1"
BASE_IMAGE="ghcr.io/dcasati/python-base:sha-${COMMIT_SHA}"

echo "Updating base image references to: ${BASE_IMAGE}"

# Update forecasting Dockerfile
if [ -f "k8s-apps/iot-stack/forecasting/Dockerfile" ]; then
    sed -i "s|FROM ghcr.io/dcasati/python-base:sha-.*|FROM ${BASE_IMAGE}|" k8s-apps/iot-stack/forecasting/Dockerfile
    echo "✓ Updated forecasting/Dockerfile"
fi

# Update sunrise Dockerfile
if [ -f "k8s-apps/iot-stack/sunrise/Dockerfile" ]; then
    sed -i "s|FROM ghcr.io/dcasati/python-base:sha-.*|FROM ${BASE_IMAGE}|" k8s-apps/iot-stack/sunrise/Dockerfile
    echo "✓ Updated sunrise/Dockerfile"
fi

echo ""
echo "Base image updated to sha-${COMMIT_SHA}"
echo ""
echo "Next steps:"
echo "1. git add k8s-apps/iot-stack/*/Dockerfile"
echo "2. git commit -m \"Update base image to sha-${COMMIT_SHA}\""
echo "3. git push"
