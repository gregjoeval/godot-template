---
name: review-plan
description: Iteratively review the current plan file for completeness, improvements, best practices, and regression safety. Invoke with /review-plan or /review-plan <number-of-passes>. Use when the user asks to review, stress-test, or sanity-check a plan.
allowed-tools: Read, Glob, Grep, AskUserQuestion, ExitPlanMode, Edit
---

## Instructions

1. **Find the active plan file**: Glob for `.claude/plans/*.md` and read the most recent one. If no plan file exists, tell the user there is no plan to review.

2. **Run review passes** (default: 5, or use $ARGUMENTS if a number is provided):

   For each pass, evaluate the plan against these questions and note any issues:

   - **Anything missed?** — Edge cases, error handling, affected systems, missing dependencies, untested paths
   - **Anything to improve?** — Simpler approaches, fewer files touched, reuse of existing utilities/patterns, unnecessary complexity
   - **Does this follow best practices?** — Project conventions (CLAUDE.md), typing rules, multiplayer patterns, architectural consistency
   - **Does this avoid future regression?** — What could break? What tests are needed? Are there side effects on existing behavior?

3. **After each pass**, write a brief summary:
   - Pass N: [issues found or "no issues"]
   - Suggested revisions (if any)

4. **Present the final output**:
   - A numbered list of all revisions suggested across all passes
   - If no issues were found across all passes, say so explicitly
   - Do NOT modify the plan file — present suggestions for the user to accept

5. **Ask the user for a decision** using `AskUserQuestion`:
   - Option 1: "Ready for handoff" — the plan is good to hand off to the Architect/Daemon agents
   - Option 2: "Suggest changes" — the user wants to provide feedback (they can type their suggestions via the input)
   - If the user selects "Ready for handoff", call `ExitPlanMode` so the Overseer can proceed with handoff
   - If the user suggests changes, apply their feedback to the plan file and re-run a single review pass, then ask again

## Notes
- The review passes are read-only. The skill only edits the plan file if the user suggests changes.
- Focus on actionable, specific feedback — not generic advice.
- Reference specific sections of the plan when suggesting changes.
