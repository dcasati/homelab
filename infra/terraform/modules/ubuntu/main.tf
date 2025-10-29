data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

# Use data source to find existing files in the datastore
data "proxmox_virtual_environment_datastores" "iso_datastore" {
  node_name = var.proxmox_node_name
}

# Since we can't import the file easily, we'll reference it directly by its expected ID format
locals {
  cloud_image_id = "${var.proxmox_iso_storage_pool}:iso/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  vm_id       = var.vmid
  node_name   = var.proxmox_node_name
  name        = "ubuntu-${var.vm_settings.suffix}"
  description = "Ubuntu Server - ${var.vm_settings.suffix}"

  cpu {
    cores = var.vm_settings.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_settings.memory_gb * 1024 
  }

  agent {
    enabled = true
    trim    = true
    type    = "virtio"
  }

  network_device {
    bridge = var.networking_settings.bridge
  }

  disk {
    datastore_id = var.proxmox_vm_disk_storage_pool
    file_id      = local.cloud_image_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.vm_settings.disk_size_gb
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.networking_settings.ip_config_ipv4 == "dhcp" ? "dhcp" : var.networking_settings.ip_config_ipv4
        gateway = var.networking_settings.ip_config_ipv4 == "dhcp" ? null : var.networking_settings.ip_config_gateway
      }
    }

    user_account {
      username = var.admin_username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_config.id
  }

  tags = ["ubuntu", var.vm_settings.suffix]

  depends_on = [
    proxmox_virtual_environment_file.cloud_init_config
  ]
}

resource "proxmox_virtual_environment_file" "cloud_init_config" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippets_storage_pool
  node_name    = var.proxmox_node_name
  source_file {
    path = var.cloud_init_file_path
  }
}
