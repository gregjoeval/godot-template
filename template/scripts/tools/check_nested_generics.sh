#!/usr/bin/env bash
# Pre-commit hook: detect nested generics in GDScript files.
# gdtoolkit cannot parse Type[Type[...]] syntax (e.g., Array[Dictionary[K, V]]).
# See docs/gdscript-conventions.md for the approved pattern.

set -euo pipefail

status=0

for file in "$@"; do
    [ -f "$file" ] || continue

    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Strip trailing comment (everything after first unquoted #)
        # Simple approach: remove from first # that is not inside a string
        code="${line%%#*}"

        # Strip string literals (single and double quoted)
        code=$(echo "$code" | sed -E 's/"[^"]*"//g; s/'\''[^'\'']*'\''//g')

        # Check for nested generics: a second [ before the first ] closes
        if echo "$code" | grep -qE '(Array|Dictionary)\[[^]]*\['; then
            echo "$file:$line_num: $line"
            status=1
        fi
    done < "$file"
done

if [ "$status" -ne 0 ]; then
    echo ""
    echo "ERROR: Nested generics detected. gdtoolkit cannot parse Type[Type[...]]."
    echo "Flatten the outer container and use a doc comment for the intended type."
    echo "See docs/gdscript-conventions.md for details."
fi

exit "$status"
