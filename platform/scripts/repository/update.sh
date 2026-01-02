#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../../.."; pwd)"

SERVICES_DIR="$ROOT_DIR/services"
WORKERS_DIR="$ROOT_DIR/workers"
APPS_DIR="$ROOT_DIR/apps"

TARGET_BRANCH="develop"

echo "ROOT_DIR: $ROOT_DIR"
echo "Target branch: $TARGET_BRANCH"
echo ""

is_git_repo() {
  [[ -d "$1/.git" ]]
}

has_uncommitted_changes() {
  # returns 0 if dirty, 1 if clean
  git status --porcelain | grep -q .
}

ensure_develop_local() {
  # Create local develop if missing, based on current HEAD
  if git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH"; then
    return 0
  fi

  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "  + Creating local '$TARGET_BRANCH' from '$current_branch'"
  git branch "$TARGET_BRANCH"
}

ensure_develop_remote() {
  # Push develop to origin only if remote branch doesn't exist
  if git ls-remote --exit-code --heads origin "$TARGET_BRANCH" >/dev/null 2>&1; then
    return 0
  fi

  echo "  + Pushing '$TARGET_BRANCH' to origin (remote branch missing)"
  git push -u origin "$TARGET_BRANCH"
}

update_repo() {
  local repo_path="$1"
  echo "==> $(basename "$repo_path")"

  if ! is_git_repo "$repo_path"; then
    echo "  - Not a git repo, skipping: $repo_path"
    return 0
  fi

  cd "$repo_path"

  # Ensure origin exists
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "  - No 'origin' remote, skipping"
    cd - >/dev/null
    return 0
  fi

  # Fetch updates
  git fetch origin --prune >/dev/null 2>&1 || {
    echo "  - Fetch failed, skipping"
    cd - >/dev/null
    return 0
  }

  # Create local develop if needed
  ensure_develop_local

  # If working tree dirty, don't switch/pull
  if has_uncommitted_changes; then
    echo "  ! Uncommitted changes detected. Skipping checkout/pull."
    cd - >/dev/null
    return 0
  fi

  # Checkout develop
  git checkout "$TARGET_BRANCH" >/dev/null 2>&1 || {
    echo "  - Failed to checkout $TARGET_BRANCH"
    cd - >/dev/null
    return 0
  }

  # Push develop if remote missing
  ensure_develop_remote

  # Pull latest changes if remote exists
  if git ls-remote --exit-code --heads origin "$TARGET_BRANCH" >/dev/null 2>&1; then
    echo "  ~ Pulling latest '$TARGET_BRANCH'"
    git pull --ff-only origin "$TARGET_BRANCH" || {
      echo "  ! Pull failed (non-fast-forward?). Resolve manually."
    }
  fi

  cd - >/dev/null
}

scan_and_update_dir() {
  local dir="$1"
  local label="$2"

  echo "===== $label: $dir ====="
  if [[ ! -d "$dir" ]]; then
    echo "  (missing) Skipping."
    echo ""
    return 0
  fi

  for repo in "$dir"/*; do
    [[ -d "$repo" ]] || continue
    update_repo "$repo"
  done
  echo ""
}

scan_and_update_dir "$SERVICES_DIR" "SERVICES"
scan_and_update_dir "$WORKERS_DIR" "WORKERS"
scan_and_update_dir "$APPS_DIR" "APPS"

echo "✅ Update complete."
