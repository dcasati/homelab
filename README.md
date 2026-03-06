# elserverloco - MicroK8s Cluster

## Infrastructure

| Component | Details |
|-----------|---------|
| **KVM Host** | `ubuntu@172.16.5.184` (hostname: elserverloco) |
| **MicroK8s VM** | `dcasati@172.16.5.185` (hostname: microk8s) |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | 6.8.0-101-generic |
| **Kubernetes** | v1.33.7 (MicroK8s) |
| **Container Runtime** | containerd 1.7.27 |
| **API Server** | https://172.16.5.185:16443 |
| **VM Resources** | 8 vCPU, 16 GB RAM |
| **VM Disk** | `/vmpool/vms/microk8s.qcow2` (qcow2) |

### Other VMs on the Host

| VM | IP | User | Purpose |
|----|-----|------|---------|
| haos | 172.16.5.148 | N/A (no SSH) | Home Assistant OS |
| unifi | 172.16.5.186 | dcasati | UniFi Network Controller |
| microk8s | 172.16.5.185 | dcasati | Kubernetes cluster |

### KVM Host Network

The host uses a **bridge** (`br0`) so VMs get IPs on the same LAN (172.16.5.0/24).

Netplan config (`/etc/netplan/*.yaml`):
```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp5s0:
      match:
        macaddress: "ac:1f:6b:01:3d:1e"
      set-name: "enp5s0"
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      interfaces:
        - enp5s0
      addresses:
        - 172.16.5.184/24
      routes:
        - to: default
          via: 172.16.5.1
      nameservers:
        addresses:
          - 172.16.5.53
          - 1.1.1.1
      parameters:
        stp: false
        forward-delay: 0
```

### VM Disks

All disks stored in `/vmpool/vms/`:

| File | Size | VM |
|------|------|----|
| `haos.qcow2` | ~18 GB | haos |
| `unifi.qcow2` | ~9.1 GB | unifi |
| `microk8s.qcow2` | ~32 GB | microk8s |
| `microk8s-cidata.iso` | 368 KB | microk8s cloud-init |
| `unifi-cidata.iso` | 368 KB | unifi cloud-init |

Cloud-init source files are kept in `/vmpool/vms/cloud-init/{microk8s,unifi,home-assistant}/`.

---

## VM Creation Details

### haos (Home Assistant OS)

**Specs:** 2 vCPU, 16 GB RAM, UEFI boot (OVMF), TPM 2.0 emulated, i440fx chipset

