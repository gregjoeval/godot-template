#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <PR-NUMBER>" >&2
  exit 1
fi

PR_NUMBER="$1"

echo "Waiting for all checks on PR #${PR_NUMBER} to complete..."
if ! gh pr checks "$PR_NUMBER" --watch --fail-fast; then
  echo "ERROR: Some checks failed on PR #${PR_NUMBER}." >&2
  echo "Fix the failing checks before merging." >&2
  exit 1
fi

echo "All checks passed. Merging PR #${PR_NUMBER}..."
gh pr merge "$PR_NUMBER" --squash --delete-branch
echo "PR #${PR_NUMBER} merged successfully."
