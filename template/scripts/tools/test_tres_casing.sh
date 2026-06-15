#!/usr/bin/env bash
# Smoke test for scripts/tools/check_tres_casing.sh.
# Verifies that the check:
#   1. Flags a snake_case property in a [resource] section (exit non-zero).
#   2. Skips slash-separated Godot storage keys (e.g. Theme item keys) even when
#      they contain underscores (exit zero).
# Exit 0 = all assertions passed.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
CHECK="$REPO_ROOT/scripts/tools/check_tres_casing.sh"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# ── 1. snake_case property must be flagged ──────────────────────────────────
cat > "$WORK_DIR/snake.tres" << 'EOF'
[resource]
my_property = 1
EOF
if "$CHECK" "$WORK_DIR/snake.tres" >/dev/null 2>&1; then
  fail "snake_case property was not flagged"
else
  pass "snake_case property is flagged"
fi

# ── 2. slash-separated key with an underscore must be skipped ────────────────
cat > "$WORK_DIR/theme.tres" << 'EOF'
[resource]
Panel/colors/font_color = Color(1, 1, 1, 1)
EOF
if "$CHECK" "$WORK_DIR/theme.tres" >/dev/null 2>&1; then
  pass "slash-separated Theme key is skipped"
else
  fail "slash-separated Theme key was incorrectly flagged"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
