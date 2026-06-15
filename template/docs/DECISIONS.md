# Architecture Decisions

Record project-specific architectural decisions, domain language, and patterns here.
Agents reference this file for project context.

## Domain Language

| Term | Definition |
|---|---|
| (add terms as your project evolves) | |

## Architectural Patterns

(Document your patterns: state machines, component composition, signal contracts, etc.)

## Collision Layers

(If using physics, document your collision layer assignments here.)

| Layer | Bit | Name | Used by |
|---|---|---|---|
| 1 | 1 | (your layer) | |

## Key Decisions

### Pre-push gate is non-bypassable (except `--no-verify`)

**Context:** Per-hook `SKIP=` bypasses and ad-hoc opt-outs let broken builds, failing tests, or unformatted code reach the remote.

**Decision:** `tools/hooks/pre-push` (→ `scripts/hooks/pre-push.sh`) runs build, tests, format, UID, and scene-normalization checks on every push and intentionally does **not** honor `SKIP=`. The only escape hatch is `git push --no-verify`, reserved for genuine emergencies.

**Consequences:** Consistent push-time quality at the cost of a slightly slower push. Emergency pushes are possible but explicit and visible.

### YYYY-MM-DD: Decision Title

**Context:** (What situation led to this decision?)

**Decision:** (What was decided?)

**Consequences:** (What are the trade-offs?)
