#!/usr/bin/env bash
# Reject @warning_ignore annotations in GDScript files.
# Only config_helper.gd and node_cast.gd are exempt (centralized casting).
set -euo pipefail

found=0
for file in "$@"; do
    [ -f "$file" ] || continue
    if grep -n '@warning_ignore' "$file"; then
        found=1
    fi
done

if [ "$found" -ne 0 ]; then
    echo ""
    echo "ERROR: @warning_ignore is banned."
    echo "Use typed data classes, ConfigHelper, or NodeCast instead."
    echo "See docs/gdscript-conventions.md for details."
    exit 1
fi
