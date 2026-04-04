#!/usr/bin/env bash
set -euo pipefail

# Removes stale git worktrees under .claude/worktrees/ that are older than 4 hours.
# Safe: only targets worktrees within .claude/worktrees/, never the main worktree.
# Idempotent: safe to run multiple times.

REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_DIR="${REPO_ROOT}/.claude/worktrees"
AGE_MINUTES=240

if [[ ! -d "$WORKTREE_DIR" ]]; then
  echo "No stale worktrees found."
  exit 0
fi

removed=0

while IFS= read -r -d '' worktree_path; do
  # Only process directories that are registered as git worktrees
  if ! git worktree list --porcelain | grep -q "^worktree ${worktree_path}$"; then
    continue
  fi

  echo "Removing stale worktree: ${worktree_path}"
  git worktree remove "$worktree_path" --force
  ((removed++))
done < <(find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d -mmin "+${AGE_MINUTES}" -print0)

if [[ $removed -eq 0 ]]; then
  echo "No stale worktrees found."
else
  echo "Removed ${removed} stale worktree(s)."
fi
