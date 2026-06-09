# Homelab Automation Infrastructure

<div align="center">

[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet?style=for-the-badge&logo=terraform)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-Latest-red?style=for-the-badge&logo=ansible)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker)](https://www.docker.com)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?style=for-the-badge&logo=ubuntu)](https://ubuntu.com)

</div>

---

Welcome to my homelab! This repository contains the complete infrastructure-as-code configuration for managing a self-hosted services environment. I've transitioned from managing Docker Compose YAML files through Portainer to a full Infrastructure-as-Code approach using Terraform, enabling greater automation, version control, and reproducibility across my homelab infrastructure.

## 🏗️ Overview

This homelab serves as a centralized hub for personal automation, monitoring, and service management. The setup leverages:

- **Docker** for containerization and service isolation
- **Terraform** for Infrastructure-as-Code (IaC) and repeatable deployments
- **Modular Stack Architecture** for organized, scalable service management

### 📝 Recent Changes

**Security & Secrets Management:**

- **Docker TLS Authentication** - Migrated all Docker providers (Workstation, Lenovo, Optiplex) to use TCP on port 2376 with native TLS certificate-based authentication, replacing the previous SSH-based connection method for improved performance and security consistency.
- **Production Vault Deployment** - Successfully migrated HashiCorp Vault from an ephemeral Dev mode to a production-grade standalone instance on the Optiplex node.
- **Automated Vault Unsealing** - Implemented a dedicated `vault-unsealer` sidecar container that monitors the Vault status and automatically applies unseal keys upon restart.
- **Variable Refactoring** - Migrated away from plain text variables in `variables.tf`, transitioning all sensitive infrastructure parameters to use Terraform locals populated securely via the Vault data source (`vault.tf`).

**Local AI & LLM:**

- **Ollama Integration** - Deployed Ollama on the Workstation node with full NVIDIA RTX A4500 (20GB) GPU passthrough and persistent volume storage. This provides a local backend for LLMs to be used by n8n for intelligent workflow automation.

**Logging & Monitoring:**

- **Beszel Monitoring Migration** - Successfully migrated from a resource-intensive Grafana/Prometheus/Node Exporter/cAdvisor stack to **Beszel**. This transition significantly reduced the system footprint while maintaining comprehensive monitoring and alerting.
- **Docker Global Log Driver** - Implementing Docker's built-in logging drivers for centralized container log management
- **ELK Stack Demo** - Deployed Elasticsearch, Logstash, and Kibana for log aggregation, processing, and visualization

**New Services:**

- **Redis & Redis Insight** - Deployed a persistent Redis data store and GUI for job queuing and inspection across the infrastructure.

**Existing Ansible Playbooks:**

- **generate-certs.yml** - Generates TLS certificates for Docker hosts
- **deploy-certs.yml** - Deploys TLS certificates to Docker hosts
- **configure-docker.yml** - Configures Docker daemon for TLS authentication
- **tools.yml** - Installs monitoring & diagnostics tools (iperf3, powerstat, htop, lm-sensors, neofetch, nload, fzf, lsusb, lspci, iotop)
- **update.yml** - Automated system package updates and upgrades

### 🚀 Currently Working On

- **HashiCorp Vault PKI Integration** - Investigating and implementing Vault as a Certificate Authority (CA) to automate the generation and renewal of internal TLS certificates for homelab services.
- **Docker Logging Infrastructure** - Fine-tuning global log driver configuration with ELK stack for centralized log management and demo purposes.
- **n8n + Redis Integration** - Optimizing workflow automation platform with Redis backend to support future AI agent pipelines.
- **Terraform Migration** - Continuing to migrate services running on other hosts in the homelab to Terraform-managed infrastructure for improved consistency and automation.

## 📦 Managed Infrastructure

### **Lenovo (Manager Node)**
- **K3s Cluster**: `ntfy` (Notifications).
- **Core Services**: Homarr (Dashboard), Beszel (Monitoring Hub), Apache Guacamole.
- **Monitoring**: Beszel Agent.

### **Optiplex (Management & Security)**
- **Security**: HashiCorp Vault (Production), Portainer.
- **Monitoring**: Beszel Agent.

### **Workstation (Media & Heavy Lifting)**
- **Media & Entertainment**: Jellyfin, *arr Stack (Radarr, Sonarr, Prowlarr, Tdarr), RetroArch.
- **Automation**: n8n, Redis, Redis Insight.
- **AI/ML**: Ollama (NVIDIA RTX A4500 GPU Accelerated).
- **Infrastructure**: Nginx Proxy Manager, ELK Stack (Logging).
- **Monitoring**: Beszel Agent.

### Virtual Machines
- **LibVirt**: Managed virtual machines for isolated testing and legacy services.

## 🔧 Infrastructure as Code (Terraform)
irt VMs**

- **Purpose**: Virtual machine infrastructure management
- **Configuration**: [vms/libvirt-vms.tf](vms/libvirt-vms.tf)

## 🔧 Infrastructure as Code (Terraform)
tocol

### Virtual Machines

#### **LibVirt VMs**

- **Purpose**: Virtual machine infrastructure management
- **Configuration**: [vms/libvirt-vms.tf](vms/libvirt-vms.tf)

## 🔧 Infrastructure as Code (Terraform)
