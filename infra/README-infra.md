# Homelab Infrastructure

This repository contains the infrastructure and Kubernetes applications for the homelab setup.

## Repository Structure

```
infra/
├── terraform/              # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       └── microk8s/       # MicroK8s cluster module
├── argocd/                 # ArgoCD app definitions
│   ├── apps/               # Individual app manifests
│   │   ├── app-of-apps.yaml
│   │   └── iot-stack.yaml
│   └── projects/           # ArgoCD project definitions
│       └── homelab.yaml
└── k8s-apps/              # Kubernetes application manifests
    └── iot-stack/         # IoT stack components
        ├── namespace.yaml
        ├── kustomization.yaml
        ├── influxdb/
        ├── mosquitto/
        ├── telegraf/
        ├── grafana/
        ├── forecasting/
        └── sunrise/
```

## Deployment

### 1. Infrastructure Setup
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Bootstrap ArgoCD Applications
```bash
# Apply the App of Apps pattern to manage all applications
kubectl apply -f argocd/projects/homelab.yaml
kubectl apply -f argocd/apps/app-of-apps.yaml
```

### 3. Manual Application Deployment (if needed)
```bash
kubectl apply -f argocd/apps/iot-stack.yaml
```

## ArgoCD Setup

The repository uses the "App of Apps" pattern for managing multiple applications:

- **homelab project**: Defines permissions and allowed resources
- **app-of-apps**: Manages all application definitions
- **iot-stack**: The main IoT application stack

All applications are configured for automatic sync with pruning and self-healing enabled.

## Applications

### IoT Stack
- **InfluxDB**: Time-series database for sensor data
- **Mosquitto**: MQTT broker for device communication
- **Telegraf**: Data collection agent
- **Grafana**: Visualization and dashboards
- **Forecasting**: Weather prediction cronjobs
- **Sunrise**: Sunrise/sunset data collection

## Development

To add a new application:

1. Create the Kubernetes manifests in `k8s-apps/new-app/`
2. Create an ArgoCD application definition in `argocd/apps/new-app.yaml`
3. The App of Apps will automatically pick up the new application
