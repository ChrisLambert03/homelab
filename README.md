# Homelab Automation Infrastructure

<div align="center">

[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s_v1.36-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![KubeVirt](https://img.shields.io/badge/KubeVirt-Virtualization-purple?style=for-the-badge&logo=redhatopenshift&logoColor=white)](https://kubevirt.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF6036?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io)
[![OPNsense](https://img.shields.io/badge/OPNsense-Gateway-D94A38?style=for-the-badge&logo=opnsense&logoColor=white)](https://opnsense.org)
[![Active Directory](https://img.shields.io/badge/Active_Directory-Windows_Server_2025-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows-server)
[![Entra ID](https://img.shields.io/badge/Entra_ID-OIDC_RBAC-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/en-us/entra/identity/)
[![Tailscale](https://img.shields.io/badge/Tailscale-Direct_Mesh-blue?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-DNS_Round_Robin-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://www.cloudflare.com)
[![Traefik](https://img.shields.io/badge/Traefik-v3.x-24A1C1?style=for-the-badge&logo=traefikproxy&logoColor=white)](https://traefik.io)
[![HashiCorp Vault](https://img.shields.io/badge/Vault-Secured-000000?style=for-the-badge&logo=vault&logoColor=white)](https://www.vaultproject.io)
[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Longhorn](https://img.shields.io/badge/Longhorn-v1.12.0-yellow?style=for-the-badge&logo=longhorn&logoColor=white)](https://longhorn.io)

</div>

---

Welcome to my homelab repository. This infrastructure coordinates bare-metal multi-node physical compute, enterprise virtualization via **KubeVirt**, automated secrets management with **HashiCorp Vault**, high-availability edge routing with automated wildcard TLS, and a declarative **K3s Kubernetes cluster** backed by **TerraMaster NAS (F4-425 Plus)** block and file storage.

The entire environment is managed declaratively through **GitOps (ArgoCD)** and **Infrastructure as Code (Terraform)**.

---

## 🏛️ Core Architectural Pillars

### 1. Orchestration & Virtualization (K3s + KubeVirt)
* **High-Availability Control Plane**: 3-node embedded `etcd` quorum (`lenovo`, `optiplex`, `opti74`) running K3s for seamless master failover.
* **Dedicated GPU Worker**: Bare-metal `workstation` hosting an NVIDIA RTX GPU with the NVIDIA GPU Operator for hardware-accelerated transcoding and compute.
* **Cloud-Native Virtualization**: KubeVirt runs core virtual appliances directly inside Kubernetes, unifying virtual machine and container lifecycles under standard Kubernetes APIs.

### 2. Software-Defined Networking & Edge Ingress
* **Multi-Node L2 Overlay**: Cluster-wide multicast VXLAN (`br-lab0` via NMState) providing direct Layer 2 connectivity between virtual machines across physical nodes without switch VLAN trunking.
* **Preserved Client IP Ingress**: Distributed edge routing via Tailscale mesh and Cloudflare DNS round-robin (`*.lambertlab.us`) across physical node interfaces, preserving true client source IPs into Traefik.
* **Firewall & Routing Gateway**: Virtualized OPNsense router enforcing network policies, DNS resolution, and bidirectional port forwarding with symmetric return-path SNAT.

### 3. Dual-Directory Identity & Security
* **Cloud / K8s IAM**: Native OpenID Connect (OIDC) authentication on `kube-apiserver` integrated with Microsoft Entra ID (Azure AD), public-client PKCE login via `Azure/kubelogin`, and RBAC group rolebindings.
* **On-Premise IAM**: Windows Server 2025 Active Directory domain controller (`lambertlab.us`), managed declaratively via Terraform over HTTPS WinRM.
* **Secrets Orchestration**: HashiCorp Vault paired with External Secrets Operator (ESO) for declarative in-cluster secret synchronization.

### 4. GitOps & Declarative IaC
* **ArgoCD App-of-Apps**: Continuous automated reconciliation of application manifests, Helm releases, and NMState node network configurations across deterministic sync waves (0–3).
* **Terraform Engine**: Manages Cloudflare DNS automation, Tailscale resources, workstation Docker daemon workloads, and Active Directory objects (OUs, groups, users, service accounts).

### 5. Storage Layer (NAS SAN + Longhorn)
* **TerraMaster NAS SAN**: Unified NFS media shares (14TB) combined with dedicated iSCSI block LUNs for low-latency database state.
* **Distributed Replication**: Longhorn storage class providing multi-replica, distributed block storage across bare-metal nodes.

---

## 📦 Managed Infrastructure Topology

| Host / Resource | Type | Role | Key Services & Workloads |
| :--- | :--- | :--- | :--- |
| **`lenovo`** | Physical | K3s HA Control Plane (etcd) | K3s API Server, etcd Member, ArgoCD GitOps Engine, Beszel Hub |
| **`optiplex`** | Physical | K3s HA Control Plane (etcd) | K3s API Server, etcd Member, Ingress Proxy, General Compute |
| **`opti74`** | Physical | K3s HA Control Plane (etcd) | K3s API Server, etcd Member, Palworld Dedicated Server |
| **`workstation`** | Physical | Dedicated GPU Worker | NVIDIA GPU Operator (RTX 4070 Ti), Media Stack Runtime |
| **`terramaster`** | SAN / NAS | Storage Target Portal | 14TB NFS Media Pool, iSCSI Block LUNs for DB/Application State |
| **OPNsense Gateway** | Virtual (KubeVirt) | Virtual Firewall & Router | Default Gateway, NAT Routing, Local DNS Resolver, Firewall ACLs |
| **Active Directory DC** | Virtual (KubeVirt) | Windows Server 2025 | Domain Controller (`lambertlab.us`), DNS, Automated WinRM Management |
| **Tailscale Ingress** | Edge Mesh | Edge Routing | Multi-A DNS Round-Robin across physical cluster nodes |

---

## 📂 Repository Structure

```
.
├── kubernetes/                  # Declarative Kubernetes Manifests & GitOps
│   ├── apps/                    # ArgoCD Root Application & Application CRDs
│   ├── network/nmstate/         # Cluster-wide NMState VXLAN & Bridge Policies
│   ├── vms/                     # KubeVirt VM Definitions (OPNsense, Domain Controller)
│   ├── media/                   # Jellyfin, Radarr, Sonarr, Prowlarr
│   ├── observability/           # Homarr, Ntfy
│   └── security/                # HashiCorp Vault, External Secrets
├── docker/                      # Standalone Docker Host Configurations (Terraform)
│   ├── workstation/             # Workstation Docker services (Jellyfin, Tdarr, ELK)
│   ├── optiplex/                # Optiplex Docker services
│   └── lenovo/                  # Lenovo ThinkCentre Docker services
├── active_directory/           # Declarative Active Directory Module (OUs, Groups, Users, SvcAccts)
├── cloudflare.tf                # Cloudflare Wildcard DNS Automation
├── tailscale.tf                 # Tailscale Device & Ingress Data Sources
├── providers.tf                 # Terraform Providers (AD, Docker, Vault, Tailscale, Cloudflare)
├── vault.tf                     # HashiCorp Vault Secret Mapping
└── variables.tf                 # Input Variables & Environment Constants
```

---

## 📝 Recent Accomplishments

- [x] **Cluster-Wide Multicast VXLAN Overlay (KubeVirt L2 Networking)**: Engineered a multi-node Layer 2 network fabric using Kubernetes NMState (`policy-br-lab0.yaml`) with multicast VXLAN bonded to `br-lab0` across all bare-metal nodes (`lenovo`, `optiplex`, `opti74`, `workstation`), enabling seamless cross-node Layer 2 VM connectivity for KubeVirt workloads without physical switch trunking.
- [x] **OPNsense Virtual Gateway & Sophos Decommissioning**: Deployed virtualized OPNsense on KubeVirt, successfully replacing the legacy Sophos Firewall. Configured WAN/LAN SNAT and DNAT routing policies, restoring full outbound internet connectivity and DNS resolution to the virtualized Windows Server Domain Controller.
- [x] **Secure WinRM Ingress & Active Directory IaC Automation**: Engineered an end-to-end HTTPS WinRM ingress pathway (`winrm.lambertlab.us`) through Traefik and OPNsense port forwarding with symmetric return-path SNAT, establishing declarative Active Directory management via Terraform (`hashicorp/ad`) for OUs, security groups, users, and service accounts.
- [x] **Workstation Workload Cleanup & Ollama Decommissioning**: Safely decommissioned the standalone Ollama container, reclaimed ~8.5 GB of container images and ~9.8 GB of model storage from `workstation`, and fully reconciled the deletion across Terraform state.
- [x] **Microsoft Entra ID (Azure AD) OIDC & RBAC Authentication**: Configured enterprise-grade OpenID Connect (OIDC) authentication on the K3s API server (`kube-apiserver`) backed by Microsoft Entra ID. Upgraded app token issuance to modern v2 access tokens (`requestedAccessTokenVersion: 2`), mapped security groups directly to `cluster-admin` via `ClusterRoleBinding`, and standardized workstation authentication using `Azure/kubelogin` interactive PKCE without requiring persistent client secrets.
- [x] **Ingress Client IP Preservation & Tailscale DNS Round-Robin**: Diagnosed and resolved source IP masking (SNAT to flannel overlay network) previously introduced by the Tailscale Operator L3 VIP. Re-architected edge ingress to multi-A Cloudflare DNS round-robin (`*.lambertlab.us`) directly across physical nodes' Tailscale interfaces via Terraform (`tailscale.tf` and `cloudflare.tf`), preserving real remote client IPs for Traefik security middleware allowlists and Jellyfin streaming logs.
- [x] **3-Node High-Availability Control Plane (Embedded etcd)**: Promoted `optiplex` and `opti74` to control-plane servers with embedded etcd (`cluster-init`), establishing a true 3-node Raft quorum across `lenovo`, `optiplex`, and `opti74` for uninterrupted multi-node master failover.
- [x] **Active Directory LDAPS Integration & OPNsense RBAC**: Integrated virtualized OPNsense with Active Directory over secure LDAPS (`636/TCP`) using internal Root CA trust and Unbound DNS host overrides. Declaratively provisioned the `OPNsense-Admins` security group and membership via Terraform (`hashicorp/ad`), establishing role-based access control and automated user group synchronization for firewall administration.

---

## 🚀 Active Roadmap

- [ ] **ArgoCD Microsoft Entra ID (Azure AD) OIDC SSO**: Integrate ArgoCD authentication with Microsoft Entra ID using OpenID Connect (OIDC) and map enterprise security groups to declarative ArgoCD RBAC roles.
- [ ] **Clientless Remote Desktop Gateway (Apache Guacamole)**: Deploy a secure web-based remote desktop gateway (Apache Guacamole) to facilitate browser-based RDP and SSH access into KubeVirt VMs without exposing management ports directly.
- [ ] **Active Directory Domain Joins & DNS Integration**: Automate domain joining for homelab Windows/Linux clients and integrate AD DNS forwarding with Pi-hole and OPNsense.
- [ ] **Transcoding Offload (Tdarr)**: Transition Tdarr distributed compute nodes directly into Kubernetes worker nodes.
- [ ] **Storage Tuning**: Benchmark and optimize NFS and iSCSI mount parameters for high-concurrency media streaming and VM hosting.


