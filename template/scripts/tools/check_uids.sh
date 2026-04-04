#!/usr/bin/env bash
# Audit script: ensures every .gd, .gdshader, .gdextension file has a .uid sidecar.
# Exits non-zero if any are missing. Usable from pre-commit hook and CI.

set -euo pipefail

UID_EXTENSIONS="gd gdshader gdextension"

# Build find pattern: -name '*.gd' -o -name '*.gdshader' -o ...
find_args=()
first=true
for ext in $UID_EXTENSIONS; do
    if [ "$first" = true ]; then
        first=false
    else
        find_args+=(-o)
    fi
    find_args+=(-name "*.${ext}")
done

# Find all matching files, excluding .godot/ and addons/gut/
missing=()
while IFS= read -r file; do
    uid_file="${file}.uid"
    if [ ! -f "$uid_file" ]; then
        missing+=("$file")
    fi
done < <(find . -type f \( "${find_args[@]}" \) \
    -not -path './.godot/*' \
    -not -path './addons/gut/*' \
    | sort)

if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: ${#missing[@]} file(s) missing .uid sidecar:"
    for f in "${missing[@]}"; do
        echo "  $f"
    done
    echo ""
    echo "Fix: commit via the pre-commit hook (auto-generates .uid files)"
    echo "  or manually create: echo 'uid://<13-char-id>' > <file>.uid"
    exit 1
fi

echo "OK: all ${UID_EXTENSIONS} files have .uid sidecars"
exit 0
