#!/usr/bin/env bash
set -euo pipefail
ROOT="/root/manager-workspace"
REPO="${ROOT}/persistent-history"
KEY="${ROOT}/secrets/github-newhiclaw58-deploy"
cd "${REPO}"
# Use SSH deploy key for push, then restore clean HTTPS remote.
git remote set-url origin git@github.com:laobanliu62-design/newhiclaw5.8.git
if [ -f "${KEY}" ]; then
  GIT_SSH_COMMAND="ssh -i ${KEY} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" "${REPO}/scripts/sync-manager-history.sh"
else
  echo "Missing deploy key: ${KEY}" >&2
  exit 1
fi
git remote set-url origin https://github.com/laobanliu62-design/newhiclaw5.8
