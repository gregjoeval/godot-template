---
name: improve-codebase-architecture
description: "Systematically explore the codebase to identify architectural friction, shallow modules, and testability gaps, then propose deep-module refactoring with competing interface designs. Use when user wants to improve architecture, find refactoring opportunities, or run a codebase health check."
---

# Improve Codebase Architecture

Systematically explore the codebase to find architectural friction and propose improvements focused on deepening shallow modules. See [REFERENCE.md](REFERENCE.md) for dependency categories and testing strategy.

## Process

### Phase 1: Exploratory Analysis

Use Agent (subagent_type=Explore) to navigate the codebase organically. Look for friction:

- **Scene tree coupling**: Nodes reaching deep into other branches with `get_node("../../..")`
- **Signal spaghetti**: Signals connected across unrelated systems without clear contracts
- **Autoload bloat**: Autoloads accumulating unrelated responsibilities
- **Shallow scripts**: Node scripts whose public interface is nearly as complex as their implementation
- **Scattered concepts**: Understanding one feature requires reading 5+ files
- **Test gaps**: Modules that are hard to test in isolation

### Phase 2: Opportunity Identification

Present candidates as a list. For each:
- **Cluster**: Which files/nodes are involved
- **Coupling rationale**: Why these belong together
- **Dependency classification**: In-process, local-substitutable, remote-owned, or external (see REFERENCE.md)
- **Testing implication**: How deepening would change testability

Do NOT propose interfaces yet — just identify the opportunities.

### Phase 3: Problem Framing

For the user's chosen candidate, establish:
- Constraints any new interface must satisfy
- Required dependencies (signals, autoloads, resources)
- Concrete code sketches grounding these constraints

### Phase 4: Parallel Design Generation

Launch 3-4 parallel sub-agents (Agent tool), each designing a fundamentally different interface:

- **Minimal entry points**: Fewest public methods/signals
- **Maximum flexibility**: Generic, composable
- **Common case optimized**: Easiest path for typical usage
- **Ports & adapters**: Clean boundary with dependency injection

Each design includes: interface signatures, usage example, what's hidden, trade-offs.

### Phase 5: Comparative Analysis

Present designs sequentially, then compare on simplicity, depth, testability, and fit with project patterns from `docs/DECISIONS.md`.

Offer an opinionated recommendation.

### Phase 6: RFC Creation

Create a GitHub issue with `gh issue create` documenting the proposal:
- Architectural friction identified
- Proposed interface design
- Dependency handling strategy
- Testing approach (replace shallow unit tests with boundary tests)
- Migration path (incremental commits)
