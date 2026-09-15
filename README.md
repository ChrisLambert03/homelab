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

- [x] **Cluster-Wide Multicast VXLAN Overlay (KubeVirt L2 Networking)**: Engineered a multi-node Layer 2 network fabric using Kubernetes NMState with multicast VXLAN bridging across bare-metal nodes, enabling seamless cross-node virtual machine networking for KubeVirt workloads without physical switch VLAN trunking.
- [x] **OPNsense Virtual Gateway & Sophos Decommissioning**: Deployed a virtualized OPNsense firewall on KubeVirt, successfully replacing the legacy edge firewall. Configured routing policies and NAT rules, establishing secure outbound connectivity and DNS resolution for virtualized domain infrastructure.
- [x] **Secure WinRM Ingress & Active Directory IaC Automation**: Engineered an end-to-end HTTPS WinRM ingress pathway through Traefik and OPNsense, establishing declarative Infrastructure as Code (IaC) management for Active Directory via Terraform for automated provisioning of organizational units, security groups, users, and service accounts.
- [x] **Workstation Workload Cleanup & Resource Optimization**: Safely decommissioned standalone local AI workloads, reclaimed significant disk space from container image layers, and fully reconciled infrastructure state across Terraform.
- [x] **Microsoft Entra ID (Azure AD) OIDC & RBAC Authentication**: Configured enterprise OpenID Connect (OIDC) authentication on the Kubernetes API server backed by Microsoft Entra ID. Mapped enterprise security groups to administrative cluster roles and standardized workstation authentication using Azure `kubelogin` interactive PKCE without requiring persistent client secrets.
- [x] **Ingress Client IP Preservation & Tailscale DNS Round-Robin**: Re-architected edge ingress to multi-node Cloudflare DNS round-robin for `lambertlab.us` across physical Tailscale interfaces via Terraform, eliminating overlay source-NAT masking and preserving real client IPs for Traefik security middleware and access logs.
- [x] **3-Node High-Availability Control Plane (Embedded etcd)**: Promoted worker nodes to control-plane servers with embedded etcd, establishing a resilient 3-node Raft quorum across physical hardware for uninterrupted high availability and automated master failover.
- [x] **Active Directory LDAPS Integration & OPNsense RBAC**: Integrated the virtualized OPNsense firewall with Active Directory over secure LDAPS using internal certificate authority trust. Declaratively provisioned administrator security groups via Terraform, establishing directory-backed role-based access control (RBAC) and automated privilege management.
- [x] **Clientless Remote Desktop Gateway (Apache Guacamole & Multi-Protocol Auth)**: Deployed an enterprise HTML5 clientless remote desktop gateway (`guacamole.lambertlab.us`) on Kubernetes backed by persistent storage on Longhorn. Integrated dual-protocol authentication combining Microsoft Entra ID OIDC SSO with Active Directory LDAPS, enforced Traefik edge ingress with real-IP preservation, and tuned container resource limits to guarantee smooth remote desktop rendering while protecting host workstation compute.
- [x] **Hybrid Identity Federation (Microsoft Entra Cloud Sync & PHS)**: Established bidirectional hybrid identity federation between on-premises Active Directory (`ad.lambertlab.us`) and Microsoft Entra ID. Automated custom domain verification for `lambertlab.us` via Cloudflare DNS in Terraform, aligned directory UPN suffixes, and deployed the Entra Cloud Sync agent on Windows Server using a Group Managed Service Account (gMSA) to synchronize users, security groups, and password hashes across on-premises and cloud.

---

## 🚀 Active Roadmap

### Enterprise Identity & Edge Access
- [ ] **Zero-Trust Edge SSO (OAuth2-Proxy & Traefik ForwardAuth)**: Deploy an identity-aware proxy integrated with Microsoft Entra ID and Traefik ForwardAuth to enforce centralized multi-factor authentication and group-based access control across internal dashboards.
- [ ] **Active Directory DNS Integration & Windows Domain Joins**: Integrate Active Directory DNS forwarding with Pi-hole and OPNsense, and automate domain joins for Windows virtual machines and management workstations.

### Platform Engineering & SRE
- [ ] **Cluster-Wide Workload Resource Quotas & QoS**: Establish baseline CPU and memory requests and limits across unconstrained workloads to enforce Kubernetes Quality of Service (QoS) and protect host compute.
- [ ] **Automated Disaster Recovery & Cold-Start Rebuild ("Nuke & Pave")**: Implement scheduled automated cluster state and persistent volume backups using Velero to offsite storage, paired with an idempotent bootstrap script to validate bare-metal disaster recovery.
- [ ] **SRE Observability & SLO Dashboards**: Deploy Prometheus Operator, Alertmanager, and Grafana to define Service Level Objectives (SLOs), track error budgets and latency metrics, and route automated alerts.
- [ ] **Centralized Log Shipping & SIEM (ELK Stack)**: Ingest Kubernetes container logs, Active Directory security event logs, and OPNsense firewall telemetry into Elasticsearch on `workstation` for unified log analytics and automated threat detection in Kibana.
- [ ] **Storage Performance Tuning**: Benchmark and optimize NFS and iSCSI mount parameters for high-concurrency media streaming and virtual machine hosting.

### DevSecOps & Governance
- [ ] **Declarative Secrets Orchestration (External Secrets Operator & HashiCorp Vault)**: Implement cluster-wide secret stores to automatically synchronize credentials from HashiCorp Vault into native Kubernetes secrets across all namespaces.
- [ ] **GitOps Policy Gatekeeping (Policy-as-Code)**: Implement automated shift-left validation in CI pipelines using schema linters and Policy-as-Code to enforce security constraints prior to GitOps reconciliation.
- [ ] **Zero-Trust NetworkPolicies (Namespace Firewalls)**: Enforce declarative Kubernetes NetworkPolicies to isolate sensitive namespaces and prevent lateral movement across workloads.

### Virtualization & Workloads
- [ ] **Persistent Windows 11 KubeVirt VM**: Provision a dedicated Windows 11 enterprise desktop VM on bare-metal hardware backed by dedicated iSCSI block storage.



