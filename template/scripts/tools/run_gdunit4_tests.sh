#!/usr/bin/env bash
# Runs gdUnit4 tests in headless mode via the gdUnit4 CLI addon.
# Usage: ./scripts/tools/run_gdunit4_tests.sh [path-to-godot]
# File arguments (from pre-commit) are accepted but ignored — gdUnit4 runs all
# tests from the specified directory.
# Exit code 0 = all tests passed, non-zero = failures or errors.
# NOTE: This script is NOT added to pre-commit — it is run manually.

set -euo pipefail

GODOT="${1:-${GODOT:-godot}}"
# Shift past the godot arg; remaining args (file list) are ignored.
shift 2>/dev/null || true

if ! command -v "$GODOT" &>/dev/null; then
    echo "FAILED: gdUnit4 tests — '$GODOT' not found" >&2
    echo "   Tests will NOT be run." >&2
    echo "   Install Godot or set GODOT= to enable this check." >&2
    exit 1
fi

GDUNIT4_TIMEOUT="${GDUNIT4_TIMEOUT:-120}"

# Capture output to a temp file to avoid bash variable size/encoding issues
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

timeout "$GDUNIT4_TIMEOUT" "$GODOT" --headless --path . \
    -s addons/gdUnit4/bin/GdUnitCmdTool.gd \
    -a "res://tests_gdunit4/" \
    --ignoreHeadlessMode \
    >"$tmpfile" 2>&1 \
    && gdunit_exit=0 || gdunit_exit=$?

# Show output (filter noise)
grep -v "^Godot Engine v" "$tmpfile" | grep -v "^$" || true

# gdUnit4 exit codes: 0=success, 101=warnings (orphans), others=failures/errors
if [ "$gdunit_exit" -eq 0 ] || [ "$gdunit_exit" -eq 101 ]; then
    if [ "$gdunit_exit" -eq 101 ]; then
        echo ""
        echo "gdUnit4 tests passed with warnings (orphan nodes detected)."
    else
        echo "gdUnit4 tests passed."
    fi
    exit 0
fi

echo ""
echo "gdUnit4 tests FAILED (exit code $gdunit_exit) — see errors above."
exit 1
