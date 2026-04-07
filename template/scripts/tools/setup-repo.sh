#!/usr/bin/env bash
set -euo pipefail

# Configure GitHub repository settings and branch protection for main.
# Requires: gh CLI (authenticated), admin access to the repository.
# Idempotent — safe to re-run at any time.

# --- Prerequisite checks ---
if ! command -v gh &>/dev/null; then
  echo "[ERROR] 'gh' (GitHub CLI) is required but not found."
  echo "        Install it from: https://cli.github.com"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "[ERROR] gh is not authenticated."
  echo "        Run: gh auth login"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [[ -z "$REPO" ]]; then
  echo "[ERROR] Could not determine repository. Are you inside a git repo with a GitHub remote?"
  exit 1
fi

echo "=== Repository Settings: ${REPO} ==="
echo ""

# --- Repo-level settings ---
echo "[RUN] Configuring repository settings..."
gh repo edit "$REPO" \
  --delete-branch-on-merge \
  --enable-auto-merge \
  --enable-squash-merge \
  --enable-rebase-merge \
  --enable-merge-commit=false \
  --enable-issues \
  --enable-wiki=false \
  --enable-discussions=false \
  --enable-projects=false \
  --allow-update-branch
echo "[OK] Repository settings configured"

# --- Default branch ---
DEFAULT_BRANCH=$(gh repo view "$REPO" --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || true)
if [[ "$DEFAULT_BRANCH" != "main" ]]; then
  if git ls-remote --heads origin main &>/dev/null; then
    echo "[RUN] Setting default branch to main..."
    gh repo edit "$REPO" --default-branch main
    echo "[OK] Default branch set to main"
  else
    echo "[SKIP] Branch 'main' does not exist on remote — push at least one commit first"
  fi
else
  echo "[OK] Default branch is already main"
fi

# --- Branch protection for main ---
echo "[RUN] Configuring branch protection for main..."

# The required status check 'gate' is the aggregation job in ci-gate.yml.
# If that job is renamed, update the context name here to match.
PROTECTION_PAYLOAD=$(cat <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["gate"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
)

HTTP_STATUS=$(gh api \
  --method PUT \
  "repos/${REPO}/branches/main/protection" \
  --input - \
  --silent \
  --include \
  <<< "$PROTECTION_PAYLOAD" 2>&1 | head -1 | grep -oP '\d{3}' || echo "000")

if [[ "$HTTP_STATUS" =~ ^2 ]]; then
  echo "[OK] Branch protection configured for main"
else
  echo "[ERROR] Failed to configure branch protection (HTTP ${HTTP_STATUS})"
  echo "        Ensure you have admin access to ${REPO}"
  echo "        Note: branch protection requires the main branch to exist"
  exit 1
fi

echo ""
echo "=== Repository Setup Complete ==="
echo ""
echo "Settings applied:"
echo "  - Squash & rebase merge only (merge commits disabled)"
echo "  - Auto-delete branches on merge"
echo "  - Auto-merge enabled"
echo "  - Wiki, discussions, projects disabled"
echo "  - Branch protection on main:"
echo "    - 1 approving review required (stale reviews dismissed)"
echo "    - Status check 'gate' required (must be up to date)"
echo "    - Conversation resolution required"
echo "    - Force pushes and deletions blocked"
