#!/usr/bin/env bash
# Smoke test for scripts/hooks/pre-push.sh.
# Verifies the hook:
#   1. Exists and is executable.
#   2. Does NOT honor SKIP= (runs the gate even when SKIP=dotnet-build,dotnet-test is set).
#   3. Exits non-zero when a gate command fails.
# Exit 0 = all assertions passed.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK="$REPO_ROOT/scripts/hooks/pre-push.sh"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# ── 1. Hook must exist and be executable ────────────────────────────────────
if [ -x "$HOOK" ]; then
  pass "hook exists and is executable"
else
  fail "hook not found or not executable at $HOOK"
  # Cannot proceed with further tests.
  echo "Results: $PASS passed, $FAIL failed"
  exit 1
fi

# ── 2. Hook must NOT contain SKIP= bypass logic ─────────────────────────────
if grep -qE 'should_skip|SKIP_PRE_PUSH|\$\{SKIP' "$HOOK"; then
  fail "hook contains SKIP= bypass logic"
else
  pass "hook contains no SKIP= bypass logic"
fi

# ── 3. SKIP= does not prevent gate from running (hook exits non-zero) ────────
# Inject a PATH-first stub 'make' that always fails, simulating a broken build.
STUB_DIR="$(mktemp -d)"
trap 'rm -rf "$STUB_DIR"' EXIT

cat > "$STUB_DIR/make" << 'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$STUB_DIR/make"

# Run hook with SKIP=dotnet-build,dotnet-test and a failing 'make' in PATH.
# If the hook honors SKIP=, it would try to skip make and might exit 0.
# If it doesn't honor SKIP=, it runs make, which fails → exits non-zero.
set +e
SKIP=dotnet-build,dotnet-test PATH="$STUB_DIR:$PATH" "$HOOK" </dev/null 2>/dev/null
hook_exit=$?
set -e

if [ "$hook_exit" -ne 0 ]; then
  pass "SKIP=dotnet-build,dotnet-test does not bypass hook (hook exited $hook_exit)"
else
  fail "SKIP=dotnet-build,dotnet-test bypassed hook (hook exited 0)"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
