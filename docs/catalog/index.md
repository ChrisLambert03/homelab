# Application & Service Catalog

The **LambertLab** service catalog documents over 30 containerized workloads, virtual appliances, and infrastructure services running across the high-availability Kubernetes cluster and bare-metal Docker engines.

---

## 🧭 Catalog Architecture & Organization

Workloads are logically grouped into four functional categories:

1. [**Core Infrastructure & Networking**](infrastructure.md): The foundational control planes, GitOps engines, storage drivers, and ingress controllers powering the cluster.
2. [**Virtual Machines & Identity**](workstations-vms.md): Bare-metal virtualized Windows infrastructure, edge routing firewalls, and remote access gateways.
3. [**Media & Automation**](media-automation.md): High-throughput media streaming, GPU transcoding pipelines, and automated download indexing stacks.
4. [**Security & Productivity Tools**](security-tools.md): Centralized secrets management, Security Information and Event Management (SIEM) telemetry, homelab dashboards, and developer tool suites.

---

## 📊 Master Service Matrix

| Workload | Category | Environment / Namespace | Management Engine | Ingress / Endpoint | Storage Tier |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ArgoCD HA** | Infrastructure | `argocd` | ArgoCD Helm (Wave 2) | `argocd.lambertlab.us` | Stateless / In-Memory |
| **Traefik Ingress** | Infrastructure | `kube-system` | K3s Native / Helm | Ports 80, 443 (Edge) | Ephemeral |
| **Cert-Manager** | Infrastructure | `cert-manager` | ArgoCD Helm (Wave 1) | In-Cluster API | Ephemeral |
| **KubeVirt Operator** | Infrastructure | `kubevirt` | ArgoCD Manifest (Wave 1) | In-Cluster API | Ephemeral |
| **Containerized Data Importer (CDI)** | Infrastructure | `cdi` | ArgoCD Manifest (Wave 1) | `cdi.lambertlab.us` | Longhorn Scratch |
| **Longhorn** | Infrastructure | `longhorn-system` | ArgoCD Helm (Wave 1) | `longhorn.lambertlab.us` | Multi-Node SSD / NVMe |
| **NMState Operator** | Infrastructure | `nmstate` | ArgoCD OCI (Wave 1) | In-Cluster Host Net | Ephemeral |
| **Multus CNI** | Infrastructure | `kube-system` | ArgoCD Manifest (Wave 1) | Host CNI Plugins | Ephemeral |
| **CoreDNS Forwarder** | Infrastructure | `kube-system` | ArgoCD Manifest (Wave 2) | Port 53 (ClusterIP) | Ephemeral |
| **NVIDIA GPU Operator** | Infrastructure | `gpu-operator` | ArgoCD Helm (Wave 1) | `workstation` Host | Host Driver / Passthrough |
| **TerraMaster TOS** | Infrastructure | `external` / Appliance | EndpointSlice & Ingress | `nas.lambertlab.us` | Appliance OS |
| **Tailscale Operator & Subnet** | Infrastructure | `tailscale` | ArgoCD Helm / Host | `*.lambertlab.us` Mesh | Ephemeral |
| **DC01 Active Directory** | Virtualization | `vms` (KubeVirt) | ArgoCD Manifest (Wave 3) | `dc01.ad.lambertlab.us` | 80 GB SAN iSCSI LUN |
| **Windows 11 Workstation** | Virtualization | `vms` (KubeVirt) | ArgoCD Manifest (Wave 3) | `win11.ad.lambertlab.us` | 64 GB SAN iSCSI LUN |
| **OPNsense Firewall** | Virtualization | `vms` (KubeVirt) | ArgoCD Manifest (Wave 3) | `opnsense.lambertlab.us` | 40 GB SAN iSCSI LUN |
| **KubeVirt Manager** | Virtualization | `kubevirt-manager` | ArgoCD Helm (Wave 2) | `kubevirt-manager.lambertlab.us` | Ephemeral |
| **Apache Guacamole** | Remote Access | `guacamole` | ArgoCD Helm (Wave 2) | `guacamole.lambertlab.us` | 6 GB Longhorn PostgreSQL |
| **Jellyfin** | Media | `media` | ArgoCD Multi-Source (Wave 3) | `jellyfin.lambertlab.us` | Host NVMe (15Gi) + 14TB Bulk NFS |
| **Sonarr** | Media | `media` | ArgoCD Manifest (Wave 3) | `sonarr.lambertlab.us` | 20 GB SAN iSCSI LUN + Bulk NFS |
| **Radarr** | Media | `media` | ArgoCD Manifest (Wave 3) | `radarr.lambertlab.us` | 20 GB SAN iSCSI LUN + Bulk NFS |
| **Prowlarr** | Media | `media` | ArgoCD Manifest (Wave 3) | `prowlarr.lambertlab.us` | 2 GB SAN iSCSI LUN |
| **Tdarr (Transcoder)** | Media | `workstation` (Docker) | Terraform Docker | `tdarr.lambertlab.us` | 14TB TerraMaster NFS Pool |
| **Palworld Dedicated** | Gaming | `gaming` | ArgoCD Manifest (Wave 3) | Port 8211 UDP (`opti74`) | Longhorn Retained Volume (25Gi) |
| **HashiCorp Vault** | Security | `security` | ArgoCD Manifest (Wave 2) | `vault.lambertlab.us` | 1 GiB Longhorn Retained |
| **External Secrets Operator** | Security | `security` | ArgoCD Helm (Wave 2) | In-Cluster API | Ephemeral |
| **Elasticsearch 8.x** | SIEM / Logging | `workstation` (Docker) | Terraform Docker | Port 9200 (Internal) | Dedicated Local NVMe |
| **Logstash** | SIEM / Logging | `workstation` (Docker) | Terraform Docker | Port 12201 (GELF UDP/TCP) | Ephemeral Pipeline |
| **Kibana** | SIEM / Logging | `workstation` (Docker) | Terraform Docker | `kibana.lambertlab.us` | Ephemeral |
| **Elastic Agent** | SIEM / Logging | `kube-system` | ArgoCD Helm (Wave 5) | In-Cluster Host DaemonSet | Ephemeral DaemonSet |
| **Homarr Dashboard** | Observability | `observability` | ArgoCD Manifest (Wave 3) | `homarr.lambertlab.us` | Local Host Storage (`lenovo`) |
| **Ntfy Notifications** | Observability | `observability` | ArgoCD Manifest (Wave 3) | `ntfy.lambertlab.us` | Longhorn Retained Volume (1Gi) |
| **Beszel Hub & Agents** | Observability | `lenovo` (Hub) / Nodes | Terraform Docker | `beszel.lambertlab.us` | Local Docker Volume |
| **Pi-hole** | Security | `external` / Docker | EndpointSlice & Ingress | `pihole.lambertlab.us` | Local Docker Volume |
| **Portainer** | Management | `optiplex` (Docker) | Terraform Docker | `portainer.lambertlab.us` | Local Docker Volume |
| **Cockpit** | Management | `workstation` / Node | EndpointSlice & Ingress | `cockpit.lambertlab.us` | Host System |
| **Code-Server** | Developer Tools | `lenovo` / Node | EndpointSlice & Ingress | `code.lambertlab.us` | Host Filesystem |
| **Firefox Web Sandbox** | Developer Tools | `external` (`opti74`) | EndpointSlice & Ingress | `firefox.lambertlab.us` | Ephemeral Container |
