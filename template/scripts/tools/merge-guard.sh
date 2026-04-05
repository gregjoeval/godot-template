#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <PR-NUMBER>" >&2
  exit 1
fi

PR_NUMBER="$1"
HEAD_SHA=$(gh pr view "$PR_NUMBER" --json headRefOid -q .headRefOid)

echo "Checking workflow runs for PR #${PR_NUMBER} (SHA: ${HEAD_SHA})..."

# Find workflow runs for this commit
RUNS=$(gh run list --commit "$HEAD_SHA" --json databaseId,status,conclusion)
RUN_COUNT=$(echo "$RUNS" | jq length)

if [[ "$RUN_COUNT" -eq 0 ]]; then
  echo "WARNING: No workflow runs found for PR #${PR_NUMBER} (SHA: ${HEAD_SHA})."
  echo "Proceeding with merge (no CI configured)."
else
  echo "Found ${RUN_COUNT} workflow run(s). Waiting for completion..."

  # Watch any in-progress runs (--exit-status fails fast on failure)
  for RUN_ID in $(echo "$RUNS" | jq -r '.[] | select(.status != "completed") | .databaseId'); do
    echo "Watching run ${RUN_ID}..."
    gh run watch "$RUN_ID" --exit-status
  done

  # Re-check all runs for failures (catches already-completed runs)
  FAILED=$(gh run list --commit "$HEAD_SHA" --json databaseId,conclusion \
    -q '[.[] | select(.conclusion != "success" and .conclusion != "skipped")] | length')

  if [[ "$FAILED" -gt 0 ]]; then
    echo "ERROR: Some checks failed on PR #${PR_NUMBER}." >&2
    echo "Fix the failing checks before merging." >&2
    exit 1
  fi

  echo "All checks passed."
fi

echo "Merging PR #${PR_NUMBER}..."
gh pr merge "$PR_NUMBER" --squash --delete-branch
echo "PR #${PR_NUMBER} merged successfully."
