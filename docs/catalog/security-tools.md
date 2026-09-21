# Service Catalog: Security & Productivity Tools

This section documents secrets orchestration, centralized Security Information and Event Management (SIEM) observability, developer environments, homelab dashboards, and management utilities supporting **LambertLab**.

---

## 🔒 Workload Directory

### 1. HashiCorp Vault
* **Namespace:** `security`
* **AppProject:** `security`
* **Sync Wave:** `Wave 2`
* **Ingress Endpoint:** `https://vault.lambertlab.us`
* **Architectural Role:** Centralized cryptographic secrets engine and identity broker.
* **Storage Backend:** 10 GB distributed Longhorn block storage with `longhorn-retain` StorageClass.
* **Key Configuration:**
  * Stores Cloudflare API tokens, Tailscale authentication keys, database passwords, and Active Directory service account credentials.
  * Native Kubernetes authentication engine granting cluster pods time-limited, scoped tokens based on ServiceAccounts.

---

### 2. External Secrets Operator (ESO)
* **Namespace:** `security`
* **Version:** Helm `v2.9.0`
* **Sync Wave:** `Wave 2`
* **Architectural Role:** Kubernetes operator dynamically synchronizing external secret backends into native Kubernetes Secret objects.
* **Key Configuration:**
  * Configures `ClusterSecretStore` pointing directly to HashiCorp Vault.
  * Eliminates plaintext secrets from Git repositories while allowing applications to consume standard Kubernetes secrets declaratively.

---

### 3. Centralized ELK Stack (Elasticsearch, Logstash, Kibana)
* **Host Environment:** `workstation` (Docker Engine managed via Terraform `docker/workstation/elk-stack.tf`)
* **Ingress Endpoint:** `https://kibana.lambertlab.us` (Internal ES on `:9200`, Logstash on `:12201` GELF)
* **Architectural Role:** Enterprise Security Information and Event Management (SIEM) and log analytics pipeline.
* **Storage Backend:** Dedicated local NVMe storage (`/usr/share/elasticsearch/data`) on `workstation`.
* **Key Configuration:**
  * Single-node cluster enforcing `number_of_replicas: 0` across templates to maintain solid green health and prevent Index Lifecycle Management (ILM) stalls.
  * Docker GELF input on port 12201 (UDP/TCP) streaming container logs over Tailscale from all physical nodes.
  * Logstash mutate filter recording exact receipt timestamps (`received_at => "%{@timestamp}"`).
  * Kibana tuned with `NODE_OPTIONS=--max-old-space-size=2048` to prevent V8 JavaScript heap exhaustion during complex visual log queries.
  * Traefik Ingress with `default-admin-only-access` security middleware.

---

### 4. Homarr Dashboard
* **Namespace:** `observability`
* **AppProject:** `observability`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://homarr.lambertlab.us`
* **Architectural Role:** Customizable homelab landing portal and application launcher.
* **Key Configuration:**
  * Displays real-time operational status and ping health across all cluster services.
  * Secured via Traefik HTTPS termination using the cluster-wide default TLSStore.

---

### 5. Ntfy Push Notification Service
* **Namespace:** `observability`
* **AppProject:** `observability`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://ntfy.lambertlab.us`
* **Architectural Role:** Lightweight, HTTP-based publish-subscribe push notification service.
* **Storage Backend:** Persistent volume backed by Longhorn with `longhorn-retain` policy.
* **Key Configuration:**
  * Configured with `ignoreDifferences` on StatefulSet `volumeClaimTemplates` to prevent ArgoCD GitOps drift.
  * Dispatches real-time alerts from backup scripts, CI/CD pipelines, and health monitors directly to mobile devices.

---

### 6. Beszel Hub & Distributed Agents
* **Host Environments:** Beszel Hub on `lenovo` (Docker), Beszel Agents on `lenovo`, `optiplex`, and `workstation` (Docker)
* **Management Engine:** Terraform Docker provider (`docker/lenovo/app-beszel.tf`, `app-beszel-agent.tf`)
* **Ingress Endpoint:** `https://beszel.lambertlab.us`
* **Architectural Role:** Ultra-lightweight resource telemetry, CPU/RAM utilization tracking, and hardware monitoring.
* **Key Configuration:**
  * Hub runs natively in Docker on `lenovo` with persistent local host storage (`/home/chris/services/beszel/beszel_data`), deliberately kept outside Kubernetes for low overhead.
  * Distributed `beszel-agent` containers mount `/var/run/docker.sock` and `/dev/dri` to report CPU, memory, per-container metrics, disk I/O, and GPU utilization without the resource footprint of Prometheus exporters.

---

### 7. External Services Suite (EndpointSlice Integrations)
A collection of standalone node services, containers, and network appliances mapped into Kubernetes via ArgoCD (`kubernetes/apps/external-services.yaml`):

| Service | Host / Address | Ingress Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Pi-hole** | Docker / Host | `https://pihole.lambertlab.us` | Network-wide DNS sinkhole, local domain resolution, and tracking ad-blocker. |
| **Portainer** | `optiplex` | `https://portainer.lambertlab.us` | Graphical management web interface for standalone Docker hosts and containers. |
| **Cockpit** | `lenovo` | `https://cockpit.lambertlab.us` | Web-based Linux system administration, storage controller monitoring, and terminal access. |
| **Code-Server** | `lenovo` | `https://code.lambertlab.us` | Browser-based Visual Studio Code IDE environment running directly on the cluster manager. |
| **Firefox Web** | `opti74` | `https://firefox.lambertlab.us` | Isolated browser sandbox running on port 4000 for secure, disposable web browsing and testing. |
| **Redis & RedisInsight** | `workstation` | `https://redisinsight.lambertlab.us` | In-memory key-value caching layer paired with a real-time memory visualizer GUI. |
| **RetroArch Web** | `workstation` | `https://retroarch.lambertlab.us` | Cloud-hosted browser-based emulator gaming frontend. |
