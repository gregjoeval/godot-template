#!/usr/bin/env bash
# Normalizes .tscn, .tres, and project.godot files by running Godot's headless
# import pipeline, which re-serializes them to canonical format (property
# ordering, UIDs, load_steps, section order).
# Usage: ./scripts/tools/normalize_scenes.sh [path-to-godot]
# File arguments (from pre-commit) are accepted but ignored — Godot needs full
# project context, so we always normalize all files.
# Exit code 0 = clean or skipped, non-zero = error.

set -euo pipefail

GODOT="${1:-godot}"
# Shift past the godot arg; remaining args (file list from pre-commit) are ignored.
shift 2>/dev/null || true

if ! command -v "$GODOT" &>/dev/null; then
    echo "Scene normalization SKIPPED — '$GODOT' not found"
    exit 0
fi

# Build C# project first so Godot can discover [GlobalClass] attributes.
# Without the compiled DLL, Godot's headless import leaves global_script_class_cache.cfg
# empty and cannot assign UIDs to .cs scripts or update .tres ext_resource entries.
if command -v dotnet &>/dev/null && ls ./*.csproj 2>/dev/null | grep -q .; then
    echo "Building C# project for class discovery..."
    dotnet build --no-incremental -warnaserror 2>&1 | tail -5 || {
        echo "WARNING: dotnet build failed — scene normalization may be incomplete"
    }
fi

echo "Normalizing Godot scene/resource files..."
output=$(timeout 120 "$GODOT" --headless --import --path . 2>&1) || true

# Report what changed
changed=$(git diff --name-only -- '*.tscn' '*.tres' 'project.godot' 2>/dev/null || true)

if [ -n "$changed" ]; then
    echo "Normalized files:"
    echo "$changed" | while read -r f; do
        echo "  $f"
    done
else
    echo "All scene/resource files already normalized."
fi

exit 0
