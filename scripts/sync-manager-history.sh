#!/usr/bin/env bash
set -euo pipefail
ROOT="/root/manager-workspace"
REPO="${ROOT}/persistent-history"
TODAY_UTC="$(date -u +%F)"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "${REPO}/logs" "${REPO}/snapshots"

redact() {
  sed -E \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(access[_-]?token["=:[:space:]]+)[^"[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(api[_-]?key["=:[:space:]]+)[^"[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(password["=:[:space:]]+)[^"[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(gh[pousr]_[A-Za-z0-9_]{20,})/[REDACTED_GITHUB_TOKEN]/g'
}

{
  echo "# Manager Log ${TODAY_UTC}"
  echo
  echo "> Synced at ${NOW_UTC}. Sensitive fields redacted."
  echo
  if [ -f "${ROOT}/memory/${TODAY_UTC}.md" ]; then
    redact < "${ROOT}/memory/${TODAY_UTC}.md"
  else
    echo "No daily memory file found for ${TODAY_UTC}."
  fi
} > "${REPO}/logs/${TODAY_UTC}.md"

if [ -f "${ROOT}/state.json" ]; then
  jq '{active_tasks:(.active_tasks // []), updated_at, admin_dm_room_id}' "${ROOT}/state.json" > "${REPO}/snapshots/state.json"
fi

if command -v hiclaw >/dev/null 2>&1; then
  hiclaw get workers -o json > "${REPO}/snapshots/workers.json" 2>/dev/null || echo '{"workers":[],"total":0,"error":"hiclaw get workers failed"}' > "${REPO}/snapshots/workers.json"
fi

{
  echo "# Sync Status"
  echo
  echo "- Last synced UTC: ${NOW_UTC}"
  echo "- Source memory: ${ROOT}/memory/${TODAY_UTC}.md"
  echo "- Source state: ${ROOT}/state.json"
  echo "- Policy: sanitized logs only; secrets and raw runtime configs excluded."
} > "${REPO}/snapshots/last-sync.md"

cd "${REPO}"
git add README.md .gitignore logs snapshots scripts
if git diff --cached --quiet; then
  echo "NO_CHANGES"
else
  git commit -m "sync manager history ${NOW_UTC}"
  git push origin HEAD
fi
