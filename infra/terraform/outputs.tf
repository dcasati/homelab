output "main_node_ip" {
  value = module.microk8s[0].ip_address
}

output "join_command" {
  value = data.local_file.join_command.content
}

