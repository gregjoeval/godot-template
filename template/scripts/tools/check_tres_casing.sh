#!/usr/bin/env bash
# Pre-commit hook: detect snake_case property names in [resource] sections of .tres files.
# Godot C# registers [Export] properties as PascalCase. Godot silently ignores snake_case
# property names (from GDScript era), loading them as null/default with no error.
#
# Heuristic: any property key containing an underscore in a [resource] section is a violation,
# EXCEPT known Godot built-in keys: script, resource_name, resource_local_to_scene, metadata/*.
#
# Usage:
#   ./scripts/tools/check_tres_casing.sh [file1.tres file2.tres ...]
#   With no arguments: scans all .tres files under data/
#
# Exit 0 if clean, exit 1 if violations found.

set -euo pipefail

# Known Godot built-in property names that legitimately use snake_case.
# These are not C# [Export] properties and must be excluded from the check.
is_builtin_key() {
    local key="$1"
    case "$key" in
        script)                  return 0 ;;
        resource_name)           return 0 ;;
        resource_local_to_scene) return 0 ;;
        metadata/*)              return 0 ;;
    esac
    return 1
}

# Convert snake_case to PascalCase for the suggestion message
to_pascal_case() {
    local key="$1"
    echo "$key" | awk -F'_' '{ result=""; for(i=1;i<=NF;i++) result=result toupper(substr($i,1,1)) substr($i,2); print result }'
}

status=0

# Determine which files to check
if [ "$#" -gt 0 ]; then
    files=("$@")
else
    # No arguments: scan all .tres files under data/
    mapfile -t files < <(find data/ -name '*.tres' -type f 2>/dev/null | sort)
fi

for file in "${files[@]}"; do
    [ -f "$file" ] || continue

    in_resource_section=0
    line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Detect section headers — track only [resource] (not [ext_resource], [sub_resource], or [gd_resource])
        if echo "$line" | grep -qE '^\['; then
            if echo "$line" | grep -qE '^\[resource\]'; then
                in_resource_section=1
            else
                in_resource_section=0
            fi
            continue
        fi

        # Only check lines inside [resource] sections
        [ "$in_resource_section" -eq 1 ] || continue

        # Skip blank lines
        [ -n "$line" ] || continue

        # Extract property key from lines of the form: key = value
        # The key must start at beginning of line (no leading spaces for top-level properties)
        if echo "$line" | grep -qE '^[A-Za-z_][A-Za-z0-9_/]* ='; then
            key=$(echo "$line" | sed 's/ =.*//')

            # Skip if key has no underscore — not a snake_case issue
            echo "$key" | grep -q '_' || continue

            # Skip known Godot built-in keys
            is_builtin_key "$key" && continue

            # Violation found
            suggestion=$(to_pascal_case "$key")
            echo "$file:$line_num: snake_case property '$key' (suggestion: $suggestion)"
            status=1
        fi
    done < "$file"
done

if [ "$status" -ne 0 ]; then
    echo ""
    echo "ERROR: snake_case property names found in .tres [resource] sections."
    echo "Godot C# [Export] properties are PascalCase. Rename the properties in the .tres files"
    echo "to match the PascalCase C# property names to avoid silent null/default loading."
fi

exit "$status"
