variable "admin_username" {
  type        = string
  description = "The admin username for the VM."
}

variable "vm_settings" {
  type = object({
    suffix       = string
    cpu_cores    = number
    memory_gb    = number
    disk_size_gb = number
  })
  description = "VM configuration settings including suffix, CPU cores, memory, and disk size."
}

variable "networking_settings" {
  type = object({
    ip_config_ipv4    = string
    ip_config_gateway = string
    bridge            = string
  })
  description = "Network configuration settings including IP address, gateway, and bridge."
}

variable "proxmox_node_name" {
  type        = string
  description = "The Proxmox node to deploy the VM to."
}

variable "cloud_init_file_path" {
  type        = string
  description = "Path to the cloud-init configuration file for the VM."
}

variable "proxmox_iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool for ISOs/cloud images."
}

variable "proxmox_snippets_storage_pool" {
  type        = string
  description = "Proxmox storage pool for snippets (cloud-init)."
}

variable "proxmox_vm_disk_storage_pool" {
  type        = string
  description = "Proxmox storage pool for VM disks."
}

variable "vmid" {
  type        = number
  description = "The unique ID for the VM in Proxmox."
}
