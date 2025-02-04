# TerraForge

**TerraForge** is a Terraform-based project designed to orchestrate a full containerized stack using Docker. With TerraForge, you can easily deploy a robust infrastructure comprising a PostgreSQL database, a Flask web application,
an Nginx reverse proxy, and monitoring solutions like Prometheus and Grafana.

---

## 🚀 Project Overview

TerraForge uses Terraform modules to create and manage the following Docker resources:

- **Docker Network:** A dedicated network for seamless container communication.
- **Docker Volume:** Persistent storage for PostgreSQL data.
- **PostgreSQL Container:** Deployed using the official PostgreSQL image.
- **Flask Web App Container:** Runs your custom Flask application.
- **Nginx Container:** Acts as a reverse proxy to route traffic to your web app.
- **Prometheus Container:** Collects and exposes application metrics.
- **Grafana Container:** Provides a dashboard for visualizing monitoring data.

---

## 📁 Project Structure
├── .terraform
│   ├── modules
│   │   └── modules.json
│   └── providers
├── .terraform.lock.hcl
├── app
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── grafana
│   └── provisioning
│       └── datasources
│           └── datasource.yaml
├── main.tf
├── modules
│   ├── docker_container
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── docker_network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── nginx
│   └── nginx.conf
├── prometheus
│   └── prometheus.yaml
├── terraform.tfstate
├── terraform.tfstate.1738526642.backup
├── terraform.tfstate.backup
├── terraform.tfvars
├── tfplan
└── variables.tf

## 🖥️ Command Flow

**Terraform Commands:**
```sh
# Initialize the working directory
terraform init

# Review the execution plan
terraform plan

# Deploy the infrastructure
terraform apply -auto-approve

# Tear down the infrastructure
terraform destroy -auto-approve


🖥️ Accessing the Services
Service	URL
Nginx Proxy	http://localhost
Prometheus	http://localhost/Prometheus
Grafana	http://localhost/Grafana
