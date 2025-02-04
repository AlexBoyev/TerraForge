variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "hostname" {
  description = "Container hostname"
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name of the network to attach to"
  type        = string
  default     = null
}

variable "port_mappings" {
  description = "List of port mappings"
  type = list(object({
    internal = number
    external = number
  }))
  default = []
}

variable "mounts" {
  description = "List of mount configurations"
  type = list(object({
    target = string
    source = string
    type   = string
  }))
  default = []
}

variable "environment_variables" {
  description = "List of environment variables"
  type        = list(string)
  default     = []
}

variable "command" {
  description = "Container command"
  type        = list(string)
  default     = null
}

variable "restart_policy" {
  description = "Container restart policy"
  type        = string
  default     = "no"
}

variable "build_context" {
  description = "Build context for local images"
  type        = string
  default     = null
}