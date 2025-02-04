output "container_id" {
  description = "The ID of the container"
  value       = docker_container.container.id
}

output "container_name" {
  description = "The name of the container"
  value       = docker_container.container.name
}

output "container_ip" {
  description = "The IP address of the container"
  value       = docker_container.container.network_data[0].ip_address
}