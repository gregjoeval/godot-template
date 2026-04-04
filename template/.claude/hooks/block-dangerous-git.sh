#!/usr/bin/env bash
# PreToolUse hook: block destructive git commands
# Exit code 2 = block the tool call

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

BLOCKED_PATTERNS=(
  'git push'
  'git reset --hard'
  'git clean'
  'git checkout -- '
  'git checkout .'
  'git restore'
  'git branch -d'
  'git branch -D'
  'git stash drop'
  'git stash clear'
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'" >&2
    echo "Run this command manually if you really need it." >&2
    exit 2
  fi
done

exit 0