HAOS uses a pre-built qcow2 image from the [Home Assistant releases](https://github.com/home-assistant/operating-system/releases). No cloud-init — the image is self-contained.

Key differences from other VMs:
- **UEFI firmware** with OVMF (`/usr/share/OVMF/OVMF_CODE_4M.fd`)
- **NVRAM** at `/var/lib/libvirt/qemu/nvram/haos_VARS.fd`
- **SCSI disk** (virtio-scsi controller) instead of virtio
- **e1000 NIC** (not virtio) — bridged to `br0`
- **TPM 2.0** emulated (tpm-crb backend)
- **No guest agent** — no SSH access by default
- **No cloud-init ISO**

Recreate with `virt-install`:
```bash
# Download HAOS image (check latest version at https://github.com/home-assistant/operating-system/releases)
wget https://github.com/home-assistant/operating-system/releases/download/<VERSION>/haos_ova-<VERSION>.qcow2.xz
xz -d haos_ova-<VERSION>.qcow2.xz
mv haos_ova-<VERSION>.qcow2 /vmpool/vms/haos.qcow2

virt-install \
  --name haos \
  --description "Home Assistant OS" \
  --ram 16384 \
  --vcpus 2 \
  --cpu host-passthrough \
  --os-variant generic \
  --boot uefi \
  --machine pc-i440fx-noble-v2 \
  --disk /vmpool/vms/haos.qcow2,bus=scsi \
  --controller scsi,model=virtio-scsi \
  --network bridge=br0,model=e1000 \
  --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
  --graphics none \
  --noautoconsole \
  --import
```

Access via: `http://172.16.5.148:8123`

### unifi (UniFi Network Controller)

**Specs:** 2 vCPU, 16 GB RAM (8 GB current), Q35 chipset, cloud-init provisioned

Cloud-init user-data (`/vmpool/vms/cloud-init/unifi/user-data`):
```yaml
#cloud-config
hostname: unifi
manage_etc_hosts: true
users:
  - name: dcasati
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY8q+Ww2leih7SMZQqaM8a7CyCD1rI8EJ9oKeQbDjq9
timezone: America/Edmonton
package_update: true
package_upgrade: true
packages:
  - net-tools
  - curl
  - wget
  - ca-certificates
  - apt-transport-https
  - qemu-guest-agent
```

Cloud-init meta-data:
```yaml
instance-id: unifi-vm
local-hostname: unifi
```

Cloud-init network-config (`/vmpool/vms/cloud-init/unifi/network-config`):
```yaml
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses:
      - 172.16.5.186/24
    routes:
      - to: default
        via: 172.16.5.1
    nameservers:
      addresses:
        - 172.16.5.53
        - 1.1.1.1
```

Recreate:
```bash
# 1. Create base disk from Ubuntu cloud image
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img create -f qcow2 -b noble-server-cloudimg-amd64.img -F qcow2 /vmpool/vms/unifi.qcow2 50G

# 2. Generate cloud-init ISO
genisoimage -output /vmpool/vms/unifi-cidata.iso -V cidata -r -J \
  /vmpool/vms/cloud-init/unifi/user-data \
  /vmpool/vms/cloud-init/unifi/meta-data \
  /vmpool/vms/cloud-init/unifi/network-config

# 3. Create VM
virt-install \
  --name unifi \
  --ram 16384 \
  --vcpus 2 \
  --cpu host-passthrough \
  --os-variant ubuntu24.04 \
  --machine pc-q35-noble \
  --disk /vmpool/vms/unifi.qcow2,bus=virtio \
  --disk /vmpool/vms/unifi-cidata.iso,device=cdrom \
  --network bridge=br0,model=virtio \
  --channel unix,target.type=virtio,target.name=org.qemu.guest_agent.0 \
  --graphics none \
  --noautoconsole \
  --import
```

### microk8s (Kubernetes Cluster)

**Specs:** 8 vCPU, 16 GB RAM, Q35 chipset, cloud-init provisioned

Cloud-init user-data (`/vmpool/vms/cloud-init/microk8s/user-data`):
```yaml
#cloud-config
hostname: microk8s
manage_etc_hosts: true
users:
  - name: dcasati
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY8q+Ww2leih7SMZQqaM8a7CyCD1rI8EJ9oKeQbDjq9 dcasati@WIN-THINK24
timezone: America/Edmonton
package_update: true
package_upgrade: true
packages:
  - net-tools
  - curl
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release
  - qemu-guest-agent
runcmd:
  - systemctl enable --now qemu-guest-agent
```

Cloud-init meta-data:
```yaml
instance-id: microk8s-vm
local-hostname: microk8s
```

Cloud-init network-config (`/vmpool/vms/cloud-init/microk8s/network-config`):
```yaml
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses:
      - 172.16.5.185/24
    routes:
      - to: default
        via: 172.16.5.1
    nameservers:
      addresses:
        - 172.16.5.53
        - 1.1.1.1
```

Recreate:
```bash
# 1. Create base disk from Ubuntu cloud image
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img create -f qcow2 -b noble-server-cloudimg-amd64.img -F qcow2 /vmpool/vms/microk8s.qcow2 100G

# 2. Generate cloud-init ISO
genisoimage -output /vmpool/vms/microk8s-cidata.iso -V cidata -r -J \
  /vmpool/vms/cloud-init/microk8s/user-data \
  /vmpool/vms/cloud-init/microk8s/meta-data \
  /vmpool/vms/cloud-init/microk8s/network-config

# 3. Create VM
virt-install \
  --name microk8s \
  --description "MicroK8s - Mattermost" \
  --ram 16384 \
  --vcpus 8 \
  --cpu host-passthrough \
  --os-variant ubuntu24.04 \
  --machine pc-q35-noble \
  --disk /vmpool/vms/microk8s.qcow2,bus=virtio \
  --disk /vmpool/vms/microk8s-cidata.iso,device=cdrom \
  --network bridge=br0,model=virtio \
  --channel unix,target.type=virtio,target.name=org.qemu.guest_agent.0 \
  --graphics none \
  --noautoconsole \
  --import

# 4. After first boot, install MicroK8s
ssh dcasati@172.16.5.185
sudo snap install microk8s --classic --channel=1.33/stable
sudo usermod -aG microk8s dcasati
microk8s enable dns hostpath-storage metallb:172.16.5.230-172.16.5.245 helm3
```

## SSH Config

Entries are in `~/.ssh/config`:

```
Host elserverloco  -> ubuntu@172.16.5.184
Host microk8s      -> dcasati@172.16.5.185
Host unifi         -> dcasati@172.16.5.186
Host haos          -> root@172.16.5.148
```

## Kubeconfig

```bash
export KUBECONFIG=$(pwd)/kubeconfig
# or use direnv (.envrc is set up)
```

Retrieve a fresh kubeconfig:
```bash
ssh dcasati@172.16.5.185 "microk8s config" > kubeconfig
```

## MicroK8s Addons

### Enabled
- **dns** - CoreDNS
- **ha-cluster** - High availability configuration
- **helm / helm3** - Helm package manager
- **hostpath-storage** - Storage class (allocates from host directory)
- **metallb** - LoadBalancer for bare-metal
- **storage** - Alias to hostpath-storage (deprecated)

### Disabled (available to enable)
- cert-manager, cis-hardening, community, dashboard, gpu, host-access
- ingress, kube-ovn, mayastor, metrics-server, minio, nvidia
- observability, prometheus, rbac, registry, rook-ceph

Enable an addon:
```bash
ssh dcasati@172.16.5.185 "microk8s enable <addon-name>"
```

## MetalLB Configuration

**IP Address Pool:** `172.16.5.230 - 172.16.5.245`

- Pool name: `default-addresspool`
- Mode: L2 Advertisement (`default-advertise-all-pools`)
- Auto-assign: yes

### Recreate MetalLB Config

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-addresspool
  namespace: metallb-system
spec:
  addresses:
    - 172.16.5.230-172.16.5.245
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-advertise-all-pools
  namespace: metallb-system
```

## Storage

- **Storage Class:** `microk8s-hostpath` (default)
- **Provisioner:** `microk8s.io/hostpath`
- **Reclaim Policy:** Delete
- **Volume Binding:** WaitForFirstConsumer

## Namespaces & Services

### caal
Voice AI assistant stack.

| Service | Type | External IP | Port(s) |
|---------|------|-------------|---------|
| agent | ClusterIP | — | 8889 |
| frontend | ClusterIP | — | 3000 |
| kokoro | ClusterIP | — | 8880 |
| livekit | ClusterIP | — | 7880, 7881 |
| n8n | ClusterIP | — | 5678 |
| n8n-external | LoadBalancer | 172.16.5.236 | 5678 |
| nginx | LoadBalancer | 172.16.5.235 | 3443, 7443 |
| ollama | ClusterIP | — | 11434 |
| speaches | ClusterIP | — | 8000 |
| speaches-external | LoadBalancer | 172.16.5.237 | 8000 |

**Deployments:** agent, frontend, kokoro, livekit, n8n, nginx, speaches

**PVCs:**
| Name | Size | Purpose |
|------|------|---------|
| caal-config | 100Mi | Config storage |
| caal-memory | 1Gi | Memory/state |
| kokoro-cache | 5Gi | Kokoro TTS cache |
| n8n-data | 2Gi | n8n workflow data |
| nginx-certs | 10Mi | TLS certificates |
| speaches-cache | 5Gi | Speaches model cache |

**Secrets:** `caal-secrets` (16 keys)

### mattermost
Team chat deployed via Helm.

| Service | Type | External IP | Port(s) |
|---------|------|-------------|---------|
| mattermost-team-edition | LoadBalancer | 172.16.5.230 | 8065 |
| mattermost-postgresql | ClusterIP | — | 5432 |

**Helm Release:**
```
Chart:       mattermost-team-edition-6.6.93
App Version: 11.4.2
Namespace:   mattermost
```

Reinstall:
```bash
helm repo add mattermost https://helm.mattermost.com
helm install mattermost mattermost/mattermost-team-edition \
  -n mattermost --create-namespace \
  -f mattermost/helm-values.yaml
```

**PVCs:**
| Name | Size |
|------|------|
| mattermost-mattermost-team-edition | 10Gi |
| mattermost-mattermost-team-edition-plugins | 1Gi |
| mattermost-postgresql-data | 10Gi |

### iot-stack
MQTT broker for IoT devices.

| Service | Type | External IP | Port(s) |
|---------|------|-------------|---------|
| mosquitto-service | LoadBalancer | 172.16.5.241 | 1883, 9001 |

**Deployments:** mosquitto

**PVCs:**
| Name | Size |
|------|------|
| mosquitto-data-pvc | 1Gi |

### home-assistant
Voice processing services for Home Assistant.

| Service | Type | External IP | Port(s) |
|---------|------|-------------|---------|
| piper | ClusterIP | — | 10200 |
| piper-external | LoadBalancer | 172.16.5.239 | 10200 |
| whisper | ClusterIP | — | 10300 |
| whisper-external | LoadBalancer | 172.16.5.238 | 10300 |

**Deployments:** mqtt-discovery-bridge, piper, whisper

**PVCs:**
| Name | Size |
|------|------|
| piper-data-pvc | 2Gi |
| whisper-data-pvc | 5Gi |

### wikipedia-offline
Offline Wikipedia served via Kiwix.

| Service | Type | External IP | Port(s) |
|---------|------|-------------|---------|
| kiwix-serve | LoadBalancer | 172.16.5.244 | 80 |

**PVCs:**
| Name | Size |
|------|------|
| zim-data | 200Gi |

## LoadBalancer IP Summary

| IP | Service | Namespace |
|----|---------|-----------|
| 172.16.5.230 | mattermost-team-edition | mattermost |
| 172.16.5.235 | nginx (CAAL frontend) | caal |
| 172.16.5.236 | n8n-external | caal |
| 172.16.5.237 | speaches-external | caal |
| 172.16.5.238 | whisper-external | home-assistant |
| 172.16.5.239 | piper-external | home-assistant |
| 172.16.5.241 | mosquitto-service | iot-stack |
| 172.16.5.244 | kiwix-serve | wikipedia-offline |

## Custom Docker Images

Two locally-built images are loaded directly into the microk8s containerd store (not pulled from a registry):

| Image | Size | Namespace | Exported To |
|---|---|---|---|
| `docker.io/library/caal-agent:latest` | 907.9 MiB | caal | `caal/images/caal-agent.tar` |
| `docker.io/library/caal-frontend:latest` | 246.0 MiB | caal | `caal/images/caal-frontend.tar` |

Source code for these images is also backed up in `caal/agent-src/` and `caal/frontend-src/`.

### Restoring Custom Images

```bash
# Import images into microk8s containerd
microk8s ctr images import caal/images/caal-agent.tar
microk8s ctr images import caal/images/caal-frontend.tar
```

## Directory Structure

```
~/clusters/elserverloco/
├── README.md              # This file
├── kubeconfig             # Cluster kubeconfig
├── .envrc                 # direnv config (sets KUBECONFIG)
├── caal/
│   ├── deploys.yaml
│   ├── services.yaml
│   ├── configmaps.yaml
│   ├── secrets.yaml
│   ├── pvcs.yaml
│   ├── files/             # Bespoke config files from configmaps
│   │   ├── nginx.conf
│   │   ├── livekit.yaml
│   │   ├── generate-certs.sh
│   │   ├── mcp_servers.default.json
│   │   └── settings.default.json
│   ├── agent-src/         # caal-agent custom image source
│   │   ├── voice_agent.py
│   │   ├── entrypoint.sh
│   │   ├── src/caal/
│   │   └── prompt/
│   ├── frontend-src/      # caal-frontend custom image source
│   │   ├── server.js
│   │   ├── package.json
│   │   └── public/
│   └── images/            # Exported custom Docker images
│       ├── caal-agent.tar     (908 MB)
│       └── caal-frontend.tar  (247 MB)
├── mattermost/
│   ├── deploys.yaml
│   ├── services.yaml
│   ├── configmaps.yaml
│   ├── secrets.yaml
│   ├── pvcs.yaml
│   └── helm-values.yaml
├── iot-stack/
│   ├── deploys.yaml
│   ├── services.yaml
│   ├── configmaps.yaml
│   ├── secrets.yaml
│   ├── pvcs.yaml
│   └── files/
│       └── mosquitto.conf
└── home-assistant/
    ├── deploys.yaml
    ├── services.yaml
    ├── configmaps.yaml
    ├── secrets.yaml
    ├── pvcs.yaml
    └── files/
        └── bridge.py
```

## Recreating the Cluster

1. Install MicroK8s: `sudo snap install microk8s --classic --channel=1.33/stable`
2. Enable addons:
   ```bash
   microk8s enable dns hostpath-storage metallb:172.16.5.230-172.16.5.245 helm3
   ```
3. Apply MetalLB config (IPAddressPool + L2Advertisement) from above
4. Create namespaces:
   ```bash
   for ns in caal mattermost iot-stack home-assistant wikipedia-offline; do
     kubectl create namespace $ns
   done
   ```
5. Import custom Docker images:
   ```bash
   microk8s ctr images import caal/images/caal-agent.tar
   microk8s ctr images import caal/images/caal-frontend.tar
   ```
6. Deploy each namespace from the saved YAMLs:
   ```bash
   for ns in caal iot-stack home-assistant; do
     kubectl apply -f $ns/ -n $ns
   done
   ```
7. Deploy Mattermost via Helm:
   ```bash
   helm repo add mattermost https://helm.mattermost.com
   helm install mattermost mattermost/mattermost-team-edition \
     -n mattermost -f mattermost/helm-values.yaml
   ```
