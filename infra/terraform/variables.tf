variable "nodes" {
  description = "Total number of MicroK8s virtual machines (e.g., 1 main + 2 workers = 3)"
  type        = number
  default     = 3
}

variable "admin_username" {
  description = "Username to connect to VMs via SSH"
  type        = string
  default     = "ubuntu"
}

variable "proxmox_node_name" {
  description = "The Proxmox node to deploy the VMs to."
  type        = string
  default     = "pve" // Or your specific node name
}

variable "proxmox_api_url" {
  description = "The API URL of the Proxmox VE server (e.g., https://your-proxmox-server:8006/api2/json)"
  type        = string
  # It's recommended to set this via a .tfvars file or environment variable for security.
  # sensitive   = true 
  # default     = "https://<your-proxmox-ip-or-hostname>:8006/api2/json" 
}

variable "proxmox_username" {
  description = "The username for Proxmox VE authentication."
  type        = string
  sensitive   = true
  # No default, should be set via .tfvars or environment variable
}

variable "proxmox_password" {
  description = "The password for Proxmox VE authentication."
  type        = string
  sensitive   = true
  # No default, should be set via .tfvars or environment variable
}

variable "proxmox_iso_storage_pool" {
  description = "Proxmox storage pool where the cloud image (.img file) is located (e.g., 'local', 'iso_datastore')."
  type        = string
  default     = "ISO" // Adjust if your ISO/image storage has a different name
}

variable "proxmox_snippets_storage_pool" {
  description = "Proxmox storage pool for storing cloud-init snippets (e.g., 'local')."
  type        = string
  default     = "local"
}

variable "proxmox_vm_disk_storage_pool" {
  description = "Proxmox storage pool for VM disks (e.g., 'local-lvm')."
  type        = string
  default     = "local-lvm"
}

variable "vm_id_start_offset" {
  description = "Starting VMID for the created virtual machines. Subsequent VMs will have VMID = start_offset + index."
  type        = number
  default     = 300 // Changed to avoid conflict with existing VMs 200-202
}

variable "ip_address_start_octet" {
  description = "Starting octet for the IP addresses of the VMs (e.g., if 210, IPs will be 172.16.5.210, 172.16.5.211, ...)."
  type        = number
  default     = 210
}

