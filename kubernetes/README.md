# Kubernetes GitOps Topology

This directory contains the declarative state for the Homelab Kubernetes (K3s) cluster. It is structured around a domain-driven GitOps topology, completely managed by ArgoCD (`root-apps`).

## 📂 Directory Structure

The cluster state is categorized into the following core domains:

*   **`infrastructure/`**: Core cluster networking, storage providers, and fundamental controllers (e.g., Traefik, Longhorn, Multus, KubeVirt).
*   **`observability/`**: The Elastic Agent DaemonSet, Prometheus stack, and logging pipelines (shipping to ELK).
*   **`security/`**: Identity and access management, SSO proxies (OAuth2-Proxy), and secret operators.
*   **`config/`**: Cluster-wide configurations, root certificates, and global ConfigMaps/Secrets.
*   **`vms/`**: Declarative KubeVirt VirtualMachines (e.g., `dc01-ad`, `win11`).
*   **`gaming/`**: Game servers and streaming workloads.
*   **`media/`**: Self-hosted media and automation stacks.
*   **`apps/`**: General-purpose workloads and dashboards.

## 🌊 ArgoCD Sync Waves (1–5)

To ensure that dependencies are met during a cluster bootstrap or disaster recovery, ArgoCD manages applications in strictly defined Sync Waves:

1.  **Wave 1 (Storage & Networking):** Longhorn, Traefik, cert-manager, Multus.
2.  **Wave 2 (Security & Identity):** OAuth2-Proxy, Vault injectors.
3.  **Wave 3 (Observability):** Elastic Agents, Prometheus.
4.  **Wave 4 (Core Services & VMs):** KubeVirt operator, `dc01` Active Directory, Traefik middlewares.
5.  **Wave 5 (User Apps & Media):** Standard workloads, dashboards, and media servers.

## 📜 Manifest Conventions

To maintain uniformity across domains, all applications generally follow this standardized file structure within their respective directories:

*   `deployment.yaml` / `daemonset.yaml`
*   `service.yaml`
*   `ingress.yaml`
*   `configmap.yaml` / `secret.yaml`
*   `pvc.yaml` / `storage.yaml`
*   `virtualmachine.yaml` (For KubeVirt resources)

*Note: All manifests must pass `kubeconform` OpenAPI schema validation before being merged into the `main` branch.*
