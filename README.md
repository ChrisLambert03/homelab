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

**Kubernetes & Storage Migration:**

- **Terramaster NAS Integration (Storage Node)** - Configured a Terramaster F4-425 Plus NAS (`10.x.x.x`) to serve as the unified storage layer for the homelab. Leverages a `14T` shared NFS media volume (`nas-media-pvc`) for multi-pod file sharing and dedicated `20G` iSCSI block storage targets (`radarr-config`, `sonarr-config`) for stateful config databases.
- **Sonarr & Radarr K3s Migrations** - Migrated Sonarr and Radarr from standalone Docker containers on Workstation to K3s. Applications are deployed as declarative workloads in K3s, mapping config storage directly to dedicated iSCSI targets on the NAS (avoiding database locks during pod updates) and media to the shared NFS mount.
- **K3s Control Plane Deployment** - Migrated `ntfy` and `homarr` from standalone Docker containers on Lenovo to the K3s cluster.
- **Longhorn Persistent Storage** - Integrated Longhorn dynamic volume provisioning on the cluster, deploying `ntfy` as a StatefulSet using a replicated 1Gi storage volume.
- **Longhorn Node Requirements** - Added an Ansible playbook `longhorn-reqs.yml` to automate host-level requirements (`iscsid`, `multipathd`, etc.) for Longhorn storage across cluster nodes.

**Security & Secrets Management:**

- **Docker TLS Authentication** - Migrated all Docker providers (Workstation, Lenovo, Optiplex) to use TCP on port 2376 with native TLS certificate-based authentication, replacing the previous SSH-based connection method for improved performance and security consistency.
- **Production Vault Deployment** - Successfully migrated HashiCorp Vault from an ephemeral Dev mode to a production-grade standalone instance on the Optiplex node.
- **Automated Vault Unsealing** - Implemented a dedicated `vault-unsealer` sidecar container that monitors the Vault status and automatically applies unseal keys upon restart.
- **Variable Refactoring** - Migrated away from plain text variables in `variables.tf`, transitioning all sensitive infrastructure parameters to use Terraform locals populated securely via the Vault data source (`vault.tf`).

**Infrastructure Automation:**

- **Dynamic Image Updates** - Configured all Docker services to use `docker_registry_image` data sources and `pull_triggers` in their `docker_image` resources. This enables Terraform to automatically detect image updates on the registry and trigger container redeployments when a new SHA256 digest is identified.

**Local AI & LLM:**

- **Ollama Integration** - Deployed Ollama on the Workstation node with full NVIDIA RTX A4500 (20GB) GPU passthrough and persistent volume storage. This provides a local backend for LLMs to be used by n8n for intelligent workflow automation.

**Logging & Monitoring:**

- **Beszel Monitoring Migration** - Successfully migrated from a resource-intensive Grafana/Prometheus/Node Exporter/cAdvisor stack to **Beszel**. This transition significantly reduced the system footprint while maintaining comprehensive monitoring and alerting.
- **Docker Global Log Driver** - Implementing Docker's built-in logging drivers for centralized container log management
- **ELK Stack Demo** - Deployed Elasticsearch, Logstash, and Kibana for log aggregation, processing, and visualization

**New Services:**

- **Redis & Redis Insight** - Deployed a persistent Redis data store and GUI for job queuing and inspection across the infrastructure.
- **NAS Proxy Host** - Added a proxy host configuration pointing to the NAS web interface on port 8181 using the `nas_ip` secret retrieved from Vault. See [proxy_hosts.tf](file:///home/chris/homelab/nginx/proxy_hosts.tf).

**Repository Organization & Restructuring:**

- **Ansible Cleanup** - Organized Ansible configurations and templates into `files/` and `templates/` folders while leaving playbooks flat in the root of `/ansible` for CWD execution.
- **Docker Cleanup** - Archived commented-out legacy TF configuration files (Homarr & ntfy) to `docker/archived/` and moved Workstation container reference configurations (`filebeat.yml`, `logstash.conf`) into `docker/workstation/config/`.
- **Kubernetes Cleanup** - Grouped Longhorn NodePort service under `kubernetes/longhorn/` and resolved all formatting and trailing whitespace warnings.

**Existing Ansible Playbooks:**

- **generate-certs.yml** - Generates TLS certificates for Docker hosts
- **deploy-certs.yml** - Deploys TLS certificates to Docker hosts
- **configure-docker.yml** - Configures Docker daemon for TLS authentication
- **tools.yml** - Installs monitoring & diagnostics tools (iperf3, powerstat, htop, lm-sensors, neofetch, nload, fzf, lsusb, lspci, iotop)
- **update.yml** - Automated system package updates and upgrades

### 🚀 Currently Working On

- **Kubernetes Migration** - Continuing the migration of other media and automation services (Jellyfin, Prowlarr, Tdarr, n8n) from Docker to the K3s cluster.
- **HashiCorp Vault PKI Integration** - Investigating and implementing Vault as a Certificate Authority (CA) to automate the generation and renewal of internal TLS certificates for homelab services.
- **NFS & iSCSI Tuning** - Optimizing mount parameters and connection settings between Terramaster NAS and cluster nodes for high-speed file transport.

## 📦 Managed Infrastructure

### **Lenovo (Manager Node)**
- **K3s Cluster**: `ntfy` (StatefulSet, Longhorn), `homarr` (Dashboard), `radarr` (Config on iSCSI, Media on NFS), `sonarr` (Config on iSCSI, Media on NFS).
- **Core Services**: Beszel (Monitoring Hub), Apache Guacamole.
- **Monitoring**: Beszel Agent.

### **Optiplex (Management & Security)**
- **Security**: HashiCorp Vault (Production), Portainer.
- **Monitoring**: Beszel Agent.

### **Workstation (Media & Heavy Lifting)**
- **Media & Entertainment**: Jellyfin (Prepped with NFS media volumes for NAS), RetroArch, Prowlarr, Tdarr.
- **Automation**: n8n, Redis, Redis Insight.
- **AI/ML**: Ollama (NVIDIA RTX A4500 GPU Accelerated).
- **Infrastructure**: Nginx Proxy Manager, ELK Stack (Logging).
- **Monitoring**: Beszel Agent.

### **Terramaster NAS (f4-425 plus - Storage Node)**
- **Storage Services**: Unified NFS Shares (14TB media pool), iSCSI target portal (`10.x.x.x:3260` - ext4 block LUNs for application configs).
- **Host access**: SSH port `9222`.

### Virtual Machines
- **LibVirt**: Managed virtual machines for isolated testing and legacy services.

## 🔧 Infrastructure as Code (Terraform)

### **Nginx Proxy Manager**
- **Purpose**: Handles reverse proxy and SSL termination for internal and external homelab services.
- **Configuration**: [proxy_hosts.tf](file:///home/chris/homelab/nginx/proxy_hosts.tf)

### **Virtual Machines (LibVirt)**
- **Purpose**: Virtual machine infrastructure management.
- **Configuration**: [libvirt-vms.tf](file:///home/chris/homelab/vms/libvirt-vms.tf)
