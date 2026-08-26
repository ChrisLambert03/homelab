# Homelab Automation Infrastructure

<div align="center">

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![K3s](https://img.shields.io/badge/K3s-v1.x-orange?style=for-the-badge&logo=k3s&logoColor=white)](https://k3s.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF6036?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io)
[![Tailscale](https://img.shields.io/badge/Tailscale-HA_Operator-blue?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com)
[![Traefik](https://img.shields.io/badge/Traefik-v3.x-24A1C1?style=for-the-badge&logo=traefikproxy&logoColor=white)](https://traefik.io)
[![Cert-Manager](https://img.shields.io/badge/Cert--Manager-v1.21-green?style=for-the-badge&logo=letsencrypt&logoColor=white)](https://cert-manager.io)
[![HashiCorp Vault](https://img.shields.io/badge/Vault-Secured-000000?style=for-the-badge&logo=vault&logoColor=white)](https://www.vaultproject.io)
[![Longhorn](https://img.shields.io/badge/Longhorn-v1.12.0-yellow?style=for-the-badge&logo=longhorn&logoColor=white)](https://longhorn.io)
[![Ansible](https://img.shields.io/badge/Ansible-Latest-red?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)

</div>

---

Welcome to my homelab! This repository has evolved from a standalone Docker Compose setup into a fully declarative **GitOps and Infrastructure-as-Code (IaC)** architecture. It coordinates bare-metal multi-node provisioning, automated secrets management, Ansible-based configuration, high-availability edge routing with automated wildcard TLS, and a declarative K3s Kubernetes cluster backed by TerraMaster NAS (F4-425 Plus) block & file storage.

## 🏗️ Architecture & Evolution

My infrastructure is centered around a declarative, highly available Kubernetes cluster orchestrated via GitOps:

1. **GitOps Engine (ArgoCD)**: Central declarative deployment pipeline using the App-of-Apps pattern to self-manage applications, Helm releases, and companion manifests.
2. **Kubernetes (K3s)**: 4-node physical bare-metal cluster hosting core services, GPU-accelerated workloads, and dynamic persistent storage.
3. **High-Availability Ingress (Tailscale Operator + ProxyGroup)**: Distributed HA Tailscale Ingress ProxyGroup exposing a permanent virtual gateway with raw TCP TLS passthrough into Traefik.
4. **Edge Routing & Wildcard TLS (Traefik + Cert-Manager)**: Centralized edge ingress using Traefik with automated Let's Encrypt DNS-01 wildcard certificates and granular IP allowlisting (ACLs).
5. **Storage Layer (TerraMaster NAS NFS & iSCSI + Longhorn)**: TerraMaster NAS storage pool providing unified NFS media shares and dedicated iSCSI block LUNs for database/application state, complemented by distributed Longhorn storage.
6. **Security & Secrets**: Centrally orchestrated by HashiCorp Vault with OIDC SSO integration and External Secrets Operator (ESO).

---

## 📝 Recent Accomplishments

- [x] **Tailscale Kubernetes Operator & HA Ingress**: Deployed the official Tailscale Kubernetes Operator via a multi-source Argo CD application. Configured a 2-replica High-Availability `ProxyGroup` (`k8s-ingress-proxy`) distributed across worker nodes.
- [x] **Persistent Virtual Ingress Gateway (VIP)**: Established a permanent Tailscale Virtual Service IP utilizing `spec.loadBalancerClass: tailscale` for raw TCP Layer 4 TLS passthrough, eliminating single-node ingress bottlenecks and enabling seamless multi-node failover.
- [x] **4th Physical Node Onboarded (`opti74`)**: Joined the 4th bare-metal node `opti74` to the K3s cluster as a dedicated worker node.
- [x] **Dedicated Gaming Workload (`palworld`)**: Deployed containerized Palworld dedicated game server onto the `opti74` worker node within the `gaming` namespace.
- [x] **Media Stack Namespace Migration & Storage Refactor**: Completely migrated the media automation stack (`jellyfin`, `prowlarr`, `radarr`, `sonarr`) from `default` into a dedicated `media` namespace. Declared explicit `claimRef` bindings on all 5 TerraMaster persistent volumes (`jellyfin-config-pv`, `nas-media-pv`, `prowlarr-iscsi-pv`, `radarr-iscsi-pv`, `sonarr-iscsi-pv`), achieving 100% bound PVCs with zero data loss.
- [x] **Namespace Segregation**: Reorganized cluster workloads into dedicated logical namespaces:
  - `media`: Jellyfin, Radarr, Sonarr, Prowlarr
  - `observability`: Homarr dashboard, Ntfy notification service
  - `security`: HashiCorp Vault
  - `gaming`: Palworld dedicated game server
  - `external`: Bridged external Docker services
  - `argocd`: ArgoCD GitOps engine & companion ingress
  - `tailscale`: Tailscale Operator & Ingress ProxyGroup
  - `longhorn-system`: Distributed storage engine
  - `kube-system`: Traefik, Cert-Manager, CoreDNS
- [x] **External Secrets Operator (ESO)**: Deployed External Secrets Operator via Argo CD for declarative secret synchronization.
- [x] **CoreDNS High Availability**: Adopted custom CoreDNS configurations and multi-replica HA scaling into GitOps management.
- [x] **Longhorn GitOps Adoption**: Migrated Longhorn to a multi-source Argo CD application with native Ingress routes and a custom `longhorn-retain` StorageClass.
- [x] **Cluster-Wide Wildcard TLS (Traefik `TLSStore`)**: Centralized Let's Encrypt DNS-01 ACME wildcard certificate issuance in the `kube-system` namespace. Configured Traefik's global `default` `TLSStore`, providing zero-touch, cluster-wide SSL termination for all services across all namespaces without duplicating secrets or risking Let's Encrypt rate limits.
- [x] **Self-Managed ArgoCD (App-of-Apps)**: Adopted ArgoCD into its own declarative GitOps model. The root application (`root-apps`) continuously reconciles all application manifests in `kubernetes/apps/`.

---

## 🚀 Active Roadmap

- [ ] **FortiGate-VM + Active Directory / FSSO in KubeVirt**: Architect and deploy virtualized FortiGate next-gen firewall and Windows Server DC on KubeVirt with Multus CNI Linux bridges and TerraMaster iSCSI backing.
- [ ] **Modernize `external-services` with `TraefikService` CRDs**: Refactor static `EndpointSlice` definitions in the `external` namespace to native Traefik Custom Resource Definitions.
- [ ] **Transcoding Offload (Tdarr)**: Transition Tdarr distributed compute nodes to Kubernetes worker nodes.
- [ ] **Storage Tuning**: Benchmark and optimize NFS and iSCSI mount parameters for high-concurrency 4K media streaming.

---

## 📦 Managed Infrastructure Topology

| Host | Role | Workloads / Responsibilities |
| :--- | :--- | :--- |
| **`lenovo`** | K3s Control Plane | K3s API Server, etcd, Argo CD (GitOps Engine), Beszel Hub |
| **`workstation`** | K3s GPU Worker | NVIDIA GPU Operator (RTX A4500), Media Stack Runtime, Hardware Transcoding |
| **`optiplex`** | K3s Worker | Pi-hole DNS, Tailnet Exit Node, General Compute |
| **`opti74`** | K3s Worker | Palworld Dedicated Game Server, Dedicated Worker Node, General Compute |
| **`terramaster`** | Storage SAN/NAS | High-Capacity NFS Media Pool (14TB), iSCSI Target Portal (ext4 Block LUNs for DB state) |
| **`k8s-gateway`** | **Virtual VIP Gateway** | **High-Availability Tailscale Ingress Gateway (Multi-Replica Layer 4 Proxy)** |

---

## 🔧 Infrastructure as Code & GitOps Principles

- **GitOps Pipeline**: Centralized, declarative continuous delivery via ArgoCD using the App-of-Apps pattern (`kubernetes/apps/`).
- **Edge Routing & Ingress**: Managed natively in Kubernetes using Traefik `IngressRoute`, `Middleware` (IP allowlists, HTTPS redirects), and `EndpointSlice` bridging for legacy Docker hosts.
- **Automated TLS**: Cert-Manager with Cloudflare DNS-01 ACME issuing a single wildcard certificate to Traefik's `default` `TLSStore`.
- **Virtual Machines**: Declaratively provisioned via LibVirt using [vms/libvirt-vms.tf](file:///home/chris/homelab/vms/libvirt-vms.tf).
