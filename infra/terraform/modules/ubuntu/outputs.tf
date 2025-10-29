output "vm_id" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.vm_id
  description = "The VM ID of the created Ubuntu server."
}

output "vm_name" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.name
  description = "The name of the created Ubuntu server."
}

output "ip_address" {
  value       = length(proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses) > 1 ? proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1] : (length(proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses) == 1 ? proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[0] : "VM booting - IP not yet detected by Proxmox")
  description = "The IP address of the Ubuntu server (DHCP assigned)."
}

output "all_ip_addresses" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses
  description = "All IPv4 addresses detected by Proxmox for this VM."
}

output "vm_status" {
  value = {
    started    = proxmox_virtual_environment_vm.ubuntu_vm.started
    mac_address = length(proxmox_virtual_environment_vm.ubuntu_vm.mac_addresses) > 0 ? proxmox_virtual_environment_vm.ubuntu_vm.mac_addresses[0] : "No MAC detected"
    ip_count   = length(proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses)
  }
  description = "Status information for the Ubuntu VM."
}

output "vm_node" {
  value       = proxmox_virtual_environment_vm.ubuntu_vm.node_name
  description = "The Proxmox node where the VM is deployed."
}
