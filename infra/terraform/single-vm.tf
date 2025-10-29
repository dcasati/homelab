module "single_ubuntu_vm" {
  source            = "./modules/ubuntu"
  admin_username    = var.admin_username
  proxmox_node_name = var.proxmox_node_name

  vm_settings = {
    suffix        = "standalone"
    cpu_cores     = 2
    memory_gb     = 4
    disk_size_gb  = 40
  }

  networking_settings = {
    ip_config_ipv4    = "dhcp"  # Use DHCP to avoid IP conflicts
    ip_config_gateway = null
    bridge            = "vmbr0"
  }

  cloud_init_file_path          = "${path.module}/modules/ubuntu/config/cloud-init-ubuntu-server.yaml"
  proxmox_iso_storage_pool      = var.proxmox_iso_storage_pool
  proxmox_snippets_storage_pool = var.proxmox_snippets_storage_pool
  proxmox_vm_disk_storage_pool  = var.proxmox_vm_disk_storage_pool
  vmid                         = 400  # Use a different VMID to avoid conflicts
}

output "ubuntu_vm_info" {
  value = {
    vm_id           = module.single_ubuntu_vm.vm_id
    vm_name         = module.single_ubuntu_vm.vm_name
    ip_address      = module.single_ubuntu_vm.ip_address
    all_ip_addresses = module.single_ubuntu_vm.all_ip_addresses
    vm_node         = module.single_ubuntu_vm.vm_node
    vm_status       = module.single_ubuntu_vm.vm_status
  }
  description = "Information about the created Ubuntu VM"
}
