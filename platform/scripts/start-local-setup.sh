    # 1. WSL check (Windows), if not installed, propose suggestion how to install and exit script. 
    # 2. Docker check, if not installed or running, propose suggestion how to install, run and exit script.
    # 3. Clone repositories if not already cloned.
#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config (EDIT org if needed)
# =========================
ORG="ai-assited-social-platform"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SERVICES_DIR="$ROOT_DIR/services"
WORKERS_DIR="$ROOT_DIR/workers"
APPS_DIR="$ROOT_DIR/apps"

SERVICES=(
  "https://github.com/${ORG}/api-gateway.git api-gateway"
  "https://github.com/${ORG}/auth-service.git auth-service"
  "https://github.com/${ORG}/user-profile-service.git user-profile-service"
  "https://github.com/${ORG}/social-graph-service.git social-graph-service"
  "https://github.com/${ORG}/chat-service.git chat-service"
  "https://github.com/${ORG}/voice-call-service.git voice-call-service"
  "https://github.com/${ORG}/post-service.git post-service"
  "https://github.com/${ORG}/feed-service.git feed-service"
  "https://github.com/${ORG}/events-service.git events-service"
  "https://github.com/${ORG}/notifications-service.git notifications-service"
  "https://github.com/${ORG}/search-service.git search-service"
  "https://github.com/${ORG}/media-service.git media-service"
  "https://github.com/${ORG}/admin-service.git admin-service"
  "https://github.com/${ORG}/audit-service.git audit-service"
  "https://github.com/${ORG}/ai-orchestrator-service.git ai-orchestrator-service"
)

WORKERS=(
  "https://github.com/${ORG}/ai-worker.git ai-worker"
)

APPS=(
  "https://github.com/${ORG}/web-app.git web-app"
)

is_windows() {
  [[ "${OS:-}" == "Windows_NT" ]] || uname | grep -qiE 'mingw|msys'
}

# =========================
# 1) WSL check (Windows)
# =========================
if is_windows; then
  if ! command -v wsl >/dev/null 2>&1; then
    echo "❌ WSL is not installed."
    echo ""
    echo "How to install (run PowerShell as Administrator):"
    echo "  wsl --install"
    echo ""
    echo "Then reboot (if prompted) and run this script again."
    exit 1
  fi
  echo "✅ WSL found."
fi

# =========================
# 2) Docker check (installed + daemon running)
# =========================
# if ! command -v docker >/dev/null 2>&1; then
#   echo "❌ Docker is not installed."
#   echo ""
#   echo "Install Docker Desktop for Windows:"
#   echo "  https://www.docker.com/products/docker-desktop/"
#   echo ""
#   echo "After installation:"
#   echo "  1) Start Docker Desktop"
#   echo "  2) Wait until it shows 'Running'"
#   echo "  3) Rerun this script"
#   exit 1
# fi

# # Docker daemon running?
# if ! docker info >/dev/null 2>&1; then
#   echo "❌ Docker is installed, but the daemon is not running."
#   echo ""
#   echo "How to fix:"
#   echo "  1) Start Docker Desktop"
#   echo "  2) Wait until 'Docker Desktop is running'"
#   echo "  3) Ensure 'Use the WSL 2 based engine' is enabled (Docker Desktop Settings)"
#   echo "  4) Rerun this script"
#   exit 1
# fi

# echo "✅ Docker daemon is running."

# =========================
# 3) Clone repositories if missing
# =========================
mkdir -p "$SERVICES_DIR" "$WORKERS_DIR" "$APPS_DIR"

clone_group() {
  local base="$1"; shift
  local group_name="$1"; shift
  echo "=== Checking clones: $group_name ==="

  for repo in "$@"; do
    set -- $repo
    local url="$1"
    local name="$2"
    local target="$base/$name"

    if [[ -d "$target/.git" ]]; then
      echo "✅ $name already exists."
    else
      echo "⬇️ Cloning $name..."
      git clone "$url" "$target" || {
        echo "❌ Failed to clone: $url"
        exit 1
      }
    fi
  done
}

clone_group "$SERVICES_DIR" "services" "${SERVICES[@]}"
clone_group "$WORKERS_DIR" "workers" "${WORKERS[@]}"
clone_group "$APPS_DIR" "apps" "${APPS[@]}"

echo ""
echo "✅ Done. All missing repositories were cloned."
