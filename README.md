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

- **HashiCorp Vault Integration** - Implemented the Vault provider to securely manage and fetch homelab secrets dynamically from a Vault KV v2 secrets engine.
- **Variable Refactoring** - Migrated away from plain text variables in `variables.tf`, transitioning all sensitive infrastructure parameters (IPs, credentials, encryption keys, and paths) to use Terraform locals populated securely via the Vault data source (`vault.tf`).

**Logging & Monitoring:**

- **Beszel Monitoring Migration** - Successfully migrated from a resource-intensive Grafana/Prometheus/Node Exporter/cAdvisor stack to **Beszel**. This transition significantly reduced the system footprint while maintaining comprehensive monitoring and alerting.
- **Docker Global Log Driver** - Implementing Docker's built-in logging drivers for centralized container log management
- **ELK Stack Demo** - Deployed Elasticsearch, Logstash, and Kibana for log aggregation, processing, and visualization
- **configure-docker-tls-gelf.yml** - New playbook to configure Docker daemon with TLS and GELF logging driver for sending logs to the ELK stack

**New Services:**

- **n8n** - Workflow automation platform, now integrated with infrastructure
- **Redis** - In-memory data store with persistence configuration
- **Redis Insight** - Redis GUI for monitoring and data inspection

**Existing Ansible Playbooks:**

- **generate-certs.yml** - Generates TLS certificates for Docker hosts
- **deploy-certs.yml** - Deploys TLS certificates to Docker hosts
- **configure-docker.yml** - Configures Docker daemon for TLS authentication
- **tools.yml** - Installs monitoring & diagnostics tools (iperf3, powerstat, htop, lm-sensors, neofetch, nload, fzf, lsusb, lspci, iotop)
- **update.yml** - Automated system package updates and upgrades
- **restart-docker.yml** - Restarts Docker service after configuration changes

### 🚀 Currently Working On

- **Vault Production Migration & Auto-Unseal** - Converting the HashiCorp Vault server from a dev environment to a production-like setup. This includes developing an Ansible playbook to automate the manual unseal process required by the open-source Vault server upon restart.
- **Docker Logging Infrastructure** - Fine-tuning global log driver configuration with ELK stack for centralized log management and demo purposes
- **n8n + Redis Integration** - Optimizing workflow automation platform with Redis backend to support future AI agent pipelines (e.g., automatically updating this README)
- **Terraform Migration** - Continuing to migrate services running on other hosts in the homelab to Terraform-managed infrastructure for improved consistency and automation

## 📦 Terraform-Managed Services

### Docker Services

#### **Jellyfin**

- **Purpose**: Open-source media server for streaming movies, TV shows, and music
- **Configuration**: [docker/workstation/app-jellyfin.tf](docker/workstation/app-jellyfin.tf)

#### **Nginx Proxy Manager**

- **Purpose**: Central reverse proxy and SSL/TLS termination
- **Configuration**: [docker/workstation/app-nginx.tf](docker/workstation/app-nginx.tf) and [nginx/proxy_hosts.tf](nginx/proxy_hosts.tf)

#### **Radarr**

- **Purpose**: Movie collection manager and automation tool
- **Configuration**: [docker/workstation/app-radarr.tf](docker/workstation/app-radarr.tf)

#### **Sonarr**

- **Purpose**: TV show collection manager and automation tool
- **Configuration**: [docker/workstation/app-sonarr.tf](docker/workstation/app-sonarr.tf)

#### **Tdarr**

- **Purpose**: Distributed transcoding and media optimization
- **Configuration**: [docker/workstation/app-tdarr.tf](docker/workstation/app-tdarr.tf)

#### **Prowlarr**

- **Purpose**: Indexer manager for Radarr and Sonarr
- **Configuration**: [docker/workstation/app-prowlarr.tf](docker/workstation/app-prowlarr.tf)

#### **n8n**

- **Purpose**: Workflow automation platform for connecting applications and automating tasks
- **Configuration**: [docker/workstation/app-n8n.tf](docker/workstation/app-n8n.tf)
- **Integration**: Connected to Redis backend for job queuing and state management

#### **Redis**

- **Purpose**: In-memory data store providing caching and state management for n8n and other services
- **Configuration**: [docker/workstation/app-redis.tf](docker/workstation/app-redis.tf)
- **Features**: Persistence enabled with RDB snapshots and AOF logging

#### **Redis Insight**

- **Purpose**: GUI-based Redis database management and monitoring tool
- **Configuration**: [docker/workstation/app-redis-insight.tf](docker/workstation/app-redis-insight.tf)
- **Integration**: Connected to Redis network for visualization and inspection

#### **Homarr**

- **Purpose**: A simple, yet powerful dashboard to access all your favorite applications
- **Configuration**: [docker/lenovo/app-homarr.tf](docker/lenovo/app-homarr.tf)

#### **Ntfy**

- **Purpose**: Send push notifications to your phone or desktop
- **Configuration**: [docker/lenovo/app-ntfy.tf](docker/lenovo/app-ntfy.tf)

#### **Beszel**

- **Purpose**: Lightweight monitoring hub and agent for resource visualization
- **Configuration**:
    - **Hub**: [docker/lenovo/app-beszel.tf](docker/lenovo/app-beszel.tf)
    - **Agents**:
        - [docker/workstation/app-beszel-agent.tf](docker/workstation/app-beszel-agent.tf)
        - [docker/lenovo/app-beszel-agent.tf](docker/lenovo/app-beszel-agent.tf)
        - [docker/optiplex/app-beszel-agent.tf](docker/optiplex/app-beszel-agent.tf)
- **Rationale**: Replaced Grafana/Prometheus/Node Exporter/cAdvisor stack with this lightweight alternative to significantly reduce system resource usage.

### Logging Infrastructure

#### **ELK Stack (Elasticsearch, Logstash, Kibana)**

- **Purpose**: Centralized logging with Elasticsearch, Logstash, and Kibana for container log aggregation, processing, and visualization
- **Configuration**: [docker/workstation/elk-stack-demo.tf](docker/workstation/elk-stack-demo.tf)
- **Components**:
  - **Elasticsearch**: Search and analytics engine for logs
  - **Logstash**: Log processing and transformation pipeline
  - **Kibana**: Web UI for log exploration and visualization
- **Integration**: Docker global log driver sends container logs to Logstash via GELF protocol

### Virtual Machines

#### **LibVirt VMs**

- **Purpose**: Virtual machine infrastructure management
- **Configuration**: [vms/libvirt-vms.tf](vms/libvirt-vms.tf)

## 🔧 Infrastructure as Code (Terraform)
