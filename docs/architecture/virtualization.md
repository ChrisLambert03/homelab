# Cloud-Native Virtualization Architecture (KubeVirt)

The **LambertLab** virtualization architecture leverages **KubeVirt v1.9.0** and the **Containerized Data Importer (CDI v1.66.0)** to converge traditional monolithic operating systems (Windows Server 2025, Windows 11 Enterprise, FreeBSD/OPNsense) and cloud-native container workloads into a **single, unified declarative control plane**.

---

## 🏛️ KubeVirt Lifecycle & Storage Architecture

```mermaid
graph TD
    subgraph MasterTemplate["1. Immutable Master Template"]
        RefVM["Reference Windows 11 VM"] -->|"Sysprep /generalize /oobe"| SealedDisk["Sealed iSCSI Block LUN"]
        SealedDisk -->|"qemu-img convert -c<br/>User-Space libiscsi"| QCOW2["win11-template.qcow2<br/>Compressed Master Store"]
    end

    subgraph DirectFlashing["2. Line-Rate Target Flashing"]
        QCOW2 -->|"qemu-img convert -O raw<br/>Direct TCP 3260 socket"| SANLUN[("Target iSCSI LUN<br/>san.lambertlab.us:3260")]
    end

    subgraph KubernetesKubeVirt["3. Declarative KubeVirt VM Boot"]
        Secret["win11-unattend-secret<br/>Declarative unattend.xml"] -->|"Synthetic CD-ROM"| KVM["QEMU / KVM Guest Engine"]
        SANLUN -->|"VirtIO SCSI Bus viostor"| KVM
        TPMVol[("Persistent Longhorn Volume")] -->|"swtpm State Storage"| KVM
        Multus["Multus CNI: ovn-ad-vpc<br/>(managedTap binding)"] -->|"VirtIO Net NetKVM"| KVM
        KVM --> WinOS["Windows 11 Enterprise LTSC<br/>Dynamic WIN-* Domain Joined"]
    end
```

---

## 📦 Virtualized Machine Portfolio

| Virtual Machine | Operating System | vCPU / RAM | Storage Backend | Network Interface | Primary Role |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`win11`** | Windows 11 Enterprise LTSC | 4 vCPU / 8 GiB | 64 GB SAN iSCSI LUN | `ovn-ad-vpc` (Geneve / `managedTap`) | Domain-Joined Dedicated Admin Workstation |
| **`dc01`** | Windows Server 2025 | 4 vCPU / 8 GiB | 80 GB SAN iSCSI LUN | `ovn-ad-vpc` (Geneve / `managedTap`) | Primary Active Directory Domain Controller (`ad.lambertlab.us`) |
| **`opnsense`** | FreeBSD 14 / OPNsense | 4 vCPU / 4 GiB | Distributed Longhorn Block | `ovn-ad-vpc` (`managedTap`) + Pod Masquerade | Edge Gateway, NAT & Security Firewall |

---

## 🔬 Hypervisor Tuning & Windows 11 Hardware Compliance

Deploying Windows 11 under KVM requires strict hardware attestation compliance and specialized low-level hypervisor flags:

### 1. OVMF UEFI Secure Boot & Persistent vTPM 2.0
Windows 11 strictly enforces UEFI Secure Boot and a Trusted Platform Module (TPM 2.0):

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

* **`efi.secureBoot: true`:** Boots using Open Virtual Machine Firmware (OVMF) compiled with standard Microsoft Authenticode keys.
* **`efi.persistent: true`:** Persists EFI NVRAM variables across pod reboots, preventing bootloader priority loss.
* **`features.smm.enabled: true`:** System Management Mode emulation in QEMU, required by OVMF to safeguard the Secure Boot keystore from guest OS tampering.
* **`devices.tpm.persistent: true`:** Emulates a TPM 2.0 cryptographic chip using `swtpm`, backing its state volume with **Longhorn** distributed storage so BitLocker keys and Platform Configuration Registers (PCRs) survive VM migrations and host reboots.

---

### 2. Multi-vCPU Hyper-V Hypercall Optimizations
To eliminate hypervisor context switching and CPU core contention across the 4 vCPUs, KubeVirt exposes KVM's synthetic Hyper-V hypercall suite:

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

* **`tlbflush` & `ipi`:** Allows the Windows kernel to issue synthetic hypercalls for Translation Lookaside Buffer (TLB) flushes and Inter-Processor Interrupts (IPIs) across all virtual cores simultaneously, bypassing standard emulated APIC bottlenecks.
* **`synictimer.direct: {}`:** Delivers synthetic timer messages directly into guest architectural registers, avoiding costly VM exits.
* **`relaxed`:** Relaxes guest watchdog constraints during high host load, completely eliminating false-positive `CLOCK_WATCHDOG_TIMEOUT` Blue Screens of Death (BSOD).
* **`spinlocks (8191)`:** Forces Windows to yield execution after 8,191 failed spinlock attempts, avoiding wasteful thread spinning on contested locks.

