terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

# Create the Docker volume first
resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

module "app_network" {
  source       = "./modules/docker_network"
  network_name = "app_network"
}

module "postgres" {
  source         = "./modules/docker_container"
  container_name = "postgres_db"
  image_name     = "postgres:13-alpine"  # Using alpine version for smaller size
  hostname       = "postgres"
  network_name   = module.app_network.network_name
  
  port_mappings = [{
    internal = 5432
    external = 5432
  }]
  
  environment_variables = [
    "POSTGRES_USER=admin",
    "POSTGRES_PASSWORD=adminpass",
    "POSTGRES_DB=registration_db"
  ]
  
  mounts = [{
    target = "/var/lib/postgresql/data"
    source = docker_volume.postgres_data.name
    type   = "volume"
  }]
}

module "webapp" {
  source         = "./modules/docker_container"
  container_name = "webapp"
  image_name     = "local/webapp:latest"
  network_name   = module.app_network.network_name
  build_context  = replace(abspath("${path.module}/app"), "\\", "/")
  
  port_mappings = [{
    internal = 5000
    external = 5001
  }]
  
  restart_policy = "always"
  
  depends_on = [module.postgres]
}

module "nginx" {
  source         = "./modules/docker_container"
  container_name = "nginx_proxy"
  image_name     = "nginx:latest"
  network_name   = module.app_network.network_name
  
  port_mappings = [{
    internal = 80
    external = 80
  }]
  
  mounts = [{
    target = "/etc/nginx/nginx.conf"
    source = replace(abspath("${path.module}/nginx/nginx.conf"), "\\", "/")
    type   = "bind"
  }]
  
  restart_policy = "always"
  
  depends_on = [module.webapp]
}

module "prometheus" {
  source         = "./modules/docker_container"
  container_name = "prometheus_monitor"
  image_name     = "prom/prometheus:v2.31.1"
  network_name   = module.app_network.network_name
  
  port_mappings = [{
    internal = 9090
    external = 9090
  }]
  
  command = [
    "--config.file=/etc/prometheus/prometheus.yaml",
    "--web.external-url=http://localhost/prometheus",
    "--web.route-prefix=/prometheus"
  ]
  
  mounts = [{
    target = "/etc/prometheus/prometheus.yaml"
    source = replace(abspath("${path.module}/prometheus/prometheus.yaml"), "\\", "/")
    type   = "bind"
  }]
  
  restart_policy = "always"
  
  depends_on = [module.webapp]
}

module "grafana" {
  source         = "./modules/docker_container"
  container_name = "grafana_dashboard"
  image_name     = "grafana/grafana:8.2.2"
  network_name   = module.app_network.network_name
  
  port_mappings = [{
    internal = 3000
    external = 3000
  }]
  
  environment_variables = [
    "GF_SERVER_ROOT_URL=http://localhost/grafana"
  ]
  
  mounts = [{
    target = "/etc/grafana/provisioning/datasources"
    source = replace(abspath("${path.module}/grafana/provisioning/datasources"), "\\", "/")
    type   = "bind"
  }]
  
  restart_policy = "always"
  
  depends_on = [module.prometheus]
}