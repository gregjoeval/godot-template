#!/usr/bin/env bash
# merge-guard.sh — Wait for CI, then squash-merge a PR.
#
# Usage: ./scripts/tools/merge-guard.sh <PR-NUMBER>
#
# CI check strategy (gh < 2.30 compatible):
#   gh run list --commit <SHA> requires gh >= 2.30. We fetch the PR's head branch
#   name, list runs filtered by --branch, then narrow to the exact HEAD SHA using
#   jq so we only watch runs for this specific commit (not stale runs on the same
#   branch).
#
# Merge strategy (personal-repo admin fallback):
#   On organisation repos, a reviewer GitHub App can be added to
#   bypass_pull_request_allowances so its App-token merge skips the review
#   requirement. Personal repos do NOT support that API — GitHub returns HTTP 422.
#   Without bypass, the App's approval does not count toward
#   required_approving_review_count and the merge is rejected with
#   "base branch policy prohibits the merge".
#
#   Strategy:
#   1. If APP_TOKEN is set in the environment, attempt the merge with it. This
#      works on org repos that have bypass_pull_request_allowances configured.
#   2. If the App-token merge fails with a branch-protection error, fall back to
#      `gh pr merge --admin` using the default (user) gh token. --admin overrides
#      branch protection on the user's own personal repo where they are an admin.
#   3. If APP_TOKEN is not set, go straight to the --admin fallback.
#
#   To use a GitHub App identity, generate the token externally and export
#   APP_TOKEN before invoking this script. The template does not bundle App
#   token generation; bring your own (e.g. via `gh auth token` for an App, or
#   a custom script).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <PR-NUMBER>" >&2
  exit 1
fi

PR_NUMBER="$1"

# Fetch both head SHA and branch name in one call (compatible with all gh versions)
PR_INFO=$(gh pr view "$PR_NUMBER" --json headRefOid,headRefName)
HEAD_SHA=$(printf '%s' "$PR_INFO" | jq -r .headRefOid)
HEAD_BRANCH=$(printf '%s' "$PR_INFO" | jq -r .headRefName)

echo "Checking workflow runs for PR #${PR_NUMBER} (branch: ${HEAD_BRANCH}, SHA: ${HEAD_SHA})..."

# List runs for the head branch, then filter to exactly the HEAD SHA.
# --branch is available since gh 2.0; --commit requires gh >= 2.30.
RUNS=$(gh run list --branch "$HEAD_BRANCH" --json databaseId,status,conclusion,headSha \
  | jq --arg sha "$HEAD_SHA" '[.[] | select(.headSha == $sha)]')
RUN_COUNT=$(printf '%s' "$RUNS" | jq length)

if [[ "$RUN_COUNT" -eq 0 ]]; then
  echo "WARNING: No workflow runs found for PR #${PR_NUMBER} (SHA: ${HEAD_SHA})."
  echo "Proceeding with merge (no CI configured or runs not yet triggered)."
else
  echo "Found ${RUN_COUNT} workflow run(s). Waiting for completion..."

  # Watch any in-progress runs (--exit-status fails fast on failure)
  for RUN_ID in $(printf '%s' "$RUNS" | jq -r '.[] | select(.status != "completed") | .databaseId'); do
    echo "Watching run ${RUN_ID}..."
    gh run watch "$RUN_ID" --exit-status
  done

  # Re-check all runs (using the same branch+SHA filter) for failures.
  # Catches already-completed runs that were not watched above.
  FAILED=$(gh run list --branch "$HEAD_BRANCH" --json conclusion,headSha \
    | jq --arg sha "$HEAD_SHA" \
        '[.[] | select(.headSha == $sha)
               | select(.conclusion != "success" and .conclusion != "skipped")]
         | length')

  if [[ "$FAILED" -gt 0 ]]; then
    echo "ERROR: Some checks failed on PR #${PR_NUMBER}." >&2
    echo "Fix the failing checks before merging." >&2
    exit 1
  fi

  echo "All checks passed."
fi

# --- Merge ---
# Try App-token merge first if APP_TOKEN is set (works on org repos with
# bypass_pull_request_allowances). Fall back to --admin merge on failure
# (required for personal repos where bypass is unavailable).

_merge_admin() {
  echo "Merging PR #${PR_NUMBER} with --admin flag (user token, admin override)..."
  gh pr merge "$PR_NUMBER" --squash --delete-branch --admin
}

if [[ -n "${APP_TOKEN:-}" ]]; then
  echo "Attempting merge with App identity..."
  if GH_TOKEN="$APP_TOKEN" gh pr merge "$PR_NUMBER" --squash --delete-branch 2>/tmp/merge_err; then
    echo "PR #${PR_NUMBER} merged successfully (App identity)."
    exit 0
  fi

  # Check whether the failure is a branch-protection rejection.
  MERGE_ERR=$(cat /tmp/merge_err)
  echo "App-token merge failed: ${MERGE_ERR}" >&2

  if printf '%s' "$MERGE_ERR" | grep -qiE \
      "base branch policy|protected branch|required status|cannot be merged|pull request is not mergeable"; then
    echo "Branch protection blocked App-token merge (expected on personal repos)." >&2
    echo "Falling back to admin merge with user token..." >&2
    _merge_admin
  else
    # Unexpected error — propagate it.
    echo "ERROR: Merge failed with unexpected error." >&2
    exit 1
  fi
else
  echo "Merging PR #${PR_NUMBER} (no APP_TOKEN set, using user identity)..."
  _merge_admin
fi

echo "PR #${PR_NUMBER} merged successfully."
