#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $(basename "$0") <image_path> <namespace> <pvc_name>" >&2
  exit 1
fi

IMAGE_PATH="$1"
NAMESPACE="$2"
PVC_NAME="$3"
UPLOAD_PROXY_URL="https://cdi.lambertlab.us"

echo "=========================================================="
echo " Starting KubeVirt VM Image Upload "
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
  --no-create "${@:4}"

echo "----------------------------------------------------------"
echo "✅ Upload completed successfully!"
echo "=========================================================="
