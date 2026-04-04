#!/usr/bin/env bash
# Validates all GDScript files by loading every .gd and .tscn in the project.
# Uses check_all_scripts.gd to force-load all files, not just main-scene-reachable ones.
# Usage: ./scripts/tools/check_types.sh [path-to-godot]
# File arguments (from pre-commit) are accepted but ignored — Godot needs full
# project context to resolve autoloads, so we always check all files.
# Exit code 0 = clean, non-zero = errors found.

set -euo pipefail

GODOT="${1:-${GODOT:-godot}}"
# Shift past the godot arg; remaining args (file list from pre-commit) are ignored.
shift 2>/dev/null || true

if ! command -v "$GODOT" &>/dev/null; then
    echo "❌ FAILED: GDScript type check — '$GODOT' not found" >&2
    echo "   Type errors (Variant inference, missing classes) will NOT be caught." >&2
    echo "   Install Godot or set GODOT= to enable this check." >&2
    echo "   To bypass: SKIP=gdtypecheck git commit ..." >&2
    exit 1
fi

# Rebuild the global script class cache (mirrors CI's --import step).
# Without this, newly-added class_name scripts won't be resolved.
timeout 120 "$GODOT" --headless --import --path . --quit 2>/dev/null || true

output=$(timeout 120 "$GODOT" --headless --path . --script res://scripts/tools/check_all_scripts.gd 2>&1) || true

# Filter out the version banner, noise, and the tool script's own backtrace lines
echo "$output" | grep -v "^Godot Engine v" | grep -v "^$" | grep -v "check_all_scripts\.gd" || true

if echo "$output" | grep -v "check_all_scripts\.gd" | grep -qiE "(SCRIPT ERROR|Parse Error|Cannot infer|^ERROR)"; then
    echo ""
    echo "GDScript type check FAILED — see errors above."
    exit 1
fi

echo "GDScript type check passed."
exit 0
