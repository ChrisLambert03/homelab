#!/usr/bin/env bash
# scripts/aikido-cleanup.sh - Cleanup stale image IDs from Aikido dashboard
# Usage: AIKIDO_CLIENT_ID=xxx AIKIDO_CLIENT_SECRET=xxx ./scripts/aikido-cleanup.sh

set -euo pipefail

BASE_URL="https://app.aikido.dev/api/public/v1"
CONTEXTS=("default" "opti74" "optiplex" "workstation-engine")

# --- Helper Functions ---

log_header() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

ensure_contexts() {
    log_header "ENSURING DOCKER CONTEXTS"
    
    # Define context endpoints
    declare -A endpoints=(
        ["opti74"]="tcp://opti74:2376"
        ["optiplex"]="tcp://optiplex:2376"
        ["workstation-engine"]="tcp://workstation:2376"
    )

    for name in "${!endpoints[@]}"; do
        if ! docker context inspect "$name" > /dev/null 2>&1; then
            log_info "Creating missing context: $name -> ${endpoints[$name]}"
            docker context create "$name" --docker "host=${endpoints[$name]}" > /dev/null
        else
            log_info "Context already exists: $name"
        fi
    done
}

# 1. Authenticate with Aikido
if [[ -n "${AIKIDO_CLIENT_ID:-}" && -n "${AIKIDO_CLIENT_SECRET:-}" ]]; then
    CREDENTIALS=$(echo -n "${AIKIDO_CLIENT_ID}:${AIKIDO_CLIENT_SECRET}" | base64 -w 0)

    TOKEN=$(curl -sf \
      -X POST "https://app.aikido.dev/api/oauth/token" \
      -H "Authorization: Basic ${CREDENTIALS}" \
      -H "Content-Type: application/json" \
      -d '{"grant_type":"client_credentials"}' \
      | jq -r '.access_token')

    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
      log_error "Failed to get access token"
      exit 1
    fi
    log_info "Authenticated with Aikido"
else
    log_error "Aikido credentials not provided. AIKIDO_CLIENT_ID and AIKIDO_CLIENT_SECRET are required."
    exit 1
fi

# Ensure contexts exist before querying
ensure_contexts

# 2. Collect all active Repo:Tags from all Docker contexts
log_header "COLLECTING ACTIVE REPO:TAGS"
ACTIVE_TAGS=$(mktemp)

for ctx in "${CONTEXTS[@]}"; do
    log_info "Querying context: $ctx..."
    docker --context "$ctx" images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" >> "$ACTIVE_TAGS" || log_error "Failed to query context $ctx"
done

# Deduplicate
sort -u "$ACTIVE_TAGS" -o "$ACTIVE_TAGS"
ACTIVE_COUNT=$(wc -l < "$ACTIVE_TAGS")
log_info "Found $ACTIVE_COUNT unique active image tags across all hosts."

# 3. Cross-check with Aikido
log_header "AIKIDO API CROSS-CHECK"

# Fetch all containers from Aikido
CONTAINERS=$(curl -sf \
  -X GET "${BASE_URL}/containers?per_page=100" \
  -H "Authorization: Bearer ${TOKEN}")

echo "Aikido Entry        Status"
echo "------------------  ----------"

echo "$CONTAINERS" | jq -r '.[] | "\(.name):\(.tag // "latest") \(.id)"' | while read -r name id; do
    if grep -q "^$name$" "$ACTIVE_TAGS"; then
        printf "%-18s %s\n" "$name" "ACTIVE"
    else
        printf "%-18s %s\n" "$name" "STALE (Not on hosts)"
        # Note: If the API supports deletion, it could be implemented here.
    fi
done

rm "$ACTIVE_TAGS"
log_header "CLEANUP COMPLETE"
