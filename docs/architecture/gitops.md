# GitOps Engine & ArgoCD High-Availability Architecture

In **LambertLab**, Git is the absolute single source of truth for all Kubernetes cluster state. Cluster workloads, operators, Custom Resource Definitions (CRDs), and virtual machines are reconciled declaratively by **ArgoCD High Availability (HA)**.

---

## 🔄 App-of-Apps Topology & Sync Waves

```mermaid
graph TD
    Root["root-apps Application<br/>(App-of-Apps Pattern)"]

    Root --> Wave0
    Root --> Wave1
    Wave0 -.-> Wave1
    Wave1 -.-> Wave2
    Wave2 -.-> Wave3

    subgraph Row1[" "]
        subgraph W0["Sync Wave 0: AppProjects Scaffolding"]
            Wave0["AppProjects"]
            P1["infrastructure"]
            P2["security"]
            P3["media"]
            P4["observability"]
            P5["gaming"]
        end

        subgraph W1["Sync Wave 1: Foundation & Operators"]
            Wave1["Foundations"]
            Longhorn["Longhorn Storage"]
            Multus["Multus Thick CNI"]
            KubeVirtOp["KubeVirt & CDI"]
            CertMgr["Cert-Manager v1.21.2"]
            NMStateOp["kubernetes-nmstate"]
            GPUOp["NVIDIA GPU Operator"]
        end
    end

    subgraph Row2[" "]
        subgraph W2["Sync Wave 2: Security & Gateways"]
            Wave2["Gateways & Config"]
            Vault["HashiCorp Vault"]
            ExtSecrets["External Secrets"]
            ClusterCfg["CoreDNS & TLSStore"]
            NMStatePol["br-lab0 VXLAN"]
            Guac["Apache Guacamole"]
            KVMgr["KubeVirt Manager"]
            ExtSvc["External Services"]
        end

        subgraph W3["Sync Wave 3: Workloads & VMs"]
            Wave3["Workloads & VMs"]
            DC01VM["DC01 Active Directory"]
            Win11VM["Win11 Workstation"]
            OPNsenseVM["OPNsense Firewall"]
            MediaStack["ARR Media Stack / Jellyfin"]
            ObsStack["Homarr / Ntfy"]
            GamingStack["Palworld Dedicated"]
        end
    end
```

---

## ⚡ High-Availability Controller Architecture

ArgoCD is deployed in full **High Availability (HA)** mode across the 3-node control plane quorum (`lenovo`, `optiplex`, `opti74`):

1. **Redis Sentinel Clustering:** Multi-replica Redis state cache with automated master failover.
2. **Controller Sharding:** Active-active application controller replicas distribute sync loops and health evaluation pipelines evenly across nodes.
3. **Internal Backend TLS (`server.insecure: true`):** Traefik terminates client TLS at the edge using the wildcard `*.lambertlab.us` certificate, then communicates with `argocd-server` via an internal `ServersTransport` with insecure verification disabled.
4. **Strict Default-Deny RBAC:** Unauthorized users logging in via Microsoft Entra ID OIDC receive zero application view permissions by default (`policy.default: role:''`). Only members of the configured administrator directory group inherit `role:admin`.

---

## 🌊 Deterministic Synchronization Waves

ArgoCD assigns resources to discrete, sequential **Sync Waves** (evaluated in ascending numeric order). Wave $N+1$ does not initiate until Wave $N$ reaches a healthy, synchronized state:

| Sync Wave | Category | Primary Resources & Applications | Architectural Purpose |
| :---: | :--- | :--- | :--- |
| **`0`** | **AppProjects Scaffolding** | `infrastructure`, `security`, `media`, `observability`, `gaming` | Establishes project RBAC boundaries, source repo constraints, and allowed cluster destinations. |
| **`1`** | **Foundation & Storage** | `longhorn`, `multus`, `kubevirt`, `cdi`, `cert-manager`, `nmstate-operator`, `nvidia-gpu-operator` | Installs core storage drivers, CNI plugins, hypervisor operators, and foundational CRD schemas. |
| **`2`** | **Security & Core Gateways** | `vault`, `external-secrets`, `cluster-config`, `nmstate-policies`, `guacamole`, `kubevirt-manager`, `external-services` | Configures VXLAN networking (`br-lab0`), secrets engines, custom DNS forwarders, and clientless gateways. |
| **`3`** | **Consumer Workloads & VMs** | `dc01`, `win11`, `opnsense`, `jellyfin`, `sonarr`, `radarr`, `prowlarr`, `homarr`, `ntfy`, `palworld` | Deploys active virtual machines, database consumers, media applications, and game servers. |

---

## 🛠️ Drift Mitigation & `ignoreDifferences` Mechanics

Because certain Kubernetes controllers dynamically inject runtime metadata into managed objects, strict GitOps engines will flag non-existent drift unless configured with targeted `ignoreDifferences`:

### 1. StatefulSet `volumeClaimTemplates`
When StatefulSets (such as `vault`, `ntfy`, and `guacamole-postgresql`) scale up, the Kubernetes storage controller mutates volume claim templates with internal annotations (`volume.beta.kubernetes.io/storage-provisioner`). ArgoCD application manifests explicitly ignore these controller-injected fields:

```yaml
ignoreDifferences:
  - group: apps
    kind: StatefulSet
    jsonPointers:
      - /spec/volumeClaimTemplates
```

### 2. KubeVirt & CDI Dynamic CRD Schemas
KubeVirt DataVolumes and CDI upload proxies append dynamic status hashes and upload tokens (`cdi.kubevirt.io/storage.pod.phase`). ArgoCD ignores runtime CDI annotations to prevent false out-of-sync indicators while preserving GitOps authority over storage sizes and source definitions.