---

### 3. Hardware Clocks & Timer Drift Prevention
Windows assumes physical hardware Real-Time Clocks (RTC) run in local time rather than UTC:

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

* **`timezone: "America/New_York"`:** Offsets the emulated RTC directly to Eastern Time, eliminating automatic 4/5-hour time skews upon guest boot.
* **`hpet (present: false)`:** Disables high-overhead High Precision Event Timer emulation in favor of the hypervisor's invariant TSC (Time Stamp Counter).

---

## ⚡ Automated Sysprep Specialization Lifecycle

To achieve zero-touch desktop provisioning, master images are generalized via Microsoft Sysprep and customized on first boot using an unattended answer file:

### Phase 1: Machine Sealing
From an elevated prompt in the reference VM:
```cmd
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown
```
This purges the unique Machine SID, clears device driver databases, resets the event logging engine, and flags the Out-of-Box Experience (OOBE) for automated processing.

### Phase 2: Direct Line-Rate Flashing via `qemu-img`
Rather than uploading templates through Kubernetes CDI (which requires 64GB Longhorn scratch volumes and often triggers HTTP proxy timeouts on 25+ GB disks), the template is flashed directly to the SAN iSCSI target LUN using `libiscsi`:

```bash
qemu-img convert -p -f qcow2 -O raw \
  /mnt/nas-mount/templates/win11-template.qcow2 \
  iscsi://san.lambertlab.us/iqn.2026-09.us.lambertlab:win11-boot/0
```

### Phase 3: Declarative Specialization (`unattend.xml`)
The VM manifest mounts a Kubernetes Secret containing a declarative `unattend.xml` answer file as a virtual CD-ROM:
* **Dynamic Computer Naming:** Configured with `<ComputerName>*</ComputerName>`, prompting Windows setup to generate a random `WIN-XXXXXXXX` NetBIOS name, preventing computer object collisions in Active Directory.
* **Automated Domain Join:** Uses a restricted service account (`svc_domainjoin`) with delegated rights to place computer accounts into `OU=Computers,OU=LambertLab,DC=ad,DC=lambertlab,DC=us`.
* **Regional & OOBE Bypass:** Automatically suppresses EULA prompts, telemetry questions, Microsoft Account (MSA) login screens, and configures the default local administrator account.

---

## 🛡️ Workload Resilience & Network Partition Tolerations

To balance high availability during network partitions with manual guest power management:

* **Intentional Power Management (`runStrategy: RerunOnFailure`):** Virtual machines utilize `RerunOnFailure` rather than `Always`. This permits administrators to cleanly power down machines from within the guest OS (e.g., Windows Shutdown, OPNsense Halt) or via `virtctl stop` without the controller fighting the shutdown and immediately rebooting the VM.
* **Network Partition Defense (Node Tolerations):** Because VMs run on `workstation` with non-migratable local SAN iSCSI LUN bindings (`RWO`), temporary network partitions or control-plane failovers (such as Tailscale mesh reconvergence) must not trigger premature pod eviction. All VMs declare extended `tolerationSeconds` (1800s / 30 minutes):

```yaml
tolerations:
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 1800
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 1800
```

This prevents Kubernetes `NodeLifecycleController` from evicting `virt-launcher` pods and triggering unintended ACPI guest shutdown signals during transient control-plane blips, keeping VMs continuously operational on the worker host.

---

## 🌐 Kube-OVN Geneve Overlay & `managedTap` Binding

To enable KubeVirt virtual machines on Wi-Fi worker nodes (`workstation`) to communicate over Layer 2 without relying on physical multicast bridging, the cluster integrates **Kube-OVN** in secondary CNI mode alongside KubeVirt's **`managedTap`** network binding plugin:

### Why `managedTap` is Essential for DHCP
* **Standard Bridge DHCP Interception:** In default KubeVirt `bridge: {}` mode, `virt-launcher` intercepts guest DHCP requests and serves dummy leases, preventing external/overlay DHCP engines from providing custom options.
* **`managedTap` Plugin:** Introduced in KubeVirt v1.4+, `managedTap` creates a direct tap device wired to the pod interface without intercepting DHCP or IPv6 RA packets. This allows Kube-OVN's OVN hypervisor engine to deliver:
  * Dynamic IP allocation (`10.10.0.0/24`)
  * Default gateway routing to OPNsense (`10.10.0.1`)
  * Active Directory DNS server delivery (`10.10.0.10` -> `dc01`)


