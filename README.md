# Homelab Automation Infrastructure

<div align="center">

[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet?style=for-the-badge&logo=terraform)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-Latest-red?style=for-the-badge&logo=ansible)](https://www.ansible.com)
[![K3s](https://img.shields.io/badge/K3s-v1.x-orange?style=for-the-badge&logo=kubernetes)](https://k3s.io)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker)](https://www.docker.com)

</div>

---

Welcome to my homelab! This repository has evolved from a standalone Docker Compose setup managed via Portainer into a hybrid GitOps and Infrastructure-as-Code (IaC) configuration. It coordinates multi-node provisioning, automated secrets management, Ansible-based configuration, and a progressive migration to a K3s Kubernetes cluster backed by a dedicated NAS storage layer.

## 🏗️ Architecture & Evolution

My infrastructure is transitioning from standalone Docker hosts to a highly available, k8s cluster orchestrated model:

1. **Docker (Managed by Terraform)**: Legacy hosting layer for standalone applications and utilities.
2. **Kubernetes (K3s)**: Active migration target hosting core services with dynamic storage provisioning.
3. **Storage (NFS & iSCSI)**: Configured on a Terramaster NAS storage node to serve as the unified storage layer.
4. **Security & Secrets**: Centrally orchestrated by a HashiCorp Vault instance.

### 📝 Recent Changes

- **Traefik Migration**: Completely decommissioned Nginx Proxy Manager. Migrated all reverse proxying, SSL termination, and IP allowlisting (ACLs) into Kubernetes natively using Traefik Middlewares and EndpointSlices.
- **n8n Removal**: Completely removed the n8n automation stack from both Docker and Kubernetes infrastructure.
- **Kubernetes Migration**: Migrated `vault`, `ntfy`, `homarr`, `prowlarr`, `sonarr`, `radarr`, and `jellyfin` from Docker to the K3s cluster. Native NVIDIA GPU passthrough is now handled via the CDI standard.
- **Helm Adoption**: Transitioned to using Helm for managing complex cluster deployments. Successfully deployed the NVIDIA GPU Operator and Jellyfin using official Helm charts and custom `values.yaml` configurations.
- **Storage Integration**: Connected Terramaster NAS for unified NFS media sharing (`14T` pool) and dedicated iSCSI LUNs (`20G` per target) for database/configuration persistence.
- **Repo Restructuring**: Organized Ansible playbooks/templates and workstation log configuration files, keeping directories clean and modular.
- **Security Hardening**: Migrated all Docker host engines to TCP/TLS socket connections and refactored Terraform variables to read directly from Vault.
- **SSO & RBAC Integration**: Leveraged Microsoft Entra ID (OIDC) to implement single sign-on and role-based access control (RBAC) across the K3s cluster and HashiCorp Vault instance.

### 🚀 Currently Working On

- **High Availability Ingress**: Currently, the reverse proxy only points to a single node in the cluster, creating a single point of failure. I am evaluating the deployment of the Helm Tailscale Operator to establish a shared Virtual IP (VIP) and resolve this.
- **K3s Migration**: Continuing the transition of remaining media (Tdarr) stacks to Kubernetes.
- **Storage Optimization**: Performance-tuning NFS and iSCSI mount parameters for high-throughput media transport.

---

## 📦 Managed Infrastructure

### **Lenovo (Manager Node & K3s Control Plane)**

- **K3s Cluster**: `vault` (StatefulSet, Longhorn), `ntfy` (StatefulSet, Longhorn), `homarr` (Dashboard), `prowlarr` (iSCSI Config), `radarr` (iSCSI Config, NFS Media), `sonarr` (iSCSI Config, NFS Media), `jellyfin` (iSCSI Config, NFS Media, GPU Accelerated).
- **Core Services**: Beszel (Monitoring Hub), Apache Guacamole.

### **Optiplex (Management & Security)**

- **Security**: Portainer.

### **Workstation (Media & Heavy Lifting)**

- **Docker Container Services**: RetroArch, Tdarr, Redis, Ollama (RTX A4500 GPU Accelerated), ELK Stack.

### **Terramaster NAS (f4-425 plus - Storage Node)**

- **Storage Services**: NFS Shares (14TB media pool), iSCSI target portal (ext4-formatted block volumes for K8s pod DB configs).

### **Virtual Machines (LibVirt)**

- **LibVirt VMs**: Configured on local hosts for isolated testing.
- _Note: VM infrastructure is designated for future Active Directory lab VM deployments._

---

## 🔧 Infrastructure as Code

- **Traefik Ingress**: Managed natively in Kubernetes using Traefik Middlewares for IP Allowlisting (ACLs) and EndpointSlices for bridging legacy Docker applications into the K3s routing mesh.
- **Virtual Machines**: Declaratively provisioned via LibVirt using [vms/libvirt-vms.tf](file:///home/chris/homelab/vms/libvirt-vms.tf).
