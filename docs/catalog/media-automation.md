# Service Catalog: Media & Automation

This section documents the automated media indexing, hardware-accelerated transcoding pipelines, streaming platforms, and dedicated game servers operating within the **LambertLab** ecosystem.

---

## 🎬 Workload Directory

### 1. Jellyfin Media Server
* **Namespace:** `media`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://jellyfin.lambertlab.us`
* **Architectural Role:** Privacy-focused, high-performance open-source media streaming server.
* **Storage Backend:** Persistent data on Longhorn; media libraries mounted via ReadWriteMany (RWX) NFS shares directly from the TerraMaster NAS 14TB pool (`/Volume1/data`).
* **Hardware Acceleration:**
  * Scheduled with node affinity targeting `workstation`.
  * Passes through the **NVIDIA RTX A4500 (20 GB VRAM)** via `nvidia.com/gpu: 1` resource requests.
  * Enables zero-overhead NVENC (hardware encoding) and NVDEC (hardware decoding) across 4K HDR HEVC/H.265 streams with tone-mapping.

---

### 2. Sonarr
* **Namespace:** `media`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://sonarr.lambertlab.us`
* **Architectural Role:** Automated TV series collection manager and download scheduler.
* **Key Configuration:**
  * Reconciles television series monitoring, season upgrades, and file renaming.
  * Integrates with Prowlarr for upstream indexer coordination.
  * Persistent volume claims bound to Longhorn storage for local application database; NFS mounts for media library organization.

---

### 3. Radarr
* **Namespace:** `media`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://radarr.lambertlab.us`
* **Architectural Role:** Automated movie collection manager and quality profile scheduler.
* **Key Configuration:**
  * Tracks release dates, monitors wanted films, and orchestrates automatic quality upgrades.
  * Configured with custom quality definitions and format scoring for optimal video/audio codec matching.
  * Shared NFS volume claims with Sonarr and Jellyfin for unified library management.

---

### 4. Prowlarr
* **Namespace:** `media`
* **Sync Wave:** `Wave 3`
* **Ingress Endpoint:** `https://prowlarr.lambertlab.us`
* **Architectural Role:** Centralized indexer proxy integrating Usenet and BitTorrent feeds.
* **Key Configuration:**
  * Manages and tests upstream tracker connections and rate limits.
  * Synchronizes indexers seamlessly across both Sonarr and Radarr via in-cluster API endpoints, eliminating redundant manual configuration.

---

### 5. Tdarr Transcoding Node
* **Host Environment:** `workstation` (Docker Engine managed via Terraform `docker/workstation/app-tdarr.tf`)
* **Sync Wave:** Standalone Host Engine
* **Ingress Endpoint:** `https://tdarr.lambertlab.us`
* **Architectural Role:** Distributed, automated media library transcoder and audio/video standardization pipeline.
* **Key Configuration:**
  * Mounts the host NVIDIA GPU device (`/dev/dri` and NVIDIA runtime) for batch transcoding video libraries to space-efficient AV1 or HEVC formats.
  * Directly accesses the high-throughput 14TB TerraMaster NFS pool for line-rate read/write processing.
  * Runs as a containerized worker communicating with the central Tdarr server coordinator.

---

### 6. Palworld Dedicated Game Server
* **Namespace:** `gaming`
* **AppProject:** `gaming`
* **Sync Wave:** `Wave 3`
* **Network Port:** Port 8211 UDP
* **Architectural Role:** Dedicated, high-performance multi-player game server.
* **Key Configuration:**
  * Pod pinned deterministically to `opti74` via `nodeSelector: kubernetes.io/hostname: opti74` to isolate gaming memory consumption from core manager workloads.
  * Backed by a retained Longhorn persistent volume claim (`palworld-data`) to guarantee player progression and world state survive cluster sync waves.
  * Configured with memory limits (`limits.memory: 12Gi`) and auto-restart policies to manage game server memory leaks.
