# Cloud-Native Virtualization Infrastructure (KubeVirt)

<div align="center">

[![KubeVirt](https://img.shields.io/badge/KubeVirt-v1.9.0-purple?style=for-the-badge&logo=redhatopenshift&logoColor=white)](https://kubevirt.io)
[![QEMU/KVM](https://img.shields.io/badge/Hypervisor-QEMU%2FKVM-orange?style=for-the-badge&logo=qemu&logoColor=white)](https://www.qemu.org)
[![Storage](https://img.shields.io/badge/Storage-iSCSI_SAN_%2B_NFS-blue?style=for-the-badge&logo=netapp&logoColor=white)](https://en.wikipedia.org/wiki/ISCSI)
[![Networking](https://img.shields.io/badge/Network-Multus_L2_VXLAN-24A1C1?style=for-the-badge&logo=kubernetes&logoColor=white)](https://github.com/k8snetworkplumbingwg/multus-cni)
[![Windows 11](https://img.shields.io/badge/Windows_11-Enterprise_LTSC-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise)
[![Active Directory](https://img.shields.io/badge/Active_Directory-ad.lambertlab.us-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-domain-services)
[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-EF6036?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io)

</div>

---

## 🏛️ Architecture & System Design

This subsystem manages bare-metal, enterprise-grade virtual machines running on top of a multi-node **K3s Kubernetes cluster** via **KubeVirt v1.9.0**.

By replacing traditional standalone hypervisors with KubeVirt, this architecture converges legacy monolithic operating systems and cloud-native container workloads into a **single declarative control plane**. All virtual machine lifecycles, virtual hardware topologies, storage claims, and network attachments are tracked in Git and continuously reconciled via **ArgoCD**.

---

## 📝 Key Engineering Accomplishments

- [x] **Converged Container & VM Control Plane**: Unified virtualized Windows infrastructure and containerized microservices under Kubernetes APIs, eliminating isolated hypervisor management silos.
- [x] **Hardware-Enforced Windows 11 Security Compliance**: Implemented fully compliant OVMF UEFI Secure Boot paired with persistent virtual TPM 2.0 (`swtpm`) state storage backed by Longhorn, passing all Windows 11 hardware attestation checks out of the box.
- [x] **Dedicated iSCSI SAN Block Integration**: Architected dedicated low-latency iSCSI block storage targets hosted on the TerraMaster NAS directly into KubeVirt VirtualMachines, delivering native SCSI performance without filesystem overhead.
- [x] **Multi-vCPU Hyper-V Hypercall Optimization**: Engineered a comprehensive suite of KVM Hyper-V enlightened flags, drastically mitigating virtualization overhead, inter-processor interrupts, and timer latency across guest CPU cores.
- [x] **Multi-Node L2 VXLAN Network Bridging**: Integrated Multus CNI with cluster-wide multicast VXLAN bridging (`br-lab0`), granting VMs native Layer 2 presence on the isolated virtual LAN fabric for transparent Active Directory DNS, LDAP, and Kerberos operations without NAT.
- [x] **Declarative GitOps Lifecycle Management**: Bound all virtual machine definitions, persistent volumes, and configuration state to ArgoCD synchronization waves with automated drift detection and self-healing.

---

## 📦 Virtualized Workload Portfolio

| Virtual Machine | Operating System | Profile | Storage Architecture | Network Interface | Primary Role |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`win11`** | Windows 11 Enterprise LTSC | 4 vCPU / 8 GiB RAM | 64 GB iSCSI Block LUN | `lab-lan-bridge` (VXLAN) | Domain-Joined Enterprise Admin Workstation |
| **`dc01`** | Windows Server 2025 | 4 vCPU / 8 GiB RAM | 80 GB iSCSI Block LUN | `lab-lan-bridge` (VXLAN) | Primary Domain Controller (`ad.lambertlab.us`) |
| **`opnsense`** | FreeBSD 14 / OPNsense | 4 vCPU / 4 GiB RAM | Distributed Longhorn Block | Host NIC Physical Bridge | Edge Routing Gateway, NAT, & Firewall |

---

## 🔬 Deep Technical Specifications & Flag Analysis

Deploying modern Windows workloads on KubeVirt requires precise low-level hypervisor tuning to ensure stability, hardware compatibility, and low host resource utilization. Below is an exhaustive breakdown of the architectural specifications and configuration flags defined in `kubernetes/vms/win11/vm.yaml`:

### 1. Firmware, Secure Boot & Virtual TPM Subsystem

```yaml
firmware:
  bootloader:
    efi:
      secureBoot: true
      persistent: true
features:
  smm:
    enabled: true
devices:
  tpm:
    persistent: true
```

* **`firmware.bootloader.efi.secureBoot: true`**: Replaces standard SeaBIOS with Open Virtual Machine Firmware (OVMF) compiled with Microsoft Authenticode keys. Mandatory for Windows 11 boot validation.
* **`firmware.bootloader.efi.persistent: true`**: Persists the EFI NVRAM variables across VM reboots. Without this, Windows Boot Manager variables and boot priorities are wiped every time the VM restarts, causing UEFI boot failures.
* **`features.smm.enabled: true`**: Enables System Management Mode (SMM) emulation inside QEMU. OVMF Secure Boot strictly requires SMM to prevent unauthorized guest operating system code from modifying the authenticated Secure Boot keystore.
* **`devices.tpm.persistent: true`**: Emulates a hardware-compliant TPM 2.0 cryptographic chip using `swtpm`. By enabling persistence, KubeVirt automatically provisions a backing state volume using the cluster's default **Longhorn** storage class, preserving BitLocker encryption keys, platform configuration registers (PCRs), and credentials across pod lifecycles.

---

### 2. Multi-vCPU Hyper-V Enlightenments Suite

Windows kernels are architected to recognize Microsoft Hyper-V hypervisors. KubeVirt exposes KVM's Hyper-V synthetic hypercalls to Windows, dramatically reducing CPU overhead and eliminating expensive VM exits:

```yaml
features:
  hyperv:
    relaxed: {}
    vapic: {}
    spinlocks:
      spinlocks: 8191
    synic: {}
    synictimer:
      direct: {}
    reset: {}
    runtime: {}
    frequencies: {}
    reenlightenment: {}
    tlbflush: {}
    ipi: {}
    vpindex: {}
```

* **`tlbflush`**: Allows the guest kernel to issue Hyper-V hypercalls to flush Translation Lookaside Buffers (TLBs) across all virtual processors simultaneously. This avoids inter-processor interrupts (IPIs) across the 4 vCPUs, substantially improving memory management performance.
* **`ipi`**: Enables synthetic Hyper-V hypercalls for sending inter-processor interrupts, bypassing standard emulated local APIC bottlenecks.
* **`synictimer.direct: {}`**: Provides direct synthetic timer message delivery directly into guest architectural registers, completely bypassing hypervisor context switching.
* **`frequencies`**: Exposes pre-calculated TSC (Time Stamp Counter) and APIC frequencies directly to the guest OS, eliminating guest CPU overhead spent attempting to measure hardware clock speeds.
* **`vpindex`**: Provides a virtual processor index MSR (Model-Specific Register), enabling Windows to track its own vCPU topology efficiently.
* **`reenlightenment`**: Informs the guest operating system if hypervisor scheduling or migration alters underlying hardware timing characteristics.
* **`relaxed`**: Relaxes guest timer constraints during periods when the host CPU is heavily loaded, preventing Windows from triggering false-positive Blue Screen of Death (BSOD) watchdog timeouts (`CLOCK_WATCHDOG_TIMEOUT`).
* **`vapic`**: Enables virtual APIC support, reducing overhead when the Windows kernel accesses APIC registers during task scheduling.
* **`spinlocks (8191)`**: Tells Windows to yield the vCPU if a kernel lock cannot be acquired after 8,191 attempts, preventing wasteful CPU core spinning on contended threads.
* **`synic` & `runtime`**: Implements Hyper-V Synthetic Interrupt Controllers and virtual processor runtime tracking for enterprise telemetry.

---

### 3. Hardware Clocks & Timer Synchronization

```yaml
clock:
  timezone: "America/New_York"
  timer:
    hpet:
      present: false
    pit:
      tickPolicy: delay
    rtc:
      tickPolicy: catchup
    hyperv: {}
```

* **`timezone: "America/New_York"`**: Pins the emulated hardware RTC directly to Eastern Time. Unlike Linux which defaults to UTC hardware clocks, Windows natively assumes physical hardware RTCs run on local time. Setting this in the hypervisor avoids an automatic 4-hour/5-hour time offset upon boot.
* **`hpet (present: false)`**: Disables the High Precision Event Timer. HPET emulation imposes significant virtualization overhead under KVM; disabling it forces Windows to utilize the significantly faster TSC and Hyper-V synthetic timers.
* **`pit (tickPolicy: delay)`**: Directs the Programmable Interval Timer to discard missed ticks if the hypervisor delays delivery, preventing interrupt storms when resuming execution.
* **`rtc (tickPolicy: catchup)`**: Directs the Real Time Clock to inject missed ticks at a higher rate to allow the Windows system clock to smoothly catch up after high-load pauses.

---

### 4. Paravirtualized I/O Architecture & Driver Subsystem

Windows does not natively include drivers for KVM paravirtualized hardware. To achieve bare-metal line-rate performance and hypervisor coordination, the VM utilizes Red Hat's WHQL-certified **VirtIO drivers** (`virtio-win`) and the **QEMU Guest Agent** (`qemu-ga`):

| Subsystem | Legacy Emulated (Traps to QEMU) | VirtIO Paravirtualized | Architectural Advantage |
| :--- | :--- | :--- | :--- |
| **Storage Controller** | Emulated SATA / IDE | **VirtIO SCSI (`viostor`)** | Direct DMA block transfers via shared memory rings; eliminates emulated interrupt overhead. |
| **Network Interface** | Emulated Intel e1000e (1 Gbps) | **VirtIO Net (`NetKVM`)** | Multi-queue 10G+ virtual line-rate throughput directly into the Linux bridge fabric. |
| **Memory Balloon** | Static host allocation | **VirtIO Balloon (`balloon`)** | Dynamic memory reclamation and host-to-guest RAM statistics reporting. |
| **Pointer Device** | Relative USB Mouse | **VirtIO Tablet (`tablet`)** | Absolute coordinate mapping; eliminates cursor drift/lag across VNC and remote sessions. |
| **Guest Control Plane** | ACPI power buttons | **QEMU Guest Agent (`qemu-ga`)** | Out-of-band communication channel for graceful shutdowns, IP reporting, and VSS snapshots. |

#### The QEMU Guest Agent (`qemu-ga`) Integration
Rather than relying on the guest network adapter, `qemu-ga` communicates across a dedicated virtual serial channel (`org.qemu.guest_agent.0`) bound between KVM and Windows. This provides KubeVirt with direct control plane visibility:
* **Clean, Application-Consistent Shutdowns**: Allows Kubernetes to issue orderly guest OS shutdowns, ensuring Windows flushes dirty disk buffers and stops system services before pod termination.
* **Dynamic Network Discovery**: Reports active guest IP addresses, network interfaces, and MAC addresses back to Kubernetes, populating `status.interfaces` on the `VirtualMachineInstance` object.
* **Volume Shadow Copy Service (VSS) Integration**: Coordinates with Windows VSS to freeze NTFS filesystem writes during volume snapshots or backups, guaranteeing zero database transaction corruption.
* **Hardware Clock Resynchronization**: Continuously synchronizes guest system time against the host hardware RTC, eliminating hypervisor time skew.
* **Accurate Memory & CPU Telemetry**: Reports real-time guest memory consumption and system performance metrics directly to the cluster's Prometheus and Grafana monitoring pipeline.

```yaml
devices:
  blockMultiQueue: true
  inputs:
    - type: tablet
      bus: usb
      name: tablet
  disks:
    - name: boot-disk
      disk:
        bus: virtio
      bootOrder: 2
    - name: win-iso
      cdrom:
        bus: sata
      bootOrder: 1
    - name: virtio-drivers
      cdrom:
        bus: sata
  rng: {}
```

* **`disk.bus: virtio`**: Mounts the primary storage LUN via the Red Hat VirtIO SCSI/Block bus (`viostor`). Rather than simulating physical SATA/IDE controllers, VirtIO establishes direct memory-mapped ring buffers between Windows and KVM for maximum block throughput.
* **`blockMultiQueue: true`**: Allocates dedicated I/O submission and completion queues for each assigned vCPU, allowing parallel disk transactions without queuing bottlenecks.
* **`inputs (type: tablet, bus: usb)`**: Implements absolute coordinate pointer tracking. Standard emulated USB mice pass relative coordinates, causing cursor escaping, desynchronization, and lag over VNC or remote management consoles. The tablet device ensures pixel-perfect coordinate mapping.
* **`rng: {}`**: Exposes a VirtIO Hardware Random Number Generator to the guest OS. This passes host kernel entropy directly into the Windows cryptographic subsystem (`KSecDD`), preventing entropy exhaustion during TLS key generation and domain joins.
* **`terminationGracePeriodSeconds: 300`**: Extends the pod shutdown window from the standard 60 seconds to 5 minutes. This ensures that when Windows installs OS updates during reboot or shutdown, Kubernetes will not issue an abrupt `SIGKILL`, preventing NTFS filesystem and update store corruption.

---

### 5. Storage Fabric & Network Topology

```yaml
# Storage: Dedicated iSCSI Block LUN
iscsi:
  targetPortal: san.lambertlab.us:3260
  iqn: iqn.2026-09.us.lambertlab:win11-boot
  lun: 0
  fsType: ext4

# Network: Multus Layer 2 VXLAN
networks:
  - name: lab-lan
    multus:
      networkName: lab-lan-bridge
```

* **Dedicated iSCSI Target**: Bound to `iqn.2026-09.us.lambertlab:win11-boot` hosted on the TerraMaster SAN SATA SSD pool. iSCSI delivers dedicated SCSI command queuing with sub-2ms random I/O latency, completely bypassing NFS file-locking mechanics.
* **Multus CNI (`lab-lan-bridge`)**: Connects the virtual machine directly to the physical cluster's `br-lab0` multicast VXLAN overlay. This places the VM directly on the flat virtual LAN subnet alongside `dc01` and OPNsense, enabling native Active Directory Kerberos ticket exchanges, LDAP queries, and dynamic DNS registration without traversing Kubernetes NAT gateways.

---

## 💿 Master Image Lifecycle & Automated Virtual Desktop Provisioning

To eliminate manual OS installations and guarantee identical, deterministic desktop environments, this infrastructure implements an automated **Golden Master Template Lifecycle**. A reference virtual machine is installed, tuned with paravirtualized drivers, and generalized using Microsoft Sysprep. The underlying raw iSCSI block storage is then extracted and compressed into an immutable QCOW2 master template, enabling rapid zero-touch provisioning of new workstations via KubeVirt's **Containerized Data Importer (CDI)** and native **Sysprep Secret specialization**.

---

### Phase 1: OS Sealing & Machine SID Generalization

Before any virtual machine image can serve as a multi-instance template, system-specific identifiers must be removed. Duplicating an ungeneralized Windows installation produces duplicate Security Identifiers (Machine SIDs), resulting in WSUS conflicts, Active Directory Trust broken relationships, and Kerberos ticket collisions.

The reference VM is generalized and sealed from an elevated command prompt:

```cmd
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown
```

* **`/generalize`**: Strips the unique Machine SID, clears hardware-specific GUIDs, purges device-specific driver databases, and resets the event log engine.
* **`/oobe`**: Sets the boot configuration database to trigger the Out-of-Box Experience on subsequent boot, allowing the setup engine to process unattended configuration passes.
* **`/shutdown`**: Powers off the hypervisor instance cleanly, guaranteeing zero disk writes occur after SID generalization.

---

### Phase 2: Block-to-Image Extraction & Compression (`qemu-img`)

With the reference VM powered off, the underlying storage LUN is frozen in an immutable, generalized state. Using QEMU's native user-space storage drivers, the raw block volume is streamed directly across the storage network, parsed, and converted into a compressed QCOW2 template.

```bash
qemu-img convert -p -f raw -O qcow2 -c \
  iscsi://san.lambertlab.us/iqn.2026-09.us.lambertlab:win11-boot/0 \
  win11-template.qcow2 2> >(grep -v "GET_LBA_STATUS" >&2)
```

#### Technical Flag Specifications

| Parameter | Technical Function & Architectural Role |
| :--- | :--- |
| **`convert`** | Core QEMU conversion engine; reads the source sector allocation table and writes only non-zero clusters to the destination format. |
| **`-p`** | **Real-Time Progress Tracking**: Renders dynamic byte transfer and percentage completion indicators. |
| **`-f raw`** | **Input Driver Specification**: Enforces raw block parsing on the source volume, bypassing heuristic filesystem probing. |
| **`-O qcow2`** | **Output Target Architecture**: Compiles the disk into **QEMU Copy-On-Write v2** format, featuring sparse allocation, internal snapshots, and cluster metadata. |
| **`-c`** | **Lossless Cluster Compression**: Applies transparent zlib/deflate compression across allocated data clusters, shrinking an enterprise OS footprint by 50–60%. |
| **`iscsi://...`** | **Direct User-Space iSCSI Protocol**: Utilizes `libiscsi` to establish TCP socket connections directly with the SAN target portal, eliminating the need for host kernel iSCSI initiator logins or device node management. |

> [!NOTE]
> **SCSI Protocol Analysis: `GET_LBA_STATUS` (SBC-3)**:
> During extraction from standard iSCSI targets, `qemu-img` may emit:
> `qemu-img: iSCSI GET_LBA_STATUS failed at lba 0: SENSE KEY:ILLEGAL_REQUEST(5) ASCQ:INVALID_FIELD_IN_CDB(0x2400)`
> `GET_LBA_STATUS` is an optional SCSI Block Command (SBC-3) query used to probe thin-provisioning metadata. If the storage target daemon does not implement this optional query, it returns a standard SCSI sense rejection (`0x2400`). QEMU automatically handles this by falling back to sequential block reads paired with software zero-detection, resulting in zero data loss or corruption.

---

### Phase 3: Automated Ingestion via Containerized Data Importer (CDI)

Deploying a new VM from the golden master involves provisioning a target volume and streaming the template into the disk via KubeVirt's **Containerized Data Importer (CDI)** upload proxy.

```bash
./upload-image.sh win11-template.qcow2 vms win11-boot-pvc
```

Or executed directly via the `virtctl` CLI:

```bash
virtctl image-upload pvc win11-boot-pvc \
  --namespace vms \
  --image-path=win11-template.qcow2 \
  --uploadproxy-url=https://cdi.lambertlab.us \
  --no-create
```

#### CDI Upload Parameter Reference

| Flag | Function |
| :--- | :--- |
| **`pvc`** | Identifies the target Kubernetes `PersistentVolumeClaim` bound to the destination storage volume. |
| **`--namespace`** | Kubernetes namespace scoping the target workload (`vms`). |
| **`--image-path`** | Filesystem path referencing the master `.qcow2` template file. |
| **`--uploadproxy-url`** | External ingress endpoint exposing `cdi-uploadproxy` via Traefik with trusted wildcard TLS termination. |
| **`--no-create`** | Directs CDI to ingest the disk image directly into a pre-existing, declaratively bound PVC rather than generating dynamic storage. |
| **`--size`** | Defines volume capacity when dynamic PVC provisioning is utilized (e.g., `--size=64Gi`). |
| **`--force-bind`** | Overrides volume binding mode constraints, forcing immediate volume provisioning regardless of consumer pod state. |

---

### Alternative: Direct High-Speed iSCSI Ingestion via `qemu-img`

For large multi-gigabyte virtual disks (such as Windows 11), streaming through CDI and an HTTP ingress proxy can trigger intermediate Longhorn scratch volume allocations (64+ GiB) or HTTP proxy timeout drops. A direct, line-rate alternative is streaming the compressed `.qcow2` template directly into the iSCSI target LUN using QEMU's native user-space `libiscsi` driver:

```bash
qemu-img convert -p -f qcow2 -O raw \
  /mnt/nas-mount/templates/win11-template.qcow2 \
  iscsi://san.lambertlab.us/iqn.2026-09.us.lambertlab:win11-boot/0
```

#### Technical Flag Specifications & Architectural Advantages

| Parameter | Technical Function & Architectural Role |
| :--- | :--- |
| **`convert`** | Core QEMU conversion engine; decompresses zlib clusters and writes sequential raw sectors to the destination LUN. |
| **`-p`** | **Real-Time Progress Tracking**: Renders dynamic byte transfer and percentage completion indicators `(XX.XX/100%)`. |
| **`-f qcow2`** | **Input Driver Specification**: Enforces QCOW2 format parsing, decoding internal cluster maps and decompression tables. |
| **`-O raw`** | **Output Target Architecture**: Emits flat, uncompressed sector arrays directly to the target storage medium. |
| **`iscsi://...`** | **Direct User-Space iSCSI Protocol**: Connects directly to the TerraMaster SAN via `libiscsi` over TCP port 3260, streaming raw blocks starting at Sector 0 without host kernel initiator logins. |

> [!TIP]
> **Why Direct iSCSI Ingestion is Preferred for Large Workstations:**
> 1. **Bypasses Ingress Timeouts**: Completely avoids Traefik HTTP connection timeouts on massive multi-gigabyte transfers.
> 2. **Eliminates Longhorn Scratch Overhead**: CDI requires a matching ephemeral scratch volume (64+ GiB) to stage QCOW2 conversions; `qemu-img` streams and converts on the fly with zero intermediate disk allocation.
> 3. **Guaranteed Sector-0 Overwrite**: Writes raw sectors directly over any prior partition tables, EFI bootloaders, and NTFS structures, ensuring a completely clean OS state without needing manual zero-wipes.
> 4. **Storage Lock Pre-requisite**: Always ensure the target VM is stopped (`virtctl stop <vm>`) and any lingering upload pods are cleared before flashing to avoid SCSI reservation conflicts.

---

### Phase 4: Declarative Specialization & Identity Management

When a newly cloned instance powers on, KubeVirt mounts a synthetic CD-ROM containing an unattended answer file (`unattend.xml`) stored in a Kubernetes Secret (`win11-unattend-secret`). This orchestrates full end-to-end OS specialization without human intervention.

```yaml
devices:
  disks:
    - name: boot-disk
      disk:
        bus: virtio
      bootOrder: 1
    - name: sysprep-disk
      cdrom:
        bus: sata
volumes:
  - name: boot-disk
    persistentVolumeClaim:
      claimName: win11-boot-pvc
  - name: sysprep-disk
    sysprep:
      secret:
        name: win11-unattend-secret
```

#### The Two-Pass Unattended Pipeline:

1. **`specialize` Configuration Pass**:
   * **Dynamic DNS Bootstrap**: Executes synchronous PowerShell commands to point the active network adapter directly to the Domain Controller, ensuring immediate Active Directory SRV record discoverability.
   * **Unique Hostname Attribution**: Generates a dynamic unique machine identity (`ComputerName: *`), emitting native `WIN-XXXXXXXX` hostnames on every specialization to prevent Active Directory account collisions and stale DNS records.
   * **Automated Domain Enrollment**: Leverages `Microsoft-Windows-UnattendedJoin` backed by a least-privilege service account (`svc_domainjoin`) to authenticate against Kerberos and enroll the machine into the target Organizational Unit (`OU=Desktops,OU=LambertLab,DC=ad,DC=lambertlab,DC=us`).

2. **`oobeSystem` Configuration Pass**:
   * **Automated Regional Settings**: Pre-configures `InputLocale`, `SystemLocale`, `UILanguage`, and `UserLocale` to `en-US` (`0409:00000409`), bypassing all interactive regional setup screens.
   * **Local Administrator & LAPS Setup**: Provisions a dedicated local administrator account (`lapsadmin`) pre-configured for automated management via Windows Local Administrator Password Solution (LAPS).
   * **Remote Management Bootstrap**: Injects `FirstLogonCommands` executing `Enable-PSRemoting -Force` to establish WinRM access for centralized configuration management.
   * **OOBE Wizard Suppression**: Disables EULA confirmation, privacy question prompts, Microsoft account requirements, and network selection dialogues, dropping directly to the domain logon console.

