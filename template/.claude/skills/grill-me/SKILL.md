---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

When exploring the codebase or forming recommendations, reference the project's domain language and architectural patterns from `docs/DECISIONS.md`. Consider:
- How does this fit the project's existing architecture patterns?
- What signal contracts, component interfaces, or state machine patterns are already established?
- What are the edge cases: error handling, freed node cleanup, edge states?
- What does "done" look like from a testable acceptance criteria perspective?

Reference `docs/DECISIONS.md` for project-specific domain language, collision layers, and architectural decisions when providing recommended answers.
