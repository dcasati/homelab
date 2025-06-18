# Docker Strategy for Homelab

## Overview
This document outlines the Docker image strategy for the homelab infrastructure using GitOps with ArgoCD.

## Directory Structure

```
infra/
├── k8s-apps/
│   └── iot-stack/
│       ├── forecasting/
│       │   ├── Dockerfile
│       │   ├── build.sh
│       │   ├── requirements.txt
│       │   ├── forecast.py
│       │   └── cronjob.yaml
│       └── sunrise/
│           ├── Dockerfile
│           ├── build.sh
│           ├── sunrise_to_influx.py
│           └── sunrise-cronjob.yaml
```

## Image Registry Strategy

### Primary Registry: GitHub Container Registry (GHCR)
```bash
# Images are available at:
ghcr.io/dcasati/service-name:tag
```

### Backup Option: MicroK8s Built-in Registry (Development only)
```bash
# Enable the registry
microk8s enable registry

# Images are available at:
localhost:32000/homelab/service-name:tag
```

### Other Options (Future consideration)
- Docker Hub: `dcasati/homelab-forecasting:latest`
- Harbor/Nexus: `your-registry.com/homelab/forecasting:latest`

## Build Process

### Automated Build (Recommended)
GitHub Actions automatically builds and pushes the Python base image when you:
1. Push changes to `main` or `develop` branch
2. Create pull requests  
3. Modify base image files:
   - `k8s-apps/base-images/Dockerfile`
   - `k8s-apps/base-images/requirements.txt`
   - `.github/workflows/build-images.yml`

The base image is tagged with commit SHA: `ghcr.io/dcasati/python-base:sha-<commit>`

### Manual Build (Development/Testing)
```bash
# Build base image
cd k8s-apps/base-images
./build.sh  # Uses current git commit SHA
# or
./build.sh abc123  # Uses specific commit SHA

# Note: Requires local Docker login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u dcasati --password-stdin
```

### CI/CD Pipeline (Current Implementation)
The GitHub Actions workflow at `.github/workflows/build-images.yml` handles:
- Building only the Python base image when base-images/ changes
- Automatic login to GHCR using `GITHUB_TOKEN`
- SHA-based tagging strategy (no latest tags)
- Multi-platform builds (linux/amd64, linux/arm64)
- Efficient caching for faster builds

## Image Update Strategy

### CronJob Image Updates Challenge
ArgoCD Image Updater has limited support for CronJobs. We solve this using Kustomize image replacements:

1. **CronJob manifests** use base image names (no tags)
2. **Kustomization.yaml** defines the specific image tags
3. **ArgoCD Image Updater** can update Kustomize image configurations
4. **Kustomize** applies the tags to all resources during deployment

### Manual Updates (When needed)
```bash
# Update all images to a specific commit
./update-images.sh abc123

# Commit and push
git add k8s-apps/iot-stack/kustomization.yaml
git commit -m "Update images to sha-abc123"
git push
```

### Automated Updates via ArgoCD Image Updater
- Detects new images with commit SHA tags
- Updates the kustomization.yaml file
- Commits changes back to Git automatically
- Works with CronJobs through Kustomize

## Security Best Practices

1. **Non-root user**: All Dockerfiles use non-root users
2. **Minimal base images**: Use slim/alpine variants
3. **Multi-stage builds**: For compiled languages
4. **Vulnerability scanning**: Use tools like Trivy
5. **Image signing**: Consider cosign for production

## Example Services

### Base Image
- **Location**: `k8s-apps/base-images/`
- **Base Image**: `python:3.11-slim`
- **Registry**: `ghcr.io/dcasati/python-base:sha-<commit>`
- **Purpose**: Common dependencies for all Python services

### Forecasting Service
- **Location**: `k8s-apps/iot-stack/forecasting/`
- **Uses Base Image**: `ghcr.io/dcasati/python-base:sha-<commit>`
- **Code Delivery**: ConfigMap (no individual image built)
- **Deployment**: CronJob using base image + mounted script

### Sunrise Service
- **Location**: `k8s-apps/iot-stack/sunrise/`
- **Uses Base Image**: `ghcr.io/dcasati/python-base:sha-<commit>`
- **Code Delivery**: ConfigMap (no individual image built)
- **Deployment**: CronJob using base image + mounted script

## Troubleshooting

### Common Issues
1. **Registry not accessible**: Check MicroK8s registry addon
2. **Image pull errors**: Verify image exists and permissions
3. **Build failures**: Check Dockerfile syntax and dependencies

### Useful Commands
```bash
# Test base image locally (after GitHub Actions builds it)
docker run --rm ghcr.io/dcasati/python-base:sha-abc123

# Check pod logs
kubectl logs -n iot-stack job/forecast-job-xxxxx

# Check base image details
docker manifest inspect ghcr.io/dcasati/python-base:sha-abc123

# Manual login (only needed for local development)
echo $GITHUB_TOKEN | docker login ghcr.io -u dcasati --password-stdin

# Get current commit SHA
git rev-parse --short HEAD
```
