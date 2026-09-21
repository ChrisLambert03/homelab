# Service Catalog: Virtual Machines & Identity

This section documents the virtual machines, edge routing firewalls, and remote access gateways operating under **KubeVirt** and Kubernetes.

---

## 🖥️ Workload Directory

### 1. DC01: Active Directory Domain Controller
* **Namespace:** `vms` (KubeVirt `VirtualMachine`)
* **Operating System:** Windows Server 2025 Standard
* **Sync Wave:** `Wave 3`
* **Internal IP:** `10.10.0.10` (Static on `br-lab0`)
* **FQDN:** `dc01.ad.lambertlab.us`
* **Hardware Profile:** 4 vCPU, 8 GiB RAM, host-passthrough CPU topology.
* **Storage Backend:** Dedicated 80 GB raw iSCSI block LUN (`iqn.2026-09.us.lambertlab:dc01-disk`) on TerraMaster SAN.
* **Architectural Role:** Primary Domain Controller providing Active Directory Domain Services (AD DS), DNS, Kerberos authentication, and LDAPS (Port 636).
* **Key Configuration:**
  * Red Hat VirtIO paravirtualized SCSI storage (`viostor`) and network (`NetKVM`) drivers.
  * VirtIO USB tablet device for pixel-perfect VNC mouse coordination.
  * Hosts the **Microsoft Entra Cloud Sync Agent** running under `provAgentgMSA$` with Password Hash Sync (PHS) to Entra ID.
  * Internal Enterprise CA (`lambertlab-DC01-CA`) providing certificates for domain-joined services.

---

### 2. Windows 11 Enterprise Workstation (`win11`)
* **Namespace:** `vms` (KubeVirt `VirtualMachine`)
* **Operating System:** Windows 11 Enterprise LTSC
* **Sync Wave:** `Wave 3`
* **Internal IP:** `10.10.0.155` (Dynamic / DHCP on `br-lab0`)
* **FQDN:** `win11.ad.lambertlab.us`
* **Hardware Profile:** 4 vCPU, 8 GiB RAM, host-passthrough CPU topology.
* **Storage Backend:** Dedicated 64 GB raw iSCSI block LUN (`iqn.2026-09.us.lambertlab:win11-boot`) on TerraMaster SAN.
* **Architectural Role:** Domain-joined administrative workstation for centralized infrastructure management, Active Directory administration, and remote engineering.
* **Key Configuration:**
  * Hardware-enforced OVMF UEFI Secure Boot and persistent virtual TPM 2.0 (`swtpm`) backed by Longhorn storage.
  * Full KVM Hyper-V enlightened hypercall suite (`tlbflush`, `ipi`, `synictimer`, `frequencies`, `relaxed`, `vapic`, `spinlocks`).
  * Automated Sysprep specialization via declarative `unattend.xml` answer file mounted via Kubernetes Secret (`win11-unattend-secret`).
  * Dynamic machine naming (`WIN-*`) and automated domain join via restricted service account `svc_domainjoin`.

---

### 3. OPNsense Firewall & Routing Gateway
* **Namespace:** `vms` (KubeVirt `VirtualMachine`)
* **Operating System:** FreeBSD 14 / OPNsense
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://opnsense.lambertlab.us`
* **Hardware Profile:** 4 vCPU, 4 GiB RAM.
* **Storage Backend:** Distributed Longhorn block volume.
* **Architectural Role:** Virtualized edge perimeter router, NAT gateway, and security firewall.
* **Key Configuration:**
  * Multi-NIC topology bridging physical host interfaces to the software-defined `br-lab0` VXLAN fabric.
  * Internal hairpin routing directing `100.64.0.0/10` LAN queries to the Traefik Ingress Service ClusterIP (`10.43.204.125:443`).
  * Traefik Ingress with custom backend HTTPS serverstransport.

---

### 4. KubeVirt Manager Web UI
* **Namespace:** `kubevirt-manager`
* **Sync Wave:** `Wave 2`
* **Ingress Endpoint:** `https://kubevirt-manager.lambertlab.us`
* **Architectural Role:** Intuitive, web-based management graphical interface for KubeVirt virtual machines, disks, and network attachments.
* **Key Configuration:**
  * Traefik zero-buffering middleware (`traefik.ingress.kubernetes.io/buffering: maxrequestbodybytes: 0`) enabling low-latency WebSocket streaming for NoVNC and serial VM consoles.
  * Kubernetes `FlowSchema` configuration prioritizing API server requests from KubeVirt Manager to eliminate console throttling during heavy cluster load.

---

### 5. Apache Guacamole Gateway
* **Namespace:** `guacamole`
* **Sync Wave:** `Wave 2`
* **Ingress Endpoint:** `https://guacamole.lambertlab.us`
* **Architectural Role:** Clientless HTML5 remote desktop gateway providing browser-based RDP and SSH access.
* **Key Configuration:**
  * Multus CNI secondary interface `net1` assigned static IP `10.10.0.50/24` on `br-lab0` for direct wire-speed VM access.
  * InitContainer automated injection of internal Active Directory Root CA into Java truststore (`cacerts`).
  * Dual authentication chaining via `EXTENSION_PRIORITY: "*,openid"`, supporting Microsoft Entra ID OIDC SSO while preserving local `guacadmin` emergency recovery.
  * Backend PostgreSQL database running on Longhorn distributed storage with `longhorn-retain` policy.
  * `guacd` resource limit guardrail (`cpu: 2000m`) preventing thread pool exhaustion on 32-thread Xeon compute nodes.
