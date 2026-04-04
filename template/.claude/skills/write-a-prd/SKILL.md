---
name: write-a-prd
description: "Create a PRD through user interview, codebase exploration, and module design, then submit as a GitHub issue. Lightweight standalone alternative to the full architect agent — use for quick PRDs without the full requirements-to-issues pipeline. Use when user wants to write a PRD, document a feature, or plan a new feature."
---

# Write a PRD

Create a Product Requirements Document through structured interview, codebase exploration, and module design. Filed as a GitHub issue.

**When to use this vs the architect agent**: Use `/write-a-prd` for a quick standalone PRD. Use the architect agent when you want the full pipeline (PRD → plan → vertical slices → Ready issues).

## Process

### 1. Gather Requirements

Ask for a detailed description of the problem and any potential solutions the user has in mind. Probe for:
- Who is affected and how?
- What does success look like?
- What constraints exist?

### 2. Codebase Analysis

Use Agent (subagent_type=Explore) to validate claims and understand current state:
- What exists today that's relevant?
- What patterns does the project use for similar features?
- Reference `docs/DECISIONS.md` for architectural conventions

### 3. User Interview

Conduct thorough questioning about design aspects. One question at a time, with a recommended answer for each. Systematically resolve decision dependencies:
- Scene tree structure and node composition
- Signal contracts and data flow
- State management approach
- Multiplayer considerations (if applicable)
- Edge cases and error handling

### 4. Module Design

Identify major components needing creation or modification. Emphasize **deep modules** — simple interfaces hiding substantial implementation. Consider:
- What signals does each module expose?
- What `@export` properties does it need?
- How do modules compose in the scene tree?
- What can be tested through the public interface?

### 5. Create GitHub Issue

Run `gh issue create` with this structure:

```markdown
## Problem Statement
<User-centric description>

## Solution
<User-focused explanation>

## User Stories
1. As a <actor>, I want <feature>, so that <benefit>
...

## Implementation Decisions
- Modules to build or modify and their interfaces
- Architectural choices and signal contracts
- Scene tree structure

## Testing Decisions
- What makes a good test for this feature
- Which modules to test and how

## Out of Scope
- <Explicitly excluded>

## Further Notes
- <Additional context>
```

Print the issue URL when done.
