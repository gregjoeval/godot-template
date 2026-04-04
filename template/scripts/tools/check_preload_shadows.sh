#!/usr/bin/env bash
# Pre-commit hook: detect const preload(...) that shadows a class_name declaration.
# When a script declares `class_name Foo`, any other file doing `const Foo = preload(...)`
# shadows the global name and causes Godot warnings.
# See docs/gdscript-conventions.md for context.

set -euo pipefail

# Collect all class_name declarations from the project (excluding addons)
class_names=$(grep -rh '^class_name ' scripts/ | sed 's/class_name //' | tr -d '\r' | sort -u)

if [ -z "$class_names" ]; then
    exit 0
fi

status=0

for file in "$@"; do
    [ -f "$file" ] || continue

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Match: const SomeName = preload(  or  const SomeName := preload(
        if echo "$line" | grep -qE '^const [A-Za-z_][A-Za-z0-9_]* :?= preload\('; then
            # Extract the const name
            const_name=$(echo "$line" | sed -E 's/^const ([A-Za-z_][A-Za-z0-9_]*) :?= preload\(.*/\1/')

            # Check if it matches any class_name
            if echo "$class_names" | grep -qxF "$const_name"; then
                echo "$file:$line_num: $line"
                status=1
            fi
        fi
    done < "$file"
done

if [ "$status" -ne 0 ]; then
    echo ""
    echo "ERROR: const preload(...) shadows a class_name declaration."
    echo "When a class_name is registered globally, re-declaring it as a const preload"
    echo "shadows the global name and causes Godot warnings."
    echo "Fix: remove the const preload line — use the class_name directly."
fi

exit "$status"
