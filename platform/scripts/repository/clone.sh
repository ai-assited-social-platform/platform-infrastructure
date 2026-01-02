#!/usr/bin/env bash
set -euo pipefail

ORG="ai-assited-social-platform"

ROOT_DIR="$(cd "$(dirname "$0")/../../.."; pwd)"

SERVICES_DIR="$ROOT_DIR/services"
WORKERS_DIR="$ROOT_DIR/workers"
APPS_DIR="$ROOT_DIR/apps"

echo "ROOT_DIR: $ROOT_DIR"
echo "Services: $SERVICES_DIR"
echo "Workers : $WORKERS_DIR"
echo "Apps    : $APPS_DIR"
echo ""

# Ensure base dirs exist
mkdir -p "$SERVICES_DIR" "$WORKERS_DIR" "$APPS_DIR"

SERVICES=(
  api-gateway
  auth-service
  user-service
  chat-service
  voice-call-service
  post-service
  feed-service
  events-service
  notifications-service
  search-service
  media-service
  admin-service
  audit-service
  ai-orchestrator-service
)

WORKERS=(
  ai-worker
)

APPS=(
  web-app
)

clone_missing() {
  local base_dir="$1"; shift
  local repos=("$@")

  for repo in "${repos[@]}"; do
    local target="$base_dir/$repo"
    local url="https://github.com/${ORG}/${repo}.git"

    if [[ -d "$target/.git" ]]; then
      echo "✔ Already cloned: $repo"
    elif [[ -d "$target" ]]; then
      echo "⚠ Folder exists but not a git repo: $target"
      echo "   Skipping. (Delete folder or init git manually.)"
    else
      echo "⬇ Cloning: $repo"
      git clone "$url" "$target"
    fi
  done
}

echo "=== SERVICES ==="
clone_missing "$SERVICES_DIR" "${SERVICES[@]}"
echo ""

echo "=== WORKERS ==="
clone_missing "$WORKERS_DIR" "${WORKERS[@]}"
echo ""

echo "=== APPS ==="
clone_missing "$APPS_DIR" "${APPS[@]}"
echo ""

echo "✅ Done."
