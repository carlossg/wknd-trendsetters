#!/usr/bin/env bash
# Import content from paolomoz/wknd-ts-1 to carlossg/wknd-trendsetters on da.live
#
# Usage:
#   1. Create a .env file in the project root with DA_TOKEN=<your-token>
#   2. Run: bash tools/import-content.sh
#
# Prerequisites: curl, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load token from .env
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/.env"
fi

if [[ -z "${DA_TOKEN:-}" ]]; then
  echo "Error: DA_TOKEN not set. Add it to .env or export it." >&2
  exit 1
fi

SOURCE_ORG="paolomoz"
SOURCE_REPO="wknd-ts-1"
TARGET_ORG="carlossg"
TARGET_REPO="wknd-trendsetters"
API_BASE="https://admin.da.live"
AUTH_HEADER="Authorization: Bearer $DA_TOKEN"

echo "Listing content from $SOURCE_ORG/$SOURCE_REPO..."

# Recursively list and copy all content
copy_path() {
  local path="$1"

  local listing
  listing=$(curl -sf -H "$AUTH_HEADER" "$API_BASE/list/$SOURCE_ORG/$SOURCE_REPO$path") || {
    echo "  Failed to list: $path" >&2
    return 0
  }

  # Process each item in the listing
  echo "$listing" | jq -r '.[] | "\(.name)\t\(.ext // "")"' | while IFS=$'\t' read -r name ext; do
    local item_path="${path}${name}"

    if [[ -z "$ext" ]]; then
      # Directory — recurse
      echo "Entering directory: $item_path/"
      copy_path "${item_path}/"
    else
      # File — download and upload
      echo "  Copying: ${item_path}.${ext}"

      local tmp
      tmp=$(mktemp)

      if curl -sf -H "$AUTH_HEADER" -o "$tmp" "$API_BASE/source/$SOURCE_ORG/$SOURCE_REPO${item_path}.${ext}"; then
        local status
        status=$(curl -sf -o /dev/null -w "%{http_code}" \
          -X PUT \
          -H "$AUTH_HEADER" \
          -H "Content-Type: application/octet-stream" \
          --data-binary "@$tmp" \
          "$API_BASE/source/$TARGET_ORG/$TARGET_REPO${item_path}.${ext}") || status="failed"

        if [[ "$status" == 2* ]]; then
          echo "    OK ($status)"
        else
          echo "    Upload returned: $status" >&2
        fi
      else
        echo "    Download failed" >&2
      fi

      rm -f "$tmp"
    fi
  done
}

copy_path "/"
echo "Import complete."
