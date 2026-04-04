#!/usr/bin/env bash
# Pre-commit hook: detect `return` statements inside shader processor functions.
# Godot shader processor functions (fragment, vertex, light) do not support
# `return` — it causes runtime shader compilation errors.
# Helper functions may use `return` freely.

set -euo pipefail

status=0

for file in "$@"; do
    [ -f "$file" ] || continue

    in_processor=0
    brace_depth=0
    processor_brace_start=0
    in_block_comment=0
    line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Track block comment state
        remaining="$line"
        if [ "$in_block_comment" -eq 1 ]; then
            if echo "$remaining" | grep -q '\*/'; then
                remaining="${remaining#*\*/}"
                in_block_comment=0
            else
                continue
            fi
        fi

        # Remove block comments that start and end on the same line
        while echo "$remaining" | grep -q '/\*'; do
            before="${remaining%%/\**}"
            after="${remaining#*/\*}"
            if echo "$after" | grep -q '\*/'; then
                after="${after#*\*/}"
                remaining="${before}${after}"
            else
                remaining="$before"
                in_block_comment=1
                break
            fi
        done

        # Strip line comments
        code="${remaining%%//*}"

        # Detect processor function entry: void fragment|vertex|light(...)
        if echo "$code" | grep -qE 'void\s+(fragment|vertex|light)\s*\('; then
            in_processor=1
            processor_brace_start=0
        fi

        # Count braces to track scope
        open_count=$(echo "$code" | tr -cd '{' | wc -c)
        close_count=$(echo "$code" | tr -cd '}' | wc -c)

        if [ "$in_processor" -eq 1 ] && [ "$processor_brace_start" -eq 0 ] && [ "$open_count" -gt 0 ]; then
            processor_brace_start=$((brace_depth + 1))
        fi

        brace_depth=$((brace_depth + open_count - close_count))

        # Check for return inside processor function (depth > processor start)
        if [ "$in_processor" -eq 1 ] && [ "$processor_brace_start" -gt 0 ]; then
            if echo "$code" | grep -qE '\breturn\b'; then
                echo "$file:$line_num: $line"
                status=1
            fi
        fi

        # Exited processor function
        if [ "$in_processor" -eq 1 ] && [ "$processor_brace_start" -gt 0 ] && [ "$brace_depth" -lt "$processor_brace_start" ]; then
            in_processor=0
            processor_brace_start=0
        fi
    done < "$file"
done

if [ "$status" -ne 0 ]; then
    echo ""
    echo "ERROR: 'return' statement found inside a shader processor function."
    echo "Godot shader processor functions (fragment, vertex, light) do not support 'return'."
    echo "Restructure the logic using if/else blocks instead of early returns."
fi

exit "$status"
