terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "container_image" {
  name = var.image_name
  dynamic "build" {
    for_each = var.build_context != null ? [1] : []
    content {
      context = var.build_context
    }
  }
}

resource "docker_container" "container" {
  name     = var.container_name
  image    = docker_image.container_image.name
  hostname = var.hostname

  dynamic "networks_advanced" {
    for_each = var.network_name != null ? [1] : []
    content {
      name = var.network_name
    }
  }

  dynamic "ports" {
    for_each = var.port_mappings
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  dynamic "mounts" {
    for_each = var.mounts
    content {
      target = mounts.value.target
      source = mounts.value.source
      type   = mounts.value.type
    }
  }

  env = var.environment_variables

  command  = var.command
  restart  = var.restart_policy
}