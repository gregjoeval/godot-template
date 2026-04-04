#!/usr/bin/env bash
# Pre-commit hook: detect type narrowing anti-pattern in GDScript files.
# Catches accessing Node2D/CanvasItem properties on variables typed as Node.
# See docs/gdscript-conventions.md for the approved pattern.

set -euo pipefail

status=0

# Properties that only exist on Node2D or CanvasItem, not on Node
PROPS="global_position|position|rotation|modulate|scale|z_index|global_rotation|global_scale|visible"

for file in "$@"; do
    [ -f "$file" ] || continue
    [[ "$file" == *.gd ]] || continue

    # Track Node-typed variables with their declaration indent level.
    # Format: "indent:varname" per entry.
    # A variable goes out of scope when we hit a non-blank line at <= its indent.
    # For "for" loops, the body indent is declaration_indent + 1 tab.
    declare -a scope_vars=()
    declare -a scope_indents=()
    # For loop vars, the scope starts INSIDE the loop (indent > declaration indent).
    # For var := patterns, the scope is the same block (indent >= declaration indent).
    declare -a scope_types=() # "for" or "var"

    line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Skip blank lines (don't affect scoping)
        if [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi

        # Calculate indent level (count leading tabs)
        stripped="${line#"${line%%[!	]*}"}"
        indent=$(( ${#line} - ${#stripped} ))

        # Expire out-of-scope variables.
        # For "for" vars: expire when indent <= declaration indent (left the loop body)
        # For "var" vars: expire when indent < declaration indent (left the block)
        new_vars=()
        new_indents=()
        new_types=()
        for i in "${!scope_vars[@]}"; do
            var_indent="${scope_indents[$i]}"
            var_type="${scope_types[$i]}"
            if [ "$var_type" = "for" ]; then
                # Loop body is indented more than the for line
                if [ "$indent" -gt "$var_indent" ]; then
                    new_vars+=("${scope_vars[$i]}")
                    new_indents+=("$var_indent")
                    new_types+=("$var_type")
                fi
            else
                # var := in a block - stays in scope at same or deeper indent
                if [ "$indent" -ge "$var_indent" ]; then
                    new_vars+=("${scope_vars[$i]}")
                    new_indents+=("$var_indent")
                    new_types+=("$var_type")
                fi
            fi
        done
        scope_vars=("${new_vars[@]+"${new_vars[@]}"}")
        scope_indents=("${new_indents[@]+"${new_indents[@]}"}")
        scope_types=("${new_types[@]+"${new_types[@]}"}")

        # Strip trailing comment
        code="${line%%#*}"

        # Detect "for <varname>: Node in" (but not "for <varname>: Node2D in" etc.)
        if echo "$code" | grep -qE 'for[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:[[:space:]]*Node[[:space:]]+in[[:space:]]'; then
            varname=$(echo "$code" | sed -nE 's/.*for[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*:[[:space:]]*Node[[:space:]]+in[[:space:]].*/\1/p')
            if [ -n "$varname" ]; then
                scope_vars+=("$varname")
                scope_indents+=("$indent")
                scope_types+=("for")
            fi
        fi

        # Detect "var <varname> := get_node_or_null(" or "var <varname> := get_parent()"
        if echo "$code" | grep -qE 'var[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:=[[:space:]]*(get_node_or_null|get_parent)[[:space:]]*\('; then
            varname=$(echo "$code" | sed -nE 's/.*var[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*:=[[:space:]]*(get_node_or_null|get_parent).*/\1/p')
            if [ -n "$varname" ]; then
                scope_vars+=("$varname")
                scope_indents+=("$indent")
                scope_types+=("var")
            fi
        fi

        # Check if any in-scope Node-typed variable accesses a flagged property
        for var in "${scope_vars[@]+"${scope_vars[@]}"}"; do
            if echo "$code" | grep -qE "(^|[^a-zA-Z0-9_])${var}\.(${PROPS})([^a-zA-Z0-9_]|$)"; then
                echo "$file:$line_num: $line"
                status=1
            fi
        done
    done < "$file"

    unset scope_vars scope_indents scope_types
done

if [ "$status" -ne 0 ]; then
    echo ""
    echo "ERROR: Type narrowing violation detected."
    echo "Accessing Node2D/CanvasItem properties on a Node-typed variable is unsafe."
    echo "Fix: use a typed local variable after an 'is' guard, or tighten the collection type."
    echo "See docs/gdscript-conventions.md for details."
fi

exit "$status"
