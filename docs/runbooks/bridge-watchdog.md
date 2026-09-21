# Runbook: L2 Bridge Watchdog Self-Healing

This runbook covers the background, diagnosis, and automated self-healing architecture for the **`br-lab0`** multicast VXLAN bridge network.

---

## ⚠️ The Problem: USB NIC Boot Latency & Bridge Carrier Loss

### Symptoms
After physical node reboots (specifically on worker nodes like `opti74`), virtual machines and pods communicating across the `10.10.0.0/24` subnet reported loss of connectivity:
* Apache Guacamole failed to connect to Windows 11 (`win11-01.ad.lambertlab.us:3389`).
* CoreDNS forwarders timed out reaching `dc01.ad.lambertlab.us` (`10.10.0.10`).

### Root Cause Diagnosis
When `opti74` reboots, its external USB 3.0 Ethernet adapter (`enx00e04c68b94d`) enumerates asynchronously in the Linux kernel. If NetworkManager / NMState applies bridge policies *before* the USB controller has fully established physical link carrier:
1. `br-lab0` enters a `NO-CARRIER` / `DOWN` state.
2. The virtual tunnel endpoint `vxlan-lab` becomes detached from `master br-lab0`.
3. Because NetworkManager does not continuously retry enslavement, the node remains severed from the L2 broadcast domain indefinitely.

---

## 🛠️ Automated Solution: `bridge-watchdog` DaemonSet

To prevent manual intervention after reboots, a lightweight Kubernetes DaemonSet continuously polls link enslavement across all Linux nodes.

### Live Manifest

The documentation below is embedded directly from the repository source file:

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: bridge-watchdog
  namespace: kube-system
  labels:
    app: bridge-watchdog
spec:
  selector:
    matchLabels:
      app: bridge-watchdog
  template:
    metadata:
      labels:
        app: bridge-watchdog
    spec:
      hostNetwork: true
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
        - operator: Exists
      containers:
        - name: watchdog
          image: busybox:1.37
          securityContext:
            privileged: true
          volumeMounts:
            - name: tz-config
              mountPath: /etc/localtime
              readOnly: true
          command:
            - sh
            - -c
            - |
              while true; do
                if ! ip link show vxlan-lab 2>/dev/null | grep -q "master br-lab0"; then
                  echo "$(date): Re-attaching vxlan-lab to br-lab0"
                  ip link set vxlan-lab master br-lab0
                  ip link set br-lab0 up
                fi
                sleep 15
              done
      volumes:
        - name: tz-config
          hostPath:
            path: /etc/localtime
```

---

## 🔍 How It Works

1. **Host Network & Privileges:** Runs with `hostNetwork: true` and `privileged: true` to access host network namespaces.
2. **Deterministic Check:** Every 15 seconds, the watchdog inspects the kernel interface status:
   ```bash
   ip link show vxlan-lab | grep "master br-lab0"
   ```
3. **Automated Re-Enslavement:** If `vxlan-lab` is found un-enslaved, the container immediately executes:
   ```bash
   ip link set vxlan-lab master br-lab0
   ip link set br-lab0 up
   ```
4. **Zero Overhead:** Employs Alpine BusyBox (`1.37`). It remains completely silent when healthy to prevent log spam, emitting timestamps matching the host's `/etc/localtime`.
