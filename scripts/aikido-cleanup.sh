#!/usr/bin/env bash
# scripts/aikido-cleanup.sh - Cleanup stale image IDs from local state and Aikido (logic only)
# Usage: AIKIDO_CLIENT_ID=xxx AIKIDO_CLIENT_SECRET=xxx ./scripts/aikido-cleanup.sh

set -euo pipefail

STATE_FILE="$HOME/.aikido_scanned_images"
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

# 1. Authenticate with Aikido (if credentials provided)
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
    log_info "Aikido credentials not provided. Skipping API-based cross-check."
    TOKEN=""
fi

# 2. Collect all active Image IDs from all Docker contexts
log_header "COLLECTING ACTIVE IMAGE IDS"
ACTIVE_IMAGES=$(mktemp)

for ctx in "${CONTEXTS[@]}"; do
    log_info "Querying context: $ctx..."
    # Get short IDs and full IDs to be safe
    docker --context "$ctx" images --format "{{.ID}}" >> "$ACTIVE_IMAGES" || log_error "Failed to query context $ctx"
done

# Deduplicate
sort -u "$ACTIVE_IMAGES" -o "$ACTIVE_IMAGES"
ACTIVE_COUNT=$(wc -l < "$ACTIVE_IMAGES")
log_info "Found $ACTIVE_COUNT unique active images across all hosts."

# 3. Cleanup local state file (~/.aikido_scanned_images)
if [[ -f "$STATE_FILE" ]]; then
    log_header "CLEANING UP LOCAL STATE FILE"
    STALE_STATE=$(mktemp)
    
    # Identify IDs in state file that are NOT in the active list
    while read -r image_id; do
        # Check if the image_id (or a prefix) exists in ACTIVE_IMAGES
        if ! grep -q "^$image_id" "$ACTIVE_IMAGES"; then
            echo "$image_id" >> "$STALE_STATE"
        fi
    done < "$STATE_FILE"

    STALE_COUNT=$(wc -l < "$STALE_STATE")
    if [[ "$STALE_COUNT" -gt 0 ]]; then
        log_info "Found $STALE_COUNT stale image IDs in $STATE_FILE."
        while read -r stale_id; do
            log_info "Removing stale ID: $stale_id"
            sed -i "/^$stale_id$/d" "$STATE_FILE"
        done < "$STALE_STATE"
    else
        log_info "Local state file is clean."
    fi
    rm "$STALE_STATE"
else
    log_info "No local state file found at $STATE_FILE."
fi

# 4. Cross-check with Aikido (if authenticated)
if [[ -n "$TOKEN" ]]; then
    log_header "AIKIDO API CROSS-CHECK"
    
    # Fetch all containers from Aikido
    CONTAINERS=$(curl -sf \
      -X GET "${BASE_URL}/containers?per_page=100" \
      -H "Authorization: Bearer ${TOKEN}")

    # Note: Aikido usually tracks by Repository:Tag. 
    # To map to Image IDs, we'd need more metadata or just look for Repo:Tags that aren't active.
    
    log_info "Fetching active Repo:Tags..."
    ACTIVE_TAGS=$(mktemp)
    for ctx in "${CONTEXTS[@]}"; do
        docker --context "$ctx" images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" >> "$ACTIVE_TAGS" || true
    done
    sort -u "$ACTIVE_TAGS" -o "$ACTIVE_TAGS"

    echo "Aikido Entry        Status"
    echo "------------------  ----------"
    
    echo "$CONTAINERS" | jq -r '.[] | "\(.name):\(.tag // "latest") \(.id)"' | while read -r name id; do
        if grep -q "^$name$" "$ACTIVE_TAGS"; then
            printf "%-18s %s\n" "$name" "ACTIVE"
        else
            printf "%-18s %s\n" "$name" "STALE (Not on hosts)"
            # Aikido API doesn't obviously expose a 'delete' endpoint in the public docs usually provided 
            # in these scenarios, so we just report it for now.
        fi
    done
    
    rm "$ACTIVE_TAGS"
fi

rm "$ACTIVE_IMAGES"
log_header "CLEANUP COMPLETE"
