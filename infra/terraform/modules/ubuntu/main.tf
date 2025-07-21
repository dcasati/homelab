data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
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

  network_device {
    bridge = var.networking_settings.bridge
  }

  disk {
    datastore_id = var.proxmox_vm_disk_storage_pool
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.vm_settings.disk_size_gb
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.networking_settings.ip_config_ipv4
        gateway = var.networking_settings.ip_config_gateway
      }
    }

    user_account {
      username = var.admin_username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_config.id
  }

  tags = ["ubuntu", var.vm_settings.suffix]

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_config" {
  node_name    = var.proxmox_node_name
  content_type = "snippets"
  datastore_id = var.proxmox_snippets_storage_pool
  source_file {
    path = var.cloud_init_file_path
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.proxmox_iso_storage_pool
  node_name    = var.proxmox_node_name
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
