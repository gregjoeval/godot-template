---
name: prd-to-issues
description: "Decompose a PRD into independently-implementable issues using vertical slice architecture. Creates Ready issues (rd create) for implementation work and GitHub issues (gh issue create) for backlog items. Standalone alternative to the architect agent's issue creation phase. Use when user has a PRD and wants to create issues, or mentions 'prd to issues'."
---

# PRD to Issues

Decompose a Product Requirements Document into actionable, independently-implementable issues using vertical slice architecture.

**When to use this vs the architect agent**: Use `/prd-to-issues` when you already have a PRD and just need issues. The architect agent creates the PRD, plan, and issues as a full pipeline.

## Process

### 1. Locate the PRD

Ask the user for the PRD — GitHub issue number/URL or local file. If a GitHub issue, fetch with `gh issue view <number>`.

### 2. Explore Codebase (Optional)

Use Agent (subagent_type=Explore) to understand current code state if needed for accurate scoping.

### 3. Draft Vertical Slices

Break the PRD into tracer bullet issues that cut through ALL layers end-to-end. For each issue, determine:

- **Title**: Short, action-oriented
- **Type**: `AFK` (can be implemented autonomously) or `HITL` (needs human decisions during dev)
- **Blocked by**: Dependencies on other issues
- **User stories covered**: Which PRD user stories this addresses

Prefer **many thin slices** over few thick ones. Each completed slice should be independently demoable.

### 4. Validate with User

Present as a numbered list:

```
1. [AFK] <Title> — covers stories #1, #3
2. [HITL] <Title> — covers story #2, blocked by #1
3. [AFK] <Title> — covers stories #4, #5
```

Ask: Is the granularity right? Should any be merged or split?

### 5. Create Issues

Create in dependency order:

- **Implementation slices** → `rd create` (Ready issues with testable acceptance criteria)
  - Mark HITL issues with `mode: foreground` in description
  - Set dependencies: `rd dep add <blocked-id> <blocker-id>`
- **Backlog items** discovered during decomposition → `gh issue create` with appropriate labels

Each Ready issue should include:
- What and why (not how)
- Acceptance criteria as a testable checklist
- Link to parent PRD: `context: "gh#<N>: <PRD title>"`

Do NOT close or modify the original PRD issue.

Print created issue IDs and a summary when done.
