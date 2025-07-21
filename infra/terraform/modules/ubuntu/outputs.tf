output "vm_id" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.vm_id
  description = "The VM ID of the created Ubuntu server."
}

output "vm_name" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.name
  description = "The name of the created Ubuntu server."
}

output "ip_address" {
  value       = var.networking_settings.ip_config_ipv4
  description = "The IP address of the Ubuntu server."
}

output "vm_node" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.node_name
  description = "The Proxmox node where the VM is deployed."
}
