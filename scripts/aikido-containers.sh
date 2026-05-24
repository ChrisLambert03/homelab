#!/usr/bin/env bash
# aikido-containers.sh - A script to list containers and their open critical/high issues via Aikido API
# Usage: AIKIDO_CLIENT_ID=xxx AIKIDO_CLIENT_SECRET=xxx ./aikido-containers.sh

set -euo pipefail

BASE_URL="https://app.aikido.dev/api/public/v1"

# 1. Authenticate with Aikido using OAuth2 Client Credentials
# This produces a Bearer token used for subsequent API calls.
CREDENTIALS=$(echo -n "${AIKIDO_CLIENT_ID}:${AIKIDO_CLIENT_SECRET}" | base64 -w 0)

TOKEN=$(curl -sf \
  -X POST "https://app.aikido.dev/api/oauth/token" \
  -H "Authorization: Basic ${CREDENTIALS}" \
  -H "Content-Type: application/json" \
  -d '{"grant_type":"client_credentials"}' \
  | jq -r '.access_token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "ERROR: Failed to get access token" >&2
  exit 1
fi

echo "✓ Authenticated"

# 2. List all containers
# Fetches the first 100 container repositories linked to the Aikido account.
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CONTAINERS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONTAINERS=$(curl -sf \
  -X GET "${BASE_URL}/containers?per_page=100" \
  -H "Authorization: Bearer ${TOKEN}")

# Print container list in a readable table format
echo "$CONTAINERS" | jq -r '.[] | "\(.id)\t\(.name)\t\(.tag // "N/A")"' \
  | column -t -s $'\t'

# 3. Fetch open issues for each container
# Iterates through the list of containers to check for high and critical vulnerabilities.
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OPEN ISSUES BY CONTAINER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "$CONTAINERS" | jq -r '.[].id' | while read -r container_id; do
  NAME=$(echo "$CONTAINERS" | jq -r ".[] | select(.id == $container_id) | .name")
  echo ""
  echo "▶ $NAME"

  # API call to export open issues with specific filters for severity
  ISSUES=$(curl -sf \
    -X GET "${BASE_URL}/issues/export?filter_container_repo_id=${container_id}&filter_status=open&filter_severities=critical,high" \
    -H "Authorization: Bearer ${TOKEN}")

  COUNT=$(echo "$ISSUES" | jq 'length')

  if [[ "$COUNT" -eq 0 ]]; then
    echo "  No critical/high issues"
  else
    echo "  Found $COUNT critical/high issue(s):"
    echo "$ISSUES" | jq -r '.[] | "  [\(.severity | ascii_upcase)] \(.title)"'
  fi
done
