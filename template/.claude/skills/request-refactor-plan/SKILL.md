---
name: request-refactor-plan
description: "Create a detailed refactoring plan with granular commits through a structured interview, then file as a GitHub issue. Use when user wants to plan a refactor, restructure code, or create a refactoring RFC."
---

# Request Refactor Plan

Guide the user through creating a detailed refactoring plan with incremental commits, filed as a GitHub issue.

## Process

### 1. Problem Gathering

Ask for a detailed description of:
- What's wrong with the current structure?
- What does the desired end state look like?
- What motivated this refactor now?

### 2. Codebase Exploration

Use Agent (subagent_type=Explore) to verify assumptions and understand current state:
- Affected files, classes, signals, scene trees
- Dependencies on the code being refactored
- Existing test coverage for affected areas

### 3. Alternative Analysis

Discuss other approaches:
- Could this be solved with a smaller change?
- What trade-offs does each approach carry?
- Has the user considered other options?

### 4. Implementation Interview

Conduct thorough discussion about how to implement:
- Which modules change and in what order?
- What interfaces need to remain stable during the refactor?
- What signals, exports, or scene references will break temporarily?

### 5. Scope Definition

Establish precise boundaries:
- What changes and what stays the same
- Explicit "out of scope" items
- What is NOT being refactored (even if tempting)

### 6. Test Coverage Review

- What tests exist for affected code?
- What new tests are needed before refactoring? (safety net)
- What tests need updating after refactoring?
- Reference `docs/testing-conventions.md` for project patterns

### 7. Commit Breakdown

Decompose into minimal, working commits. Each commit must:
- Leave the project in a passing state
- Be as small as possible (one logical change)
- Follow format: `refactor(<task-id>): <description>`

### 8. GitHub Issue Creation

Create the issue with `gh issue create` using this structure:

```markdown
## Problem Statement
<Why this refactor is needed>

## Solution
<Proposed approach>

## Commits
1. `refactor: <description>` — <what and why>
2. `refactor: <description>` — <what and why>
...

## Key Decisions
- Modules affected and their new interfaces
- Architectural choices made
- Signal/scene tree changes

## Testing Decisions
- Tests to add before refactoring (safety net)
- Tests to update after refactoring
- Test strategy for verifying no regression

## Out of Scope
- <Explicitly excluded work>
```

Print the issue URL when done.
