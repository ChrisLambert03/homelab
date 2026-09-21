# Homelab Automation Infrastructure

<div align="center">

[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s_v1.36-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![KubeVirt](https://img.shields.io/badge/KubeVirt-Virtualization-purple?style=for-the-badge&logo=redhatopenshift&logoColor=white)](https://kubevirt.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps_HA-EF6036?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io)
[![OPNsense](https://img.shields.io/badge/OPNsense-Gateway-D94A38?style=for-the-badge&logo=opnsense&logoColor=white)](https://opnsense.org)
[![Active Directory](https://img.shields.io/badge/Active_Directory-Windows_Server_2025-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows-server)
[![Entra ID](https://img.shields.io/badge/Entra_ID-OIDC_SSO-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/en-us/entra/identity/)
[![Guacamole](https://img.shields.io/badge/Guacamole-Remote_Desktop-5382A1?style=for-the-badge&logo=apache&logoColor=white)](https://guacamole.apache.org)
[![ELK Stack](https://img.shields.io/badge/ELK_Stack-Security_Information_%26_Event_Management-005571?style=for-the-badge&logo=elastic&logoColor=white)](https://www.elastic.co)
[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Vault](https://img.shields.io/badge/Vault-Secured-000000?style=for-the-badge&logo=vault&logoColor=white)](https://www.vaultproject.io)

</div>

---

## ⚡ Overview

A production-level hybrid infrastructure bridging bare-metal physical compute, cloud-native virtualization via **KubeVirt**, and dual-directory identity across **Active Directory** and **Microsoft Entra ID**. The environment is fully automated using **GitOps (ArgoCD HA)** and **Infrastructure as Code (Terraform)**, featuring zero-touch Windows 11 VM provisioning, line-rate iSCSI SAN storage, and clientless remote desktop access via **Apache Guacamole** directly bridged to a software-defined L2 VXLAN network fabric.

---

## 🛠️ Key Technical Highlights

* **Automated VM Lifecycle & Sysprep Specialization**: KubeVirt runs virtualized core infrastructure (OPNsense firewall, Windows Server 2025 DC, and Windows 11 Enterprise). Reference VM templates are generalized with Microsoft Sysprep and paired with declarative `unattend.xml` answer files mounted via Kubernetes secrets for dynamic machine naming (`WIN-*`), automated regional bypass, least-privilege domain joins (`svc_domainjoin`), and direct line-rate iSCSI flashing via `qemu-img` (`libiscsi`). *(See [unattend.xml.example](kubernetes/vms/win11/unattend.xml.example) for the answer file).*
* **Active Directory CoreDNS Conditional Forwarding**: Engineered cluster-wide domain resolution routing `*.ad.lambertlab.us` from Kubernetes workloads directly to the Domain Controller (`10.10.0.10`). Combined with static IP assignment on `br-lab0` (`10.10.0.2`–`.5`) and K3s Flannel IP masquerading, pods dynamically resolve domain-joined VMs (`win11-01.ad.lambertlab.us`) and services with sub-millisecond latency and zero OPNsense NAT port-forwards.
* **High-Availability GitOps & IaC Engine**: Multi-replica ArgoCD (HA) with Redis Sentinel and controller sharding reconciles cluster state with strict default-deny RBAC across deterministic sync waves. Terraform drives Cloudflare DNS, Tailscale mesh devices, Docker host workloads, and Active Directory objects.
* **Hybrid Identity & Clientless Remote Access**: Bidirectional identity federation between on-premises Active Directory (`ad.lambertlab.us`) and Microsoft Entra ID using Entra Cloud Sync under a gMSA. Clientless HTML5 remote desktop gateway (Apache Guacamole) integrates Entra ID OIDC SSO with Active Directory LDAPS (`dc01.ad.lambertlab.us`) and native Multus L2 VXLAN pod networking for wire-speed VM access.
* **Software-Defined Networking & Storage**: Cluster-wide multicast VXLAN overlay (`br-lab0` via NMState) provides seamless Layer 2 VM connectivity across physical nodes without switch VLAN trunking, backed by a TerraMaster SAN (F4-425 Plus) delivering dedicated iSCSI block LUNs and NFS pools alongside distributed Longhorn storage.
* **Security Information and Event Management (SIEM) & Telemetry (ELK Stack)**: A production-level observability and security operations pipeline hosted on `workstation` high-speed NVMe storage (Elasticsearch 8.x, Logstash, Kibana). Aggregates cluster-wide Kubernetes pod logs, cross-node Docker container logs via GELF over Tailscale, Windows Security Event logs (Active Directory Kerberos/NTLM authentication, privilege escalation, logon tracking), and OPNsense firewall packet drops for unified threat detection with single-node Index Lifecycle Management (ILM) retention policies.

---

## 🖥️ Topology & Technical Architecture

The cluster is anchored by a high-availability 3-node K3s control plane (**`lenovo`**, **`optiplex`**, **`opti74`**) running an embedded `etcd` Raft quorum for seamless master failover and zero-downtime operations. A dedicated bare-metal GPU worker (**`workstation`**) powers compute-heavy containerized workloads, hardware transcoding (NVIDIA RTX 4070 Ti), and hosts the centralized **ELK Security Information and Event Management (SIEM) stack** (Elasticsearch, Logstash, Kibana) on local high-speed NVMe storage for rapid Kubernetes pod and container log aggregation, infrastructure telemetry, and security indexing. Perimeter routing and firewall policies are handled by a virtualized **OPNsense** instance on KubeVirt, which bridges physical node interfaces to an in-cluster multicast VXLAN overlay network (`10.10.0.0/24`) connecting the virtual machines (**DC01** Domain Controller, **`win11`** workstations). Physical hosts maintain static gateway interfaces on `br-lab0` (`10.10.0.2`–`.5`), enabling CoreDNS conditional forwarding directly to DC01 for transparent cluster-wide Active Directory hostname resolution. Storage is centralized on a **TerraMaster F4-425 Plus SAN**, supplying dedicated raw iSCSI block LUNs for low-latency VM root disks and database state alongside a 14TB NFS pool for bulk data, complemented by distributed **Longhorn** block storage across nodes. External ingress is secured via a **Tailscale** direct mesh and **Cloudflare** round-robin DNS, routing client traffic directly into **Traefik** while preserving client source IPs.

---

## 📂 Repository Structure

```text
.
├── kubernetes/                  # GitOps Manifests & Helm Configurations
│   ├── apps/                    # ArgoCD Root App & Sync Waves (0–3)
│   ├── config/                  # Cluster Config (CoreDNS AD Forwarding, RBAC, Certs)
│   ├── network/nmstate/         # Multi-Node NMState VXLAN Overlay & Bridges
│   ├── vms/                     # KubeVirt Definitions (OPNsense, DC01, Win11 Sysprep)
│   ├── guacamole/               # Apache Guacamole with Multus VXLAN Bridge & LDAPS
│   └── security/                # HashiCorp Vault & External Secrets Operator
├── docker/                      # Standalone Host Engine Services (Workstation, Optiplex)
│   └── workstation/elk-stack.tf # Docker ELK Stack, Logstash Pipelines & ILM Policies
├── active_directory/           # Terraform AD Module (OUs, Groups, Users, SvcAccts)
├── cloudflare.tf                # Cloudflare DNS Automation
├── tailscale.tf                 # Tailscale Mesh Ingress Configuration
└── vault.tf                     # HashiCorp Vault Secret Orchestration
```

---

## 🎯 Active Focus

- [ ] **Zero-Trust ForwardAuth**: Integrate Traefik ForwardAuth with Microsoft Entra ID for centralized SSO and MFA across internal services.
- [ ] **Security Information and Event Management (SIEM) & Centralized Log Analytics (ELK Stack)**:
  - Aggregate and index Kubernetes pod logs across all cluster namespaces and host container logs via Docker GELF over Tailscale into Logstash.
  - Stream Windows Security Event logs (Event IDs: 4624 logon, 4625 failed auth, 4672 admin privileges) from DC01 and Win11 via Winlogbeat.
  - Forward OPNsense firewall state tables and packet drop telemetry via syslog to Logstash for real-time threat analysis and geo-tagging.
  - Implement automated hot-warm-cold Index Lifecycle Management (ILM) retention policies and build unified Kibana security monitoring dashboards.
- [ ] **Documentation as Code & Architectural Transparency**:
  - Deploy a centralized, searchable documentation portal using **Material for MkDocs** covering disaster recovery runbooks, physical hardware topology, and storage tiers.
  - Automate parameter documentation for Helm chart releases (`values.yaml`) using **`helm-docs`** in CI to eliminate configuration drift.
  - Implement programmatic architecture and network diagrams using **`diagrams` (Python as Code)** to keep topology graphics continuously synchronized with cluster state.
  - Generate an automated inventory and service catalog covering all 30+ ArgoCD workloads and KubeVirt virtual machines.
