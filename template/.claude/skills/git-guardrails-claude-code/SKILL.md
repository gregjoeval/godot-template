---
name: git-guardrails-claude-code
description: "Set up a PreToolUse hook that blocks destructive git commands (push, reset --hard, clean, branch -D, checkout --). One-time setup skill — run once to install the guardrail, then it protects automatically. Use when user wants to prevent destructive git operations or add git safety hooks."
---

# Git Guardrails for Claude Code

Install a PreToolUse hook that blocks dangerous git commands before they execute. **Run this skill once** — after setup, the guardrail protects automatically.

**Prerequisite**: `jq` must be installed (`apt-get install jq` or equivalent).

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean`
- `git checkout -- .` / `git checkout -- <file>`
- `git restore .` / `git restore --staged`
- `git branch -D` / `git branch -d`
- `git stash drop` / `git stash clear`

## Setup Process

### 1. Ask Scope

Ask the user: **Project-level** (`.claude/settings.json`) or **Global** (`~/.claude/settings.json`)?

- Project-level: protects only this repo, committed with the project
- Global: protects all repos for this user

### 2. Create Hook Script

Write the hook script to `.claude/hooks/block-dangerous-git.sh`:

```bash
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
  'git branch -[dD]'
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
```

Make it executable: `chmod +x .claude/hooks/block-dangerous-git.sh`

### 3. Register the Hook

Add to the chosen settings.json, merging with existing hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

### 4. Verify

Test by piping a simulated command through the script:

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | bash .claude/hooks/block-dangerous-git.sh
```

Expected: stderr message "BLOCKED: ..." and exit code 2.

### 5. Customize (Optional)

Ask if the user wants to add or remove patterns from `BLOCKED_PATTERNS`. Common additions:
- `git rebase` (if they want to protect against rebase)
- `git merge --abort`

Common removals:
- `git push` (if they want Claude to push after review)
