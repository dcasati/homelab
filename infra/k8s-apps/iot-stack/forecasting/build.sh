#!/bin/bash

# DEPRECATED: This build script is no longer used
# 
# The forecasting service now uses the shared Python base image
# and delivers code via ConfigMaps instead of building individual images.
#
# To update the base image:
#   cd ../../../k8s-apps/base-images
#   ./build.sh
#
# To update the forecasting code:
#   Edit configmap.yaml and push to git
#   ArgoCD will sync automatically

echo "ERROR: This build script is deprecated"
echo ""
echo "The forecasting service now uses:"
echo "  - Shared base image: ghcr.io/dcasati/python-base:sha-<commit>"
echo "  - Code delivery: ConfigMap (forecast.py)"
echo "  - No individual image build required"
echo ""
echo "To update:"
echo "  1. Edit k8s-apps/iot-stack/forecasting/configmap.yaml"
echo "  2. git add, commit, and push"
echo "  3. ArgoCD will sync automatically"
echo ""
echo "To update base image:"
echo "  cd ../../../k8s-apps/base-images && ./build.sh"

exit 1
