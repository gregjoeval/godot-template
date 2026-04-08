---
name: triage-issue
description: Triage a bug by exploring the codebase to find root cause, then create a Ready issue with a TDD-based fix plan. Use when user reports a bug, wants to investigate a problem, or mentions "triage".
---

# Triage Issue

Investigate a reported problem, find its root cause, and create a Ready issue with a TDD fix plan. Mostly hands-off -- minimize questions to the user.

## Process

### 1. Capture

Get a brief problem description. If the user hasn't provided one, ask ONE question: "What's the problem you're seeing?" Then investigate immediately.

### 2. Explore and Diagnose

Use the Agent tool with `subagent_type=Explore` to deeply investigate:

- **Where** the bug manifests (C# files, scene tree, signal handlers)
- **What** code path is involved (trace the flow through autoloads, components, signals)
- **Why** it fails (root cause, not just the symptom)
- **What** related code exists (existing tests, similar working patterns, recent git changes)

Check: source files in `scripts/`, existing tests in `tests/`, `git log` on affected files, error handling flow.

### 3. Identify Fix Approach

Determine: minimal change needed, affected modules/interfaces, behaviors to verify, whether this is a regression, missing feature, or design flaw.

### 4. Design TDD Fix Plan

Create ordered RED-GREEN cycles (vertical slices):

- **RED**: Test capturing broken/missing behavior. Name regression tests `test_regression_<description>`.
- **GREEN**: Minimal code change to pass.
- Tests verify behavior through public interfaces, not implementation details.
- Each test should survive internal refactors.
- Include a REFACTOR step if needed.

### 5. Create Ready Issue

Run `rd create` with the investigation results. Do NOT ask the user to review first.

Include in the description:
- **Problem**: actual vs expected behavior, reproduction steps
- **Root cause**: modules and contracts involved (not file paths or line numbers)
- **TDD fix plan**: numbered RED-GREEN cycles
- **Acceptance criteria**: checklist

If a GitHub Issue exists, link with `--context "gh#<N>: ..."`.

Print the issue ID and a one-line root cause summary when done.
