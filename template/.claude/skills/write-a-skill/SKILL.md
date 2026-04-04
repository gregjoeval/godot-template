---
name: write-a-skill
description: Guide creation of new Claude Code skills with proper structure, frontmatter, and trigger descriptions. Use when user wants to create, write, or add a new skill.
---

# Write a Skill

Guide the user through creating a new Claude Code skill for this project.

## Process

### 1. Gather Requirements

Ask about:
- What task domain does this skill cover?
- What specific use cases trigger it?
- Does it need reference files for detailed content?
- What tools should it be allowed to use? (optional `allowed-tools` field)

### 2. Draft the Skill

Create `.claude/skills/<skill-name>/SKILL.md` with:

**Frontmatter** (YAML):
```yaml
---
name: skill-name          # kebab-case, matches directory name
description: ...          # CRITICAL -- see Description Rules below
argument-hint: "<args>"   # optional, shown in UI
allowed-tools: Read, Grep # optional, restricts available tools
---
```

**Body**: Concise instructions. Keep SKILL.md under 100 lines.

**Reference files** (if needed):
- `REFERENCE.md` -- detailed documentation
- `EXAMPLES.md` -- usage examples
- Split when SKILL.md would exceed ~80 lines

### 3. Review with User

Present the draft, get feedback, iterate until approved.

## Description Rules

The description is **the only thing the agent sees** when deciding whether to load a skill. It must:

- Stay under 1024 characters
- Lead with what the skill does
- Include trigger conditions: "Use when..."
- Distinguish from similar skills with specific keywords

**Good**: "Triage a bug by exploring the codebase to find root cause, then create a Ready issue with a TDD-based fix plan. Use when user reports a bug, wants to investigate a problem, or mentions 'triage'."

**Bad**: "Help with bugs."

## Examples

- **Simple skill**: See `.claude/skills/cf-poll/SKILL.md` (22 lines, single workflow)
- **Complex skill**: See `.claude/skills/review-plan/SKILL.md` (multi-step, `allowed-tools` field)
- **With references**: See `.claude/skills/tdd/SKILL.md` (links to `gdunit4-patterns.md`, `testing-philosophy.md`)
