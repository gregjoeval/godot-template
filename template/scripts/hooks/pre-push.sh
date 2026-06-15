#!/usr/bin/env bash
# Pre-push quality gate — runs on every push regardless of SKIP= env vars.
# The only bypass is: git push --no-verify
# (forbidden by project convention; see docs/DECISIONS.md)
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Per-run temp dir for gate logs (avoids predictable /tmp paths).
LOG_DIR="$(mktemp -d)"
trap 'rm -rf "$LOG_DIR"' EXIT

# Detect scene-file changes in the commits being pushed.
HAS_SCENE_CHANGES=0
while read -r _local_ref local_sha _remote_ref remote_sha; do
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    range="$local_sha"
  else
    range="${remote_sha}..${local_sha}"
  fi
  if git diff --name-only "$range" -- '*.tscn' '*.tres' 'project.godot' 2>/dev/null | grep -q .; then
    HAS_SCENE_CHANGES=1
  fi
done

# ── 1. Build ─────────────────────────────────────────────────────────────────
echo "pre-push: make build ..."
if ! make build >"$LOG_DIR/build.log" 2>&1; then
  echo "pre-push: BUILD FAILED. Last 30 lines:"
  tail -30 "$LOG_DIR/build.log"
  echo ""
  echo "pre-push: Fix the build before pushing. Bypass (emergency only): git push --no-verify"
  exit 1
fi

# ── 2. Tests ─────────────────────────────────────────────────────────────────
echo "pre-push: make test ..."
if ! make test >"$LOG_DIR/test.log" 2>&1; then
  # Godot headless exits non-zero after all tests complete — tolerate this if
  # the VSTest summary shows 0 actual failures and at least one pass.
  FAILED_COUNT=$(grep -oE 'Failed:[[:space:]]+[0-9]+' "$LOG_DIR/test.log" | grep -oE '[0-9]+$' | head -1)
  if grep -q 'Passed!' "$LOG_DIR/test.log" && [ "${FAILED_COUNT:-1}" = "0" ]; then
    echo "pre-push: test runner exited non-zero but all tests passed (Godot headless crash is pre-existing) — treating as clean."
  else
    echo "pre-push: TESTS FAILED. Failure summary:"
    grep -E "Failed |Error Message:|Test Run Aborted" "$LOG_DIR/test.log" | head -20
    echo ""
    echo "pre-push: Fix the failing tests before pushing. Bypass (emergency only): git push --no-verify"
    exit 1
  fi
fi

# ── 3. Format ─────────────────────────────────────────────────────────────────
echo "pre-push: make format ..."
if ! make format >"$LOG_DIR/format.log" 2>&1; then
  echo "pre-push: FORMAT FAILED. Run 'dotnet csharpier format .' and re-commit."
  tail -20 "$LOG_DIR/format.log"
  exit 1
fi

# ── 4. UID sidecars ───────────────────────────────────────────────────────────
echo "pre-push: check_uids.sh ..."
if ! ./scripts/tools/check_uids.sh >"$LOG_DIR/uids.log" 2>&1; then
  echo "pre-push: MISSING UID SIDECARS:"
  cat "$LOG_DIR/uids.log"
  exit 1
fi

# ── 5. Scene normalization (only when scene files are being pushed) ───────────
if [ "$HAS_SCENE_CHANGES" = "1" ]; then
  echo "pre-push: scene files detected — running normalize_scenes.sh ..."
  ./scripts/tools/normalize_scenes.sh
  if ! git diff --exit-code -- '*.tscn' '*.tres' 'project.godot' >/dev/null 2>&1; then
    echo "pre-push: NORMALIZATION REWROTE FILES. Stage and commit the normalized files before pushing:"
    git diff --name-only -- '*.tscn' '*.tres' 'project.godot'
    exit 1
  fi
fi

echo "pre-push: gate clean — pushing."
exit 0
