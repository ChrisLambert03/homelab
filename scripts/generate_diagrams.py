#!/usr/bin/env python3
"""
LambertLab Homelab Architecture Diagrams Generator
Generates high-resolution architecture diagrams for MkDocs documentation
using the Python 'diagrams' library and official CNCF/Kubernetes community icons.
"""

import os
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.client import User
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.iac import Terraform
from diagrams.onprem.gitops import Argocd
from diagrams.onprem.security import Vault
from diagrams.saas.cdn import Cloudflare
from diagrams.generic.network import VPN, Firewall, Switch
from diagrams.onprem.network import Traefik, OPNSense, Internet
from diagrams.onprem.compute import Server
from diagrams.k8s.compute import Deployment, StatefulSet, DaemonSet, Pod
from diagrams.k8s.network import Ingress, Service, NetworkPolicy
from diagrams.k8s.storage import StorageClass, PV, PVC
from diagrams.k8s.infra import Node, Master, ETCD
from diagrams.generic.os import Windows, Ubuntu
from diagrams.generic.storage import Storage
from diagrams.azure.identity import ActiveDirectory, Users, Groups
from diagrams.elastic.elasticsearch import Elasticsearch, Logstash, Kibana, Beats

OUT_DIR = os.path.abspath("diagrams")
os.makedirs(OUT_DIR, exist_ok=True)

GRAPH_ATTRS = {
    "fontsize": "20",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "spline",
}

