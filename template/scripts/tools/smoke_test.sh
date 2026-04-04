#!/usr/bin/env bash
# Smoke test: loads the main scene (from run/main_scene in project.godot) headlessly
# for ~120 frames. Fails if Godot exits non-zero or emits SCRIPT ERROR:.
# Usage: ./scripts/tools/smoke_test.sh [path-to-godot]

set -euo pipefail

GODOT="${1:-godot}"
OUTPUT=$("$GODOT" --headless --script res://scripts/tools/smoke_test.gd --path . 2>&1) || {
    echo "FAIL: Godot exited with non-zero status"
    echo "$OUTPUT"
    exit 1
}

if echo "$OUTPUT" | grep -q "SCRIPT ERROR:"; then
    echo "FAIL: SCRIPT ERROR detected in output"
    echo "$OUTPUT"
    exit 1
fi

echo "OK: smoke test passed"
echo "$OUTPUT" | tail -1
