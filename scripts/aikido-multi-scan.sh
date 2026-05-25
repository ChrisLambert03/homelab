#!/bin/bash

# ==============================================================================
# Aikido Multi-Node Image Scanner
# ------------------------------------------------------------------------------
# This script iterates through ALL nodes in the [docker_hosts] inventory,
# SSHs into each, and runs the Aikido local scanner on unique Docker images.
# ==============================================================================

# --- Configuration ---
INVENTORY_FILE="$1"
AIKIDO_API_KEY="$2"
STATE_FILE="$HOME/.aikido_scanned_images"
SCANNER_PATH="/usr/local/bin/aikido-local-scanner"
FAILED_SCANS=0

# --- Helper Functions ---

log_header() {
    echo "================================================================================"
    echo "  $1"
    echo "================================================================================"
}

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# --- Validation ---
if [[ -z "$INVENTORY_FILE" || -z "$AIKIDO_API_KEY" ]]; then
    log_error "Usage: $0 <inventory_file> <aikido_api_key>"
    exit 1
fi

if [[ ! -f "$INVENTORY_FILE" ]]; then
    log_error "Inventory file not found: $INVENTORY_FILE"
    exit 1
fi

touch "$STATE_FILE"

# --- Main Logic ---

# 1. Parse Inventory
log_info "Parsing inventory: $INVENTORY_FILE"
# Extract hostnames from [docker_hosts] section
nodes=$(grep -A 100 "\[docker_hosts\]" "$INVENTORY_FILE" | grep -v "\[" | grep -v "^$" | awk '{print $1}')

if [[ -z "$nodes" ]]; then
    log_error "No nodes found in [docker_hosts] section of $INVENTORY_FILE"
    exit 1
fi

for node in $nodes; do
    log_header "Processing Node: $node"

    # 2. Retrieve Docker Images from Node
    log_info "Fetching image list from $node..."
    # We use -n for SSH to prevent it from reading from stdin
    get_images_cmd="docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' | grep -v '<none>' | sort -u"
    
    images=$(ssh -n -o StrictHostKeyChecking=no "$node" "$get_images_cmd" 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        log_error "Could not connect to $node via SSH. Skipping."
        FAILED_SCANS=1
        continue
    fi

    if [[ -z "$images" ]]; then
        log_info "No images found on $node."
        continue
    fi

    # 3. Scan Images
    while read -r image_id image_name; do
        [[ -z "$image_id" ]] && continue

        # Check if already scanned (shared STATE_FILE on runner)
        if grep -q "^$image_id$" "$STATE_FILE"; then
            log_info "Skipping $image_name ($image_id) - Already scanned."
            continue
        fi

        log_info "Scanning $image_name ($image_id) on $node..."
        
        # Execute scan on the remote node
        # Pass API key via env and use -n to prevent SSH from consuming stdin of the while loop
        scan_cmd="AIKIDO_API_KEY=\"$AIKIDO_API_KEY\" $SCANNER_PATH image-scan \"$image_name\" --apikey \"$AIKIDO_API_KEY\""
        
        # Capture stdout and stderr to check for silent errors
        scan_output=$(ssh -n -o StrictHostKeyChecking=no "$node" "$scan_cmd" 2>&1)
        exit_code=$?
        
        # Print output for visibility in workflow logs
        echo "$scan_output"
        
        # Check for non-zero exit code OR known error strings that the scanner might swallow
        if [[ $exit_code -eq 0 ]] && ! echo "$scan_output" | grep -qiE "unexpected went wrong|ECONNRESET|socket hang up"; then
            echo "$image_id" >> "$STATE_FILE"
            log_info "Scan successful for $image_name."
        else
            log_error "Scan failed for $image_name on $node."
            FAILED_SCANS=1
        fi

        # Add a short delay to give the API time to process
        sleep 1
    done <<< "$images"
done

log_header "Scan Summary"
if [[ $FAILED_SCANS -eq 0 ]]; then
    log_info "All nodes scanned successfully."
    exit 0
else
    log_error "Some scans failed. Check logs for details."
    exit 1
fi