def generate_systems_provisioning_map():
    print("Generating: systems_provisioning_map.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "LR", "nodesep": "0.6", "ranksep": "1.0"}
    with Diagram("LambertLab Master Systems & Provisioning Map", show=False, filename=f"{OUT_DIR}/systems_provisioning_map", outformat="png", graph_attr=attrs):
        engineer = User("Staff Engineer / DevOps")

        with Cluster("Source of Truth & Automation Control Plane"):
            repo = Github("GitHub Repository\n(origin/main)")
            ci = GithubActions("GitHub Actions\n(Pre-Push & Docs CI)")
            tf = Terraform("Terraform Engine\n(IaC Core)")
            argo = Argocd("ArgoCD HA\n(GitOps Root-Apps)")
            vault = Vault("HashiCorp Vault\n(Secret Management)")

        with Cluster("Edge Ingress & Global Mesh"):
            cf = Cloudflare("Cloudflare\n(*.lambertlab.us & docs)")
            mesh = VPN("Tailscale Mesh\n(Direct WireGuard)")
            traefik = Traefik("Traefik Edge Ingress\n(:443 Wildcard TLS)")

        with Cluster("Hybrid Identity Federation Pipeline"):
            adds = ActiveDirectory("DC01 Active Directory\n(AD DS / Kerberos / LDAPS)")
            entra = ActiveDirectory("Microsoft Entra ID\n(OIDC SSO / Cloud Sync)")

        with Cluster("K3s Cluster (Sync Waves 1 -> 5)"):
            with Cluster("Wave 1: Core Operators & Software-Defined Fabric"):
                infra_ops = [
                    Deployment("Longhorn Engine"),
                    Deployment("Kube-OVN VPC"),
                    Deployment("KubeVirt & CDI"),
                    Deployment("Cert-Manager"),
                ]

            with Cluster("Wave 2: Ingress & Gateway Infrastructure"):
                guac = Deployment("Apache Guacamole\n(Multus L2 VPC)")
                eso = Deployment("External Secrets\nOperator")
                oauth2 = Deployment("OAuth2-Proxy\n(Traefik ForwardAuth)")

            with Cluster("Wave 3: Virtual Machines & Application Workloads"):
                opnsense = OPNSense("OPNsense Firewall VM\n(Edge Perimeter)")
                win11 = Windows("Win11 Admin Workstation\n(Sysprep / unattend.xml)")
                dc01_vm = Windows("DC01 VM\n(Windows Server 2025)")
                jellyfin = Deployment("Jellyfin\n(RTX GPU Hardware Transcode)")
                arrs = Pod("Sonarr / Radarr / Prowlarr\n(Media Automation)")

            with Cluster("Wave 5: Fleet Observability DaemonSet"):
                eagent = DaemonSet("Elastic Agent\n(Per-Node Telemetry)")

        with Cluster("Storage Tiers (SAN & Block)"):
            san_iscsi = Storage("TerraMaster SAN iSCSI\n(Raw LUNs for VMs)")
            san_nfs = PV("TerraMaster SAN NFS\n(14TB Bulk Media Pool)")
            longhorn_storage = StorageClass("Longhorn Retain SC\n(Distributed NVMe)")

        with Cluster("Centralized SIEM & Telemetry (Workstation Engine)"):
            logstash = Logstash("Logstash Pipeline\n(:12201 GELF)")
            es = Elasticsearch("Elasticsearch 8.x\n(Single-Node ILM)")
            kibana = Kibana("Kibana Security Portal\n(:5601)")
            logstash >> es >> kibana

        engineer >> repo >> ci
        repo >> Edge(label="GitOps Sync", color="darkgreen", style="bold") >> argo
        repo >> Edge(label="IaC Apply", color="purple", style="bold") >> tf

        tf >> Edge(label="DNS & CNAMEs", color="orange") >> cf
        tf >> Edge(label="WinRM OUs & Users", color="blue") >> adds
        tf >> Edge(label="Mesh Routing", color="cyan") >> mesh
        tf >> Edge(label="Secrets Engine", color="gray") >> vault

        argo >> Edge(label="Wave 1", color="darkgreen") >> infra_ops
        argo >> Edge(label="Wave 2", color="darkgreen") >> [guac, eso, oauth2]
        argo >> Edge(label="Wave 3", color="darkgreen") >> [opnsense, win11, dc01_vm, jellyfin, arrs]
        argo >> Edge(label="Wave 5", color="darkgreen") >> eagent

        dc01_vm >> Edge(label="Hosts AD DS", color="blue") >> adds
        adds >> Edge(label="Entra Cloud Sync (gMSA)", color="blue", style="dashed") >> entra
        entra >> Edge(label="OIDC SSO Authentication", color="blue") >> [argo, guac]

        cf >> Edge(label="Round-Robin Ingress", color="orange") >> mesh
        mesh >> Edge(label="Wire-Speed Handshake", color="cyan") >> traefik
        traefik >> Edge(label="IngressRoute", color="black") >> [guac, jellyfin, kibana]

        san_iscsi >> Edge(label="Direct Raw Block", color="brown") >> [dc01_vm, win11]
        san_nfs >> Edge(label="NFS RWX Mount", color="brown") >> [jellyfin, arrs]
        longhorn_storage >> Edge(label="RWO Retain", color="brown") >> vault

        eagent >> Edge(label="Pod & OS Logs", color="red", style="dashed") >> logstash
        guac >> Edge(label="Docker GELF", color="red", style="dashed") >> logstash


def generate_hardware_topology():
    print("Generating: hardware_topology.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "TB"}
    with Diagram("Physical Node Fleet & Compute Roles", show=False, filename=f"{OUT_DIR}/hardware_topology", outformat="png", graph_attr=attrs):
        with Cluster("Physical Compute Nodes"):
            with Cluster("Lenovo ThinkCentre M920q (10.0.0.12)"):
                lenovo = Master("lenovo\nCore i5 / 32GB RAM\nPrimary K3s Control Plane")
                lenovo_etcd = ETCD("etcd Leader")

            with Cluster("Dell OptiPlex 9020 (10.0.0.13)"):
                optiplex = Master("optiplex\nCore i7 / 32GB RAM\nControl Plane + Subnet Router")
                opti_etcd = ETCD("etcd Follower")

            with Cluster("Dell OptiPlex 7040 (10.0.0.14)"):
                opti74 = Master("opti74\nCore i7 / 32GB RAM\nControl Plane Node")
                opti74_etcd = ETCD("etcd Follower")

            with Cluster("Custom Workstation (10.0.0.15)"):
                workstation = Node("workstation\nXeon 16c/32t / 64GB RAM\nWorker & Heavy Compute")
                gpu = Pod("NVIDIA RTX A4500\n(20GB VRAM / Transcoding)")
                elk = Elasticsearch("Docker SIEM (NVMe)")

        with Cluster("Network Attached Storage & SAN"):
            san = Storage("TerraMaster F4-425 Plus (10.0.0.60)\nIntel N100 / 32GB RAM\nRaw iSCSI LUNs + 14TB NFS")

        switch = Switch("Physical Gigabit Switch Fabric (10.0.0.0/24)")
        
        [lenovo, optiplex, opti74, workstation] >> switch
        switch >> san
        lenovo_etcd - opti_etcd - opti74_etcd
        workstation - gpu
        workstation - elk


def generate_storage_architecture():
    print("Generating: storage_architecture.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "LR"}
    with Diagram("Three-Tier Storage Hierarchy & SAN", show=False, filename=f"{OUT_DIR}/storage_architecture", outformat="png", graph_attr=attrs):
        with Cluster("Tier 1: Dedicated Raw Block iSCSI (TerraMaster SAN)"):
            iscsi_san = Storage("TerraMaster SAN\n(F4-425 Plus)")
            dc01_lun = Storage("80 GB Raw LUN\n(dc01-disk)")
            win11_lun = Storage("64 GB Raw LUN\n(win11-boot)")
            opn_lun = Storage("40 GB Raw LUN\n(opnsense-boot)")
            iscsi_san >> [dc01_lun, win11_lun, opn_lun]

        with Cluster("Tier 2: Distributed Replicated NVMe (Longhorn)"):
            lh_sc = StorageClass("longhorn-retain\nStorageClass")
            vault_pvc = PVC("Vault Storage PVC\n(numberOfReplicas: 2)")
            guac_pvc = PVC("Guacamole DB PVC\n(numberOfReplicas: 2)")
            ntfy_pvc = PVC("Ntfy Message PVC\n(numberOfReplicas: 2)")
            lh_sc >> [vault_pvc, guac_pvc, ntfy_pvc]

        with Cluster("Tier 3: Bulk Media & ISO Storage (NFS Pool)"):
            nfs_san = Storage("14 TB RAID Pool\n(/Volume1/data)")
            media_pv = PV("nas-media-pv\n(ReadWriteMany / NFS)")
            media_pvc = PVC("nas-media-pvc\n(14 TB Claim)")
            nfs_san >> media_pv >> media_pvc

        with Cluster("Consumer Workloads"):
            dc01_app = Windows("DC01 VM")
            win11_app = Windows("Win11 VM")
            opn_app = OPNSense("OPNsense VM")
            vault_app = Vault("Vault Server")
            media_apps = [Deployment("Jellyfin"), Pod("Sonarr / Radarr")]

        dc01_lun >> Edge(label="libiscsi / viostor") >> dc01_app
        win11_lun >> Edge(label="libiscsi / viostor") >> win11_app
        opn_lun >> Edge(label="libiscsi") >> opn_app
        vault_pvc >> vault_app
        media_pvc >> media_apps


def generate_identity_federation():
    print("Generating: identity_federation.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "LR"}
    with Diagram("Hybrid Identity & Entra ID Federation", show=False, filename=f"{OUT_DIR}/identity_federation", outformat="png", graph_attr=attrs):
        with Cluster("Declarative IaC Management"):
            tf_ad = Terraform("Terraform\nactive_directory/ Module")
            svc_tf = User("svc_terraform\n(WinRM Admin)")
            tf_ad >> svc_tf

        with Cluster("Windows Server 2025 (dc01.ad.lambertlab.us)"):
            adds = ActiveDirectory("Active Directory DS\n(ad.lambertlab.us)")
            ca = Storage("Enterprise Root CA\n(lambertlab-DC01-CA)")
            dns = Service("AD Dynamic DNS\n(10.10.0.10:53)")
            cloud_sync = ActiveDirectory("Entra Cloud Sync Agent\n(gMSA: provAgentgMSA$)")
            adds >> cloud_sync
            adds >> ca

        with Cluster("Microsoft Entra ID (Cloud Tenant)"):
            entra_users = Users("Synchronized Users\n(chris@lambertlab.us)")
            entra_groups = Groups("Security Groups\n(LambertLab-Admins)")
            break_glass = User("Break-Glass Admin\n(Cloud-Only Account)")

        with Cluster("OIDC Authenticated Applications"):
            argo_app = Argocd("ArgoCD HA")
            guac_app = Deployment("Apache Guacamole")

        svc_tf >> Edge(label="WinRM TCP 5985", color="blue") >> adds
        cloud_sync >> Edge(label="Outbound HTTPS 443\nPHS HMAC-SHA256", color="darkgreen") >> entra_users
        cloud_sync >> Edge(label="Sync Security Groups", color="darkgreen") >> entra_groups
        entra_users >> Edge(label="OIDC SSO Flow", color="purple") >> [argo_app, guac_app]
        adds >> Edge(label="LDAPS TCP 636 Fallback", color="blue", style="dashed") >> guac_app


def generate_siem_pipeline():
    print("Generating: siem_pipeline.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "LR"}
    with Diagram("Security Information & Event Management (SIEM)", show=False, filename=f"{OUT_DIR}/siem_pipeline", outformat="png", graph_attr=attrs):
        with Cluster("Cluster Fleet Telemetry Sources"):
            k8s_pods = Pod("Kubernetes Pod Logs\n(/var/log/pods)")
            host_logs = Ubuntu("Host OS Telemetry\n(journald, auth.log, syslog)")
            docker_logs = Deployment("Docker Containers\n(GELF Driver over Tailscale)")
            win_events = Windows("Windows Security Events\n(DC01 / Win11 Event IDs)")

        with Cluster("Telemetry Collection Agents"):
            agent_ds = DaemonSet("Elastic Agent DaemonSet\n(Preset: perNode / Pinned 9.3.2)")
            k8s_pods >> agent_ds
            host_logs >> agent_ds

        with Cluster("Workstation Bare-Metal SIEM Engine"):
            fleet = Server("Fleet Server\n(Tailscale :8220)")
            logstash = Logstash("Logstash Pipeline\n(:12201 GELF)")
            es = Elasticsearch("Elasticsearch 8.x\n(Single-Node ILM / NVMe)")
            kibana = Kibana("Kibana Security Portal\n(https://kibana.lambertlab.us)")

            docker_logs >> logstash
            win_events >> logstash
            agent_ds >> Edge(label="Enrollment & Policy", color="darkgreen") >> fleet
            agent_ds >> Edge(label="Bulk Ingest :9200", color="darkgreen") >> es
            logstash >> Edge(label="Structured Ingest", color="darkgreen") >> es
            es >> Edge(label="Dashboards & Discover", color="blue") >> kibana

        with Cluster("Target Security Use Cases"):
            kibana >> [
                Pod("Sudo & SSH Brute Force"),
                Pod("Kernel OOM Killer"),
                Pod("Pod CrashLoopBackOff"),
                Pod("AD Logon / Privilege Escalation"),
            ]


def generate_virtualization_architecture():
    print("Generating: virtualization_architecture.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "TB"}
    with Diagram("KubeVirt & Virtual Machine Architecture", show=False, filename=f"{OUT_DIR}/virtualization_architecture", outformat="png", graph_attr=attrs):
        with Cluster("KubeVirt Control Plane"):
            kv_op = Deployment("KubeVirt Operator")
            cdi = Deployment("CDI (Containerized Data Importer)")
            kv_mgr = Deployment("KubeVirt Manager Web UI\n(NoVNC Console)")

        with Cluster("Software-Defined L2 VPC Network Fabric"):
            vxlan_bridge = Switch("ovn-ad-vpc Geneve UDP Overlay\n(10.10.0.0/24 VPC)")

        with Cluster("Virtual Machines (Wave 3)"):
            with Cluster("OPNsense Edge Perimeter VM"):
                opn = OPNSense("OPNsense 24.x\n(Virtual Edge Router)")
                opn_disk = Storage("Raw iSCSI LUN (40GB)")

            with Cluster("DC01 Active Directory VM"):
                dc01 = Windows("Windows Server 2025\n(10.10.0.10 Static)")
                dc01_disk = Storage("Raw iSCSI LUN (80GB)")

            with Cluster("Windows 11 Admin Workstation VM"):
                win11 = Windows("Windows 11 Enterprise\n(10.10.0.155 DHCP)")
                win11_tpm = Storage("Persistent swtpm (Longhorn)")
                win11_disk = Storage("Raw iSCSI LUN (64GB)")

        san_target = Storage("TerraMaster SAN (10.0.0.60)\nqemu-img Line-Rate Flashing")
        
        san_target >> [opn_disk, dc01_disk, win11_disk]
        opn_disk >> opn
        dc01_disk >> dc01
        win11_disk >> win11
        win11_tpm >> win11

        opn - vxlan_bridge
        dc01 - vxlan_bridge
        win11 - vxlan_bridge


def generate_gitops_waves():
    print("Generating: gitops_waves.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "LR"}
    with Diagram("ArgoCD GitOps HA & Sync Wave Progression", show=False, filename=f"{OUT_DIR}/gitops_waves", outformat="png", graph_attr=attrs):
        git_repo = Github("Git: origin/main\n(Absolute Source of Truth)")
        root_app = Argocd("root-apps\n(App-of-Apps Pattern)")

        git_repo >> Edge(label="Self-Healing Polling", color="darkgreen", style="bold") >> root_app

        with Cluster("Sync Wave 1: Core Operators"):
            w1 = [
                Deployment("Longhorn"),
                Deployment("KubeVirt"),
                Deployment("CDI"),
                Deployment("Cert-Manager"),
                Deployment("Multus CNI"),
                Deployment("Kube-OVN"),
                NetworkPolicy("Zero-Trust Policies"),
            ]

        with Cluster("Sync Wave 2: Infrastructure & Gateways"):
            w2 = [
                Argocd("ArgoCD HA"),
                Vault("HashiCorp Vault"),
                Deployment("External Secrets"),
                Deployment("OAuth2-Proxy"),
                Deployment("Apache Guacamole"),
                Deployment("Traefik ACLs"),
            ]

        with Cluster("Sync Wave 3: Workloads & VMs"):
            w3 = [
                OPNSense("OPNsense VM"),
                Windows("DC01 AD VM"),
                Windows("Win11 VM"),
                Deployment("Jellyfin"),
                Pod("*Arrs Media Suite"),
                Pod("Palworld Server"),
            ]

        with Cluster("Sync Wave 5: Fleet Observability"):
            w5 = DaemonSet("Elastic Agent DaemonSet\n(Per-Node Telemetry)")

        root_app >> Edge(label="Wave 1: Operators", color="darkgreen") >> w1[0]
        root_app >> Edge(label="Wave 2: Gateways", color="blue") >> w2[0]
        root_app >> Edge(label="Wave 3: Workloads", color="purple") >> w3[0]
        root_app >> Edge(label="Wave 5: Telemetry", color="red") >> w5


def generate_zero_trust_network():
    print("Generating: zero_trust_network.png...")
    attrs = {**GRAPH_ATTRS, "rankdir": "TB"}
    with Diagram("Zero-Trust Network Policy Architecture", show=False, filename=f"{OUT_DIR}/zero_trust_network", outformat="png", graph_attr=attrs):
        traefik = Ingress("Traefik (kube-system)\nGlobal Entrypoint")
        with Cluster("Namespace: media"):
            np_media = NetworkPolicy("media-default-deny\n(Drop All Ingress)")
            sonarr = Pod("Sonarr")
            radarr = Pod("Radarr")
            traefik >> Edge(label="Explicit Allow", color="darkgreen") >> np_media
            np_media >> [sonarr, radarr]
            sonarr << Edge(label="Intra-Namespace Allow", color="darkgreen") >> radarr
        with Cluster("Namespace: observability"):
            np_obs = NetworkPolicy("observability-default-deny\n(Drop All Ingress)")
            homarr = Pod("Homarr")
            traefik >> Edge(label="Explicit Allow", color="darkgreen") >> np_obs
            np_obs >> homarr
            homarr >> Edge(label="Blocked Cross-Namespace", color="red", style="dashed") >> sonarr

if __name__ == "__main__":
    generate_systems_provisioning_map()
    generate_hardware_topology()
    generate_storage_architecture()
    generate_identity_federation()
    generate_siem_pipeline()
    generate_virtualization_architecture()
    generate_gitops_waves()
    generate_zero_trust_network()
    print("All 7 architecture diagrams generated successfully!")
