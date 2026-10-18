# Kubernetes GitOps Topology

This directory contains the declarative state for the Homelab Kubernetes (kubeadm) cluster. It is structured around a domain-driven GitOps topology, completely managed by ArgoCD (`root-apps`).

## 📂 Directory Structure

The cluster state is categorized into the following core domains:

*   **`infrastructure/`**: Core cluster networking, storage providers, and fundamental controllers (e.g., Traefik, Longhorn, Multus, KubeVirt).
*   **`observability/`**: The Elastic Agent DaemonSet, Prometheus stack, and logging pipelines (shipping to the Elastic Stack).
*   **`security/`**: Identity and access management, SSO proxies (OAuth2-Proxy), HashiCorp Vault, and External Secrets Operator.
*   **`config/`**: Modular cluster-wide configurations decoupled into `base/`, `cilium/`, `coredns/`, `cert-manager/`, `traefik/`, and `external-secrets/`.
*   **`vms/`**: Declarative KubeVirt VirtualMachines (e.g., `dc01-ad`, `win11`).
*   **`gaming/`**: Game servers and dedicated workloads (e.g., Palworld).
*   **`media/`**: Self-hosted media and automation stacks (Jellyfin, Radarr, Sonarr, Prowlarr).
*   **`apps/`**: ArgoCD Application and AppProject manifests forming the App-of-Apps hierarchy.

## 🌊 ArgoCD Sync Waves (0–9)

To ensure that dependencies are strictly met during cluster bootstrap or disaster recovery, ArgoCD manages applications in 10 deterministic Sync Waves:

1.  **Wave 0 (Bootstrap Scaffolding & Credentials):** `projects` (AppProject RBAC), `cluster-base` (bootstrap secrets, admin RBAC).
2.  **Wave 1 (Primary CNI Fabric):** `cilium` (eBPF CNI, pod IPAM, kube-proxy replacement), `network-policies` (baseline firewall rules).
3.  **Wave 2 (Secondary CNI & Cluster Metrics):** `multus` (meta-CNI for multi-homing), `cilium-config` (L2 announcement & IP pools), `metrics-server`.
4.  **Wave 3 (SDN Engine & Persistent Storage):** `kube-ovn` (secondary SDN controller), `local-path-provisioner`, `longhorn` (distributed storage), `media-storage`.
5.  **Wave 4 (SDN Networks & Dual-Homed DNS):** `kube-ovn-networks` (`ovn-ad-vpc` Subnet & NAD), `coredns` (AD forwarder & Multus secondary interface patch).
6.  **Wave 5 (Ingress & Compute Operators):** `traefik` (ingress controller DaemonSet), `cert-manager`, `external-secrets`, `vault`, `cdi`, `kubevirt`, `nvidia-gpu-operator`, `eck-operator`.
7.  **Wave 6 (Ingress Config, Certificates & Runtimes):** `traefik-config` (middlewares, TLSStore), `cert-manager-config` (ClusterIssuer, wildcard cert), `external-secrets-config` (vault-backend), `cdi-config`, `kubevirt-config`, `elasticsearch`, `oauth2-proxy`.
8.  **Wave 7 (Management Platforms & Observability):** `argocd` (HA & edge ingress), `kubevirt-manager`, `external-services`, `guacamole`, `kibana`, `logstash`, `fleet-server`.
9.  **Wave 8 (Workloads, VMs & Consumer Apps):** `dc01`, `win11`, `opnsense`, `homarr`, `ntfy`, `jellyfin`, `prowlarr`, `radarr`, `sonarr`, `palworld`.
10. **Wave 9 (Host Telemetry & Day-2 Operations):** `elastic-agent` (syslog, audit, container logs to Fleet), `autoops`.

## 📜 Manifest Conventions

To maintain uniformity across domains, all applications generally follow this standardized file structure within their respective directories:

*   `deployment.yaml` / `daemonset.yaml`
*   `service.yaml`
*   `ingress.yaml`
*   `configmap.yaml` / `secret.yaml`
*   `pvc.yaml` / `storage.yaml`
*   `virtualmachine.yaml` (For KubeVirt resources)

*Note: All manifests must pass `kubeconform` OpenAPI schema validation before being merged into the `main` branch. Custom Resource Definitions (CRDs) are validated against local schemas extracted directly from cluster CRDs and committed to `schemas/<kind>_<version>.json`.*
