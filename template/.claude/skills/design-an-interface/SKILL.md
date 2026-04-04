---
name: design-an-interface
description: "Generate multiple radically different interface designs using parallel sub-agents, then compare trade-offs. Unlike grill-me (which interviews you about YOUR design), this skill creates competing designs for you. Use when user wants interface design, asks to 'design it twice', or wants to explore design options before committing."
---

# Design an Interface

Generate multiple radically different interface designs for a module or system, based on "Design It Twice" principles. This skill creates the designs — use `/grill-me` to stress-test a design you already have.

## Process

### 1. Gather Requirements

Ask about:
- What problem does this module solve?
- Who are the callers / consumers?
- What are the key operations it must support?
- What constraints exist (performance, scene tree structure, multiplayer)?
- What should be hidden vs exposed?

Explore the codebase to understand existing patterns. Reference `docs/DECISIONS.md` for architectural conventions.

### 2. Generate Designs

Launch 3-4 parallel sub-agents (Agent tool), each with a **different design constraint**:

- **Minimize surface area**: Fewest public methods/signals, maximum encapsulation
- **Maximize flexibility**: Generic, composable, supports unforeseen use cases
- **Optimize for common case**: Easiest to use for the 80% scenario
- **Paradigm shift**: Different architectural approach (e.g., signals vs polling, composition vs inheritance, resource-based vs node-based)

Each agent must produce:
- Interface signatures (public methods, signals, exports)
- Usage example (how a caller interacts with it)
- What complexity is hidden internally
- Trade-offs and limitations

### 3. Present and Compare

Present each design sequentially for absorption, then compare on:

| Criterion | Design A | Design B | Design C | Design D |
|-----------|----------|----------|----------|----------|
| Interface simplicity | | | | |
| General-purpose vs specialized | | | | |
| Module depth (small interface hiding complexity) | | | | |
| Testability | | | | |
| Correct usage vs misuse potential | | | | |
| Fit with existing project patterns | | | | |

### 4. Synthesize

Ask: "Which design fits your primary use case? What elements from others merit inclusion?"

Offer an opinionated recommendation. Combine insights from multiple designs if warranted.

## Key Principle

Your first idea is unlikely to be the best. The value is in contrasting **radically different** approaches — not minor variations. Evaluate based on interface shape, not implementation effort.
