# Homelab Automation Infrastructure

Welcome to my homelab! This repository contains the complete infrastructure-as-code configuration for managing a self-hosted services environment. I've transitioned from managing Docker Compose YAML files through Portainer to a full Infrastructure-as-Code approach using Terraform, enabling greater automation, version control, and reproducibility across my homelab infrastructure.

## 🏗️ Overview

This homelab serves as a centralized hub for personal automation, monitoring, and service management. The setup leverages:

- **Docker** for containerization and service isolation
- **Terraform** for Infrastructure-as-Code (IaC) and repeatable deployments
- **Modular Stack Architecture** for organized, scalable service management

### 📝 Recent Changes

Recently configured Ansible playbooks to automate infrastructure management workflows:
- **generate-certs.yml** - Generates TLS certificates for Docker hosts
- **deploy-certs.yml** - Deploys TLS certificates to Docker hosts
- **configure-docker.yml** - Configures Docker daemon for TLS authentication
- **tools.yml** - Installs monitoring & diagnostics tools (iperf3, powerstat, htop, lm-sensors, neofetch, nload, fzf, lsusb, lspci, iotop)
- **update.yml** - Automated system package updates and upgrades
- **restart-docker.yml** - Restarts Docker service after configuration changes

### 🚀 Currently Working On

- **TLS Authentication for Docker Sockets** - Implementing secure TLS authentication across Docker hosts to enable encrypted remote communication with the Docker daemon
- **Terraform Migration** - Continuing to migrate services running on other hosts in the homelab to Terraform-managed infrastructure for improved consistency and automation

## 📦 Terraform-Managed Services

### Docker Services

#### **Jellyfin**

- **Purpose**: Open-source media server for streaming movies, TV shows, and music
- **Configuration**: [docker/app-jellyfin.tf](docker/app-jellyfin.tf)

#### **Nginx Proxy Manager**

- **Purpose**: Central reverse proxy and SSL/TLS termination
- **Configuration**: [docker/app-nginx.tf](docker/app-nginx.tf) and [nginx/proxy_hosts.tf](nginx/proxy_hosts.tf)

#### **Radarr**

- **Purpose**: Movie collection manager and automation tool
- **Configuration**: [docker/app-radarr.tf](docker/app-radarr.tf)

#### **Sonarr**

- **Purpose**: TV show collection manager and automation tool
- **Configuration**: [docker/app-sonarr.tf](docker/app-sonarr.tf)

#### **Tdarr**

- **Purpose**: Distributed transcoding and media optimization
- **Configuration**: [docker/app-tdarr.tf](docker/app-tdarr.tf)

### Virtual Machines

#### **LibVirt VMs**

- **Purpose**: Virtual machine infrastructure management
- **Configuration**: [vms/libvirt-vms.tf](vms/libvirt-vms.tf)

## 🔧 Infrastructure as Code (Terraform)
