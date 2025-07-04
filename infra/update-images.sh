#!/bin/bash

# Script to update base image tag in kustomization.yaml
# Usage: ./update-images.sh <commit-sha>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <commit-sha>"
    echo "Example: $0 abc123"
    exit 1
fi

COMMIT_SHA="$1"
KUSTOMIZATION_FILE="k8s-apps/iot-stack/kustomization.yaml"

echo "Updating base image tag to sha-${COMMIT_SHA}..."

# Update python-base image
sed -i "s/newTag: sha-.*/newTag: sha-${COMMIT_SHA}/" "$KUSTOMIZATION_FILE"

# Verify the update
echo "Updated kustomization.yaml:"
grep -A 3 "images:" "$KUSTOMIZATION_FILE"

echo ""
echo "To apply changes:"
echo "1. git add $KUSTOMIZATION_FILE"
echo "2. git commit -m \"Update python-base image to sha-${COMMIT_SHA}\""
echo "3. git push"
echo "4. ArgoCD will sync automatically"
