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
GitHub Actions automatically builds and pushes images when you:
1. Push changes to `main` branch
2. Create pull requests
3. Modify any Docker-related files:
   - Dockerfiles
   - Python scripts
   - requirements.txt

Images are automatically tagged and pushed to `ghcr.io/dcasati/[service-name]`

### Manual Build (Development/Testing)
```bash
cd k8s-apps/iot-stack/forecasting
./build.sh v1.0.0

# Note: Requires local Docker login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u dcasati --password-stdin
```

### CI/CD Pipeline (Current Implementation)
The GitHub Actions workflow at `.github/workflows/build-images.yml` handles:
- Change detection (only builds modified services)
- Automatic login to GHCR using `GITHUB_TOKEN`
- Multi-tag strategy (latest, branch, SHA)
- Parallel builds for multiple services

## Image Update Strategy

### Option 1: Manual Updates
1. Build new image with tag
2. Update the image tag in Kubernetes manifests
3. Commit and push changes
4. ArgoCD will automatically sync

### Option 2: Image Updater (Recommended)
Install ArgoCD Image Updater to automatically update image tags:
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

Add annotations to your applications:
```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: forecasting=ghcr.io/dcasati/forecasting
    argocd-image-updater.argoproj.io/write-back-method: git
```

## Security Best Practices

1. **Non-root user**: All Dockerfiles use non-root users
2. **Minimal base images**: Use slim/alpine variants
3. **Multi-stage builds**: For compiled languages
4. **Vulnerability scanning**: Use tools like Trivy
5. **Image signing**: Consider cosign for production

## Example Services

### Forecasting Service
- **Location**: `k8s-apps/iot-stack/forecasting/`
- **Base Image**: `python:3.11-slim`
- **Registry**: `ghcr.io/dcasati/forecasting:latest`

### Sunrise Service
- **Location**: `k8s-apps/iot-stack/sunrise/`
- **Base Image**: `python:3.11-slim`
- **Registry**: `ghcr.io/dcasati/sunrise:latest`

## Troubleshooting

### Common Issues
1. **Registry not accessible**: Check MicroK8s registry addon
2. **Image pull errors**: Verify image exists and permissions
3. **Build failures**: Check Dockerfile syntax and dependencies

### Useful Commands
```bash
# Test image locally (after GitHub Actions builds it)
docker run --rm ghcr.io/dcasati/forecasting:latest

# Check pod logs
kubectl logs -n iot-stack job/forecast-job-xxxxx

# Check image details
docker manifest inspect ghcr.io/dcasati/forecasting:latest

# Manual login (only needed for local development)
echo $GITHUB_TOKEN | docker login ghcr.io -u dcasati --password-stdin
```
