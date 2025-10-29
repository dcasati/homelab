terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.43.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

module "microk8s" {
  source            = "./modules/microk8s"
  admin_username    = var.admin_username
  proxmox_node_name = var.proxmox_node_name

  for_each = { for i in range(var.nodes) : i => i } // Changed from var.nodes + 1 to var.nodes

  vm_settings = {
    suffix        = each.value == 0 ? "main" : "worker-${each.value}"
    cpu_cores     = 4 // Changed to 4 for all nodes
    memory_gb     = 24 // Changed to 4 for all nodes
    disk_size_gb  = 200
  }

  networking_settings = {
    ip_config_ipv4    = "172.16.5.${var.ip_address_start_octet + each.value}/24" // Use new variable for IP start
    ip_config_gateway = "172.16.5.1"
    bridge            = "vmbr0"
  }

  microk8s_settings = {
    enable_dashboard     = each.value == 0
    enable_observability = each.value == 0
    metal_lb_settings    = each.value == 0 ? { range = "172.16.5.240-172.16.5.245" } : null
  }

  cloud_init_file_path = "${path.module}/modules/microk8s/config/cloud-init-microk8s-${each.value == 0 ? "main" : "worker-${each.value}"}.yaml"
  proxmox_iso_storage_pool = var.proxmox_iso_storage_pool
  proxmox_snippets_storage_pool = var.proxmox_snippets_storage_pool
  proxmox_vm_disk_storage_pool = var.proxmox_vm_disk_storage_pool
  vmid = var.vm_id_start_offset + each.value
}


resource "null_resource" "wait_for_cloud_init" {
  count = 1

  depends_on = [module.microk8s[0]]

  provisioner "remote-exec" {
    inline = [
      "while ! cloud-init status --wait 2>/dev/null; do sleep 10; done"
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file("~/.ssh/id_rsa")
      host        = module.microk8s[0].ip_address
    }
  }
}

resource "null_resource" "read_file" {
  count = 1

  depends_on = [null_resource.wait_for_cloud_init]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      until ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ${var.admin_username}@${module.microk8s[0].ip_address} 'sudo microk8s config' > config; do
        echo "Waiting for MicroK8s..."
        sleep 5
      done
    EOT
  }
}

resource "null_resource" "fetch_join_command" {
  count = 1

  depends_on = [null_resource.read_file]

  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ${var.admin_username}@${module.microk8s[0].ip_address} \
        "microk8s add-node --worker | grep 'microk8s join'" > ${path.module}/join-command.txt
    EOT
  }
}

data "local_file" "join_command" {
  depends_on = [null_resource.fetch_join_command]
  filename   = "${path.module}/join-command.txt"
}

