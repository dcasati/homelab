# Ubuntu Server Module

This Terraform module creates an Ubuntu Server VM on Proxmox using cloud-init for initial configuration.

## Features

- Ubuntu 22.04 LTS (Jammy) cloud image
- Cloud-init configuration with basic packages
- SSH key-based authentication
- Configurable VM resources (CPU, memory, disk)
- Network configuration with static IP
- QEMU guest agent for better VM management

## Usage

```hcl
module "ubuntu_server" {
  source = "./modules/ubuntu"

  vmid              = 101
  proxmox_node_name = "proxmox-node"
  admin_username    = "dcasati"

  vm_settings = {
    suffix       = "web"
    cpu_cores    = 2
    memory_gb    = 4
    disk_size_gb = 20
  }

  networking_settings = {
    ip_config_ipv4    = "172.16.5.10/24"
    ip_config_gateway = "172.16.5.1"
    bridge            = "vmbr0"
  }

  cloud_init_file_path           = "./modules/ubuntu/config/cloud-init-ubuntu-server.yaml"
  proxmox_iso_storage_pool       = "local"
  proxmox_snippets_storage_pool  = "local"
  proxmox_vm_disk_storage_pool   = "local-lvm"
}
```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `vmid` | The unique ID for the VM in Proxmox | `number` | Yes |
| `proxmox_node_name` | The Proxmox node to deploy the VM to | `string` | Yes |
| `admin_username` | The admin username for the VM | `string` | Yes |
| `vm_settings` | VM configuration settings | `object` | Yes |
| `networking_settings` | Network configuration settings | `object` | Yes |
| `cloud_init_file_path` | Path to the cloud-init configuration file | `string` | Yes |
| `proxmox_iso_storage_pool` | Proxmox storage pool for ISOs/cloud images | `string` | Yes |
| `proxmox_snippets_storage_pool` | Proxmox storage pool for snippets | `string` | Yes |
| `proxmox_vm_disk_storage_pool` | Proxmox storage pool for VM disks | `string` | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | The VM ID of the created Ubuntu server |
| `vm_name` | The name of the created Ubuntu server |
| `ip_address` | The IP address of the Ubuntu server |
| `vm_node` | The Proxmox node where the VM is deployed |

## Cloud-init Configuration

The default cloud-init configuration includes:
- Package updates and upgrades
- Essential packages (qemu-guest-agent, net-tools, curl, wget, vim, htop, unzip)
- User configuration with SSH key authentication
- Timezone setting (America/Edmonton)
- SSH service enablement

You can customize the cloud-init configuration by modifying the `cloud-init-ubuntu-server.yaml` file or creating your own configuration file and pointing to it with the `cloud_init_file_path` variable.
