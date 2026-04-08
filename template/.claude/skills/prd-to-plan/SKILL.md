---
name: prd-to-plan
description: "Convert a PRD into a phased implementation roadmap using vertical slices (tracer bullets), saved as a plan file. Standalone alternative to the architect agent's decomposition phase. Use when user has an existing PRD and wants to create an implementation plan, or mentions 'prd to plan'."
---

# PRD to Plan

Convert a Product Requirements Document into a phased implementation roadmap using vertical slices. Output saves to `.claude/plans/`.

**When to use this vs the architect agent**: Use `/prd-to-plan` when you already have a PRD and just need the plan. The architect agent creates the PRD first, then does this automatically.

## Process

### 1. Locate the PRD

Ask the user for the PRD — either a GitHub issue number/URL or a local file. If a GitHub issue, fetch with `gh issue view <number>`.

### 2. Understand the Codebase

Use Agent (subagent_type=Explore) to understand existing architecture, patterns, and integration points relevant to the PRD.

### 3. Identify Durable Architectural Choices

Document foundational decisions that remain stable across all phases:
- Signal names and contracts
- Scene tree structure and node composition
- Resource/data model structures
- Autoload responsibilities
- Multiplayer authority model (if applicable)

### 4. Create Vertical Slices

Each phase is a thin, complete slice through ALL layers:

```
scene tree → C# logic → signals → state → tests
```

NOT horizontal slices ("just the scripts", "just the tests"). Each completed slice should be independently demoable.

Prefer **many thin slices** over few thick ones. Each slice should:
- Deliver visible, testable functionality
- Touch all relevant layers end-to-end
- Be small enough for a single PR (~300 lines)

### 5. Get User Feedback

Present phases as a numbered list:
1. **Phase title** — user stories covered, what's demoable at the end

Ask: Does granularity feel right? Should any phases be merged or split?

### 6. Generate the Plan

Write to `.claude/plans/<feature-name>.md`:

```markdown
# Plan: <Feature Name>

Source PRD: <link or reference>

## Architectural Foundations
<Durable decisions that span all phases>

## Phase 1: <Title>
**User stories**: #1, #3
**End-to-end**: <What this slice delivers>
**Acceptance criteria**:
- [ ] <Testable criterion>
- [ ] <Testable criterion>

## Phase 2: <Title>
...
```

Tell the user the plan file path when done.
