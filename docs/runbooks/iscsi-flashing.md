# Runbook: High-Speed Direct iSCSI Flashing (`qemu-img`)

This runbook documents the procedure for flashing KubeVirt virtual machine boot disks directly to TerraMaster SAN iSCSI target LUNs at line-rate speed.

---

## ⚡ Why Direct User-Space iSCSI Flashing?

### The Traditional Bottleneck (CDI Uploads)
Standard KubeVirt image uploads using `virtctl image-upload` route through the Kubernetes Containerized Data Importer (CDI) and the Traefik ingress controller:
* CDI provisions an intermediate 64 GB Longhorn scratch volume on physical host SSDs.
* Uploading large 25+ GB images triggers Traefik HTTP proxy idle timeouts (`unexpected EOF`).
* Host disks are subjected to heavy write amplification and scratch volume allocation locks (`Multi-Attach error for volume`).

### The High-Speed Solution: `libiscsi`
`qemu-img` natively supports user-space iSCSI protocols through `libiscsi`. By writing directly from the NAS template storage into the iSCSI block target LUN:
* **Zero scratch volumes** are allocated on Kubernetes nodes.
* **Zero ingress timeouts** because data transfers over a direct TCP socket.
* Flashing completes in **2–3 minutes** at full gigabit line rate.

---

## 🛠️ Step-by-Step Flashing Procedure

### 1. Identify Target SAN LUN
Ensure the target LUN is mapped on the TerraMaster SAN (`san.lambertlab.us`):
* IQN: `iqn.2026-09.us.lambertlab:win11-boot`
* LUN ID: `0`

### 2. Execute Direct `qemu-img convert`
Run the conversion directly from the node with access to the template store:

```bash
qemu-img convert -p -f qcow2 -O raw \
  /mnt/nas-mount/templates/win11-template.qcow2 \
  iscsi://san.lambertlab.us/iqn.2026-09.us.lambertlab:win11-boot/0
```

### Flag Breakdown
* `-p`: Displays real-time percentage progress bar.
* `-f qcow2`: Specifies input format (compressed QCOW2 template).
* `-O raw`: Converts output directly to raw uncompressed block format on the LUN.
* `iscsi://...`: Direct user-space iSCSI connection string bypassing host kernel iscsiadm initiator logins.

---

## 🔄 Post-Flash Boot Procedure

Once the flash completes:
1. Start or restart the KubeVirt virtual machine:
   ```bash
   virtctl start win11-01
   ```
2. Monitor boot console via VNC or serial console:
   ```bash
   virtctl vnc win11-01
   ```
3. Windows 11 will automatically execute the generalized Sysprep specialization phase using the declarative `win11-unattend-secret`.
