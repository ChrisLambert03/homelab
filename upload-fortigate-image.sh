#!/usr/bin/env bash
set -euo pipefail

IMAGE_PATH="/home/chris/Downloads/FGT_VM64_KVM-v7.6.7.M-build3704-FORTINET.out.kvm/fortios.qcow2"
NAMESPACE="vms"
PVC_NAME="fortigate-boot-pvc"
UPLOAD_PROXY_URL="https://10.43.88.41"

echo "=========================================================="
echo " Starting FortiGate Pure KVM Image Upload to TerraMaster "
echo "=========================================================="
echo "Image:   ${IMAGE_PATH}"
echo "Target:  ${NAMESPACE}/${PVC_NAME}"
echo "Proxy:   ${UPLOAD_PROXY_URL}"
echo "----------------------------------------------------------"

if [[ ! -f "${IMAGE_PATH}" ]]; then
  echo "Error: Image file not found at ${IMAGE_PATH}" >&2
  exit 1
fi

virtctl image-upload pvc "${PVC_NAME}" \
  --namespace "${NAMESPACE}" \
  --image-path="${IMAGE_PATH}" \
  --uploadproxy-url="${UPLOAD_PROXY_URL}" \
  --insecure

echo "----------------------------------------------------------"
echo "✅ Upload completed successfully!"
echo "=========================================================="
