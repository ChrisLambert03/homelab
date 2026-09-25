# Service Catalog: Core Infrastructure & Networking

This section details the foundational control plane components, software-defined networking fabrics, storage drivers, and hypervisor operators supporting the **LambertLab** cluster.

---

## 🛠️ Workload Directory

### 1. ArgoCD High Availability (HA)
* **Namespace:** `argocd`
* **Sync Wave:** `Wave 2` (AppProjects in `Wave 0`)
* **Ingress Endpoint:** `https://argocd.lambertlab.us`
* **Architectural Role:** GitOps continuous delivery engine. Reconciles cluster state against `origin/main` across deterministic synchronization waves.
* **Key Configuration:**
  * Multi-replica application controller and Redis Sentinel high availability.
  * Integration with Microsoft Entra ID OIDC for admin SSO.
  * Default-deny RBAC policy (`policy.default: role:''`) preventing unauthorized view access.
  * Traefik IngressRoute with custom internal `ServersTransport` supporting insecure backend transport.

---

### 2. Traefik Edge Ingress Controller
* **Namespace:** `kube-system`
* **Management:** Native K3s Ingress Controller
* **Endpoints:** Ports 80 (HTTP redirect), 443 (HTTPS termination)
* **Architectural Role:** Cluster edge reverse proxy terminating external client TLS and enforcing security middlewares.
* **Key Configuration:**
  * Wildcard TLSStore configured in `kube-system` referencing `wildcard-lambertlab-us-tls`.
  * Security middlewares: `default-https-redirect` and `default-admin-only-access` restricting administrative dashboards.
  * Direct Tailscale multi-A round-robin ingress preserving remote client source IPs without intermediate SNAT.

---

### 3. Cert-Manager
* **Namespace:** `cert-manager`
* **Version:** Helm `v1.21.2`
* **Sync Wave:** `Wave 1`
* **Architectural Role:** Automated TLS x509 certificate management.
* **Key Configuration:**
  * `ClusterIssuer` utilizing Let's Encrypt ACME with Cloudflare DNS-01 API challenges.
  * Issues wildcard certificate `*.lambertlab.us` stored in `kube-system`.
  * Cloudflare API tokens stored in HashiCorp Vault and synchronized via External Secrets Operator.

---

### 4. NMState Operator & Node Network Configuration Policies
* **Namespace:** `nmstate`
* **Version:** Kubernetes-NMState Operator
* **Sync Waves:** Operator in `Wave 1`, Policies in `Wave 2`
* **Architectural Role:** Declarative host-level Linux network state manager.
* **Key Configuration:**
  * Configures multi-node multicast VXLAN bridge `br-lab0` across all cluster nodes.
  * Underlay interface `vxlan-lab` bound to VNI 100 on multicast group `239.1.1.1:4789`.
  * Static gateway IP assignment per host: `10.10.0.2` (`lenovo`), `10.10.0.3` (`optiplex`), `10.10.0.4` (`opti74`), `10.10.0.5` (`workstation`).

---

### 5. Multus CNI (Thick CNI DaemonSet)
* **Namespace:** `kube-system`
* **Sync Wave:** `Wave 1`
* **Architectural Role:** Multi-network interface plugin enabling pods and VMs to attach directly to multiple network fabrics.
* **Key Configuration:**
  * `NetworkAttachmentDefinition` named `lab-lan-bridge` mapping directly to host bridge `br-lab0`.
  * Configured with `"hairpinMode": false` to prevent IPv6 Duplicate Address Detection (DAD) reflection loops.
  * Provides Apache Guacamole and KubeVirt VMs with direct Layer 2 connectivity (`10.10.0.0/24`).

---

### 6. CoreDNS Active Directory Conditional Forwarder
* **Namespace:** `kube-system`
* **Sync Wave:** `Wave 2`
* **Architectural Role:** In-cluster DNS resolver providing transparent Active Directory hostname resolution.
* **Key Configuration:**
  * Configured via `kubernetes/config/coredns-custom.yaml`.
  * Conditional zone forwarder for `ad.lambertlab.us:53` pointing to DC01 (`10.10.0.10`).
  * Enforces active health checking: `health_check 5s` and `max_fails 2`, failing fast when DC01 reboots to eliminate 30+ second application UDP lookup timeouts.

---

### 7. Tailscale Operator & Mesh Gateway
* **Namespace:** `tailscale`
* **Sync Wave:** `Wave 1`
* **Architectural Role:** Zero-trust WireGuard mesh overlay networking.
* **Key Configuration:**
  * Enables remote access without open public firewall ports.
  * High-availability subnet router running on `optiplex` advertising both the primary physical LAN and VXLAN overlay (`10.10.0.0/24`).
  * Automated DNS automation via Terraform Cloudflare provider referencing Tailscale node IPs.

---

### 8. NVIDIA GPU Operator
* **Namespace:** `gpu-operator`
* **Sync Wave:** `Wave 1`
* **Architectural Role:** Automates management of NVIDIA software components on GPU worker nodes (`workstation`).
* **Key Configuration:**
  * Probes and provisions NVIDIA drivers, Container Toolkit, and Kubernetes device plugins for the host **RTX A4500 (20 GB VRAM)**.
  * Exposes `nvidia.com/gpu` schedulable resources for hardware-accelerated transcoding (Jellyfin, Tdarr).

---

### 9. Longhorn Distributed Block Storage
* **Namespace:** `longhorn-system`
* **Sync Wave:** `Wave 1`
* **Ingress Endpoint:** `https://longhorn.lambertlab.us`
* **Architectural Role:** Highly available, distributed cloud-native block storage.
* **Key Configuration:**
  * Synchronous block replication (2x–3x) across physical node SSDs/NVMes.
  * Custom StorageClass `longhorn-retain` with `reclaimPolicy: Retain` protecting databases and stateful volume claims from accidental deletion.
  * Automated snapshot scheduling and volume backup integration.

---

### 10. KubeVirt Operator & Containerized Data Importer (CDI)
* **Namespaces:** `kubevirt`, `cdi`
* **Versions:** KubeVirt `v1.9.0`, CDI `v1.66.0`
* **Sync Wave:** `Wave 1`
* **Ingress Endpoint:** `https://cdi.lambertlab.us` (CDI uploadproxy)
* **Architectural Role:** Bare-metal virtualization management and virtual disk ingestion engine.
* **Key Configuration:**
  * Native virtualization running on Linux KVM/QEMU hypervisor.
  * Facilitates live VM lifecycle operations (`virtctl`).
  * Traefik custom `ServersTransport` proxying `cdi-uploadproxy` with certificate validation bypass.

---

### 11. TerraMaster TOS Web Portal
* **Namespace:** `external` (Managed via `kubernetes/apps/external-services.yaml`)
* **Sync Wave:** `Wave 2`
* **Ingress Endpoint:** `https://nas.lambertlab.us`
* **Backend Target:** Port 8181 on `san.lambertlab.us` via Kubernetes Service & EndpointSlice
* **Architectural Role:** Centralized storage appliance operating system web management console.
* **Key Configuration:**
  * Traefik Ingress with automatic wildcard TLS termination (`*.lambertlab.us`).
  * Protected by the `default-admin-only-access` Traefik middleware, restricting appliance access to administrative Tailscale clients.
  * Enables secure browser management of iSCSI target LUNs, NFS pools, and hardware health over HTTPS.
