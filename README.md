# Homelab Automation Infrastructure

<div align="center">

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![K3s](https://img.shields.io/badge/K3s-v1.x-orange?style=for-the-badge&logo=k3s&logoColor=white)](https://k3s.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF6036?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io)
[![Traefik](https://img.shields.io/badge/Traefik-v3.x-24A1C1?style=for-the-badge&logo=traefikproxy&logoColor=white)](https://traefik.io)
[![Cert-Manager](https://img.shields.io/badge/Cert--Manager-v1.21-green?style=for-the-badge&logo=letsencrypt&logoColor=white)](https://cert-manager.io)
[![HashiCorp Vault](https://img.shields.io/badge/Vault-Secured-000000?style=for-the-badge&logo=vault&logoColor=white)](https://www.vaultproject.io)
[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-Latest-red?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)

</div>

---

Welcome to my homelab! This repository has evolved from a standalone Docker Compose setup managed via Portainer into a fully declarative **GitOps and Infrastructure-as-Code (IaC)** architecture. It coordinates multi-node provisioning, automated secrets management, Ansible-based configuration, centralized edge routing with automated wildcard TLS, and a declarative K3s Kubernetes cluster backed by a dedicated NAS storage layer.

## 🏗️ Architecture & Evolution

My infrastructure is centered around a declarative, highly available Kubernetes cluster orchestrated via GitOps:

1. **GitOps Engine (ArgoCD)**: Central declarative deployment pipeline using the App-of-Apps pattern to self-manage applications, Helm releases, and companion manifests.
2. **Kubernetes (K3s)**: Multi-node cluster hosting core services, GPU-accelerated workloads, and dynamic persistent storage.
3. **Edge Routing & Wildcard TLS (Traefik + Cert-Manager)**: Centralized edge ingress using Traefik with automated Let's Encrypt DNS-01 wildcard certificates and IP allowlisting (ACLs).
4. **Storage (NFS & iSCSI)**: Terramaster NAS storage pool providing unified NFS media shares (`14T`) and dedicated iSCSI block LUNs for database/application state.
5. **Security & Secrets**: Centrally orchestrated by HashiCorp Vault with OIDC SSO integration.
6. **Docker (Managed by Terraform)**: Legacy hosting layer for standalone nodes and utilities.

### 📝 Recent Changes

- **Self-Managed ArgoCD (App-of-Apps)**: Adopted ArgoCD into its own declarative GitOps model. The root application (`root-apps`) continuously reconciles all application manifests in `kubernetes/apps/`, and ArgoCD manages its own Helm chart and companion `IngressRoute` with automated self-healing.
- **Cluster-Wide Wildcard TLS (Traefik `TLSStore`)**: Centralized Let's Encrypt DNS-01 ACME wildcard certificate issuance (`*.lambertlab.us`) in the `kube-system` namespace. Configured Traefik's global `default` `TLSStore`, providing zero-touch, cluster-wide SSL termination for all services across all namespaces without duplicating secrets or risking Let's Encrypt rate limits.
- **Ingress Modernization & Cleanup**: Refactored all 18 Ingress manifests across the cluster to utilize the global `TLSStore`, removing redundant per-ingress TLS secret blocks and eliminating cross-namespace secret synchronization overhead.
- **ArgoCD IngressRoute & gRPC Support**: Deployed a native Traefik `IngressRoute` in the `argocd` namespace with dual routing rules—serving the Web UI over HTTPS and the `argocd` CLI/API over gRPC (`scheme: h2c`) under `https://argocd.lambertlab.us` with `admin-only-access` IP allowlisting.
- **Full GitOps Adoption**: Declaratively onboarded all cluster applications into ArgoCD:
  - `cert-manager` (Helm v1.21.1)
  - `longhorn` (Distributed Block Storage Helm chart v1.12.0)
  - `gpu-operator` (NVIDIA GPU Operator v26.3.3)
  - `jellyfin` (Multi-source Helm chart + custom values and volume mounts)
  - `vault` (StatefulSet on Longhorn, ClusterIP)
  - `ntfy` (StatefulSet on Longhorn, ClusterIP)
  - `homarr` (Dashboard, ClusterIP)
  - `prowlarr`, `radarr`, `sonarr` (Media automation stack, ClusterIP, iSCSI + NFS)
  - `external-services` (Multi-source declarative routing for bridged Docker endpoints: Cockpit, Firefox, Guacamole, Kibana, NAS, Pi-hole, Portainer, RedisInsight, RetroArch, Tdarr)
- **Service Security Hardening**: Converted internal services (`homarr`, `ntfy`, `vault`, `sonarr`, `radarr`, `prowlarr`) from legacy `NodePort` exposures to strict `ClusterIP` services.
- **Cert-Manager Upgrade**: Upgraded Cert-Manager to `v1.21.1` and adopted its Helm release into ArgoCD management.
- **Traefik Migration**: Decommissioned Nginx Proxy Manager; migrated all reverse proxying, SSL termination, and IP allowlisting into Traefik Middlewares and EndpointSlices.
- **SSO & RBAC Integration**: Integrated Microsoft Entra ID (OIDC) for single sign-on and role-based access control across Kubernetes and HashiCorp Vault.

### 🚀 Currently Working On

- **High Availability Ingress**: Evaluating the deployment of the Helm Tailscale Operator to establish a shared Virtual IP (VIP) and eliminate single points of failure in ingress routing.
- **K3s Migration**: Continuing the transition of remaining media (Tdarr) stacks to Kubernetes.
- **Storage Optimization**: Performance-tuning NFS and iSCSI mount parameters for high-throughput media transport.

---

## 📦 Managed Infrastructure

### **Lenovo (Manager Node & K3s Control Plane)**

- **K3s Cluster Core**:
  - `argocd` (Self-Managed GitOps Engine & Deployment Pipeline)
  - `vault` (StatefulSet, Longhorn Storage, ClusterIP)
  - `ntfy` (StatefulSet, Longhorn Storage, ClusterIP)
  - `homarr` (Dashboard, ClusterIP)
  - `prowlarr` (iSCSI Config, ClusterIP)
  - `radarr` (iSCSI Config, NFS Media Pool, ClusterIP)
  - `sonarr` (iSCSI Config, NFS Media Pool, ClusterIP)
  - `jellyfin` (Helm, iSCSI Config, NFS Media Pool, NVIDIA CDI Passthrough)
- **Core Services**: Beszel (Monitoring Hub), Apache Guacamole.

### **Optiplex (Management & Security)**

- **Security & Admin**: Portainer, worker compute node.

### **Workstation (Media & Heavy Lifting)**

- **Docker Container Services**: RetroArch, Tdarr, Redis, Ollama (RTX A4500 GPU Accelerated), ELK Stack.
- **Kubernetes Worker**: GPU Operator worker node for hardware-accelerated workloads.

### **Terramaster NAS (f4-425 plus - Storage Node)**

- **Storage Services**: NFS Shares (14TB media pool), iSCSI target portal (ext4-formatted block volumes for K8s pod DB configs).

### **Virtual Machines (LibVirt)**

- **LibVirt VMs**: Declaratively configured on local hosts for isolated testing and future Active Directory lab deployments.

---

## 🔧 Infrastructure as Code & GitOps

- **GitOps Pipeline**: Centralized, declarative continuous delivery via ArgoCD using the App-of-Apps pattern (`kubernetes/apps/`).
- **Edge Routing & Ingress**: Managed natively in Kubernetes using Traefik `IngressRoute`, `Middleware` (IP allowlists, HTTPS redirects), and `EndpointSlice` bridging for legacy Docker hosts.
- **Automated TLS**: Cert-Manager with Cloudflare DNS-01 ACME issuing a single wildcard certificate to Traefik's `default` `TLSStore`.
- **Virtual Machines**: Declaratively provisioned via LibVirt using [vms/libvirt-vms.tf](file:///home/chris/homelab/vms/libvirt-vms.tf).
