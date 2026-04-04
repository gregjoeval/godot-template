# Development Principles

Principles are heuristics with trade-offs, not laws. Apply them when they reduce actual complexity. Every principle below includes guidance on when it helps and when it hurts.

**Meta-principle: Pragmatism over Dogma.** The most common anti-pattern isn't ignoring principles — it's over-applying them. Three similar lines of code is often better than a premature abstraction. A slightly longer file is often better than a fragmented one. Context determines which principle wins when they conflict.

---

## Core Principles

### KISS — Keep It Simple

Do the simplest thing that works. Favor straightforward solutions over clever ones.

**When it helps:** Default stance for all decisions. Simple code is easier to read, test, debug, and modify. In game dev, explicit behavior is almost always better than a generic system.

**When it hurts:** Rarely. If you think KISS is hurting you, you're probably confusing "simple" with "naive." Simple doesn't mean unstructured — it means no unnecessary complexity.

### YAGNI — You Aren't Gonna Need It

Don't implement features, abstractions, or infrastructure not required by current acceptance criteria.

**When it helps:** Prevents scope creep, speculative architecture, and "might need later" code that usually turns out wrong anyway. Especially valuable in game dev where requirements shift constantly.

**When it hurts:** Some anticipatory design IS reasonable — a data-driven system for enemy types is fine if you know you'll have multiple enemies. The test: "Am I building this because I need it now, or because I imagine needing it later?"

### DRY — Don't Repeat Yourself

Every piece of knowledge should have a single, authoritative representation.

**When it helps:** Reduces bugs from updating one copy but not another. Logic that must stay synchronized (validation rules, data transformations, business rules) should live in one place.

**When it hurts:** DRY applied too eagerly creates bad abstractions. If two pieces of code look similar but have **different reasons to change**, they aren't true duplication — they're coincidental similarity. Extracting a shared function couples them unnecessarily. Prefer duplication over the wrong abstraction.

**Rule of thumb:** Tolerate duplication until the third occurrence AND you can articulate a shared concept, not just shared syntax.

### SRP — Single Responsibility Principle

Each module (script, class, function) should have one reason to change.

**When it helps:** Makes code predictable. When a health system bug appears, you look at the health module, not five scattered files.

**When it hurts:** Taken to extremes, SRP fragments code into dozens of tiny classes that are individually simple but collectively incomprehensible. Don't split a Player into PlayerMovement, PlayerAnimation, PlayerInput, PlayerState unless they genuinely need to evolve independently. Group related logic that changes together.

**Godot-specific:** One script per node is the natural granularity. Don't create helper scripts just to satisfy SRP if the logic belongs to that node.

---

## SOLID (Beyond SRP)

### Open/Closed Principle

Open for extension, closed for modification. Add new behavior without changing existing code.

**When it helps:** Extend via signals, composition, `@export` callbacks, and new scene branches. Adding a new enemy type shouldn't require editing every existing enemy.

**When it hurts:** Designing for extensibility you don't need yet is YAGNI in disguise. If there's only one implementation, don't create an abstraction point "just in case."

### Liskov Substitution Principle

Subclasses must honor base class contracts. If code works with a base type, it must work with any subclass.

**When it helps:** Prevents subtle bugs where overriding a method breaks assumptions elsewhere.

**When it hurts:** Rarely an issue in GDScript since deep inheritance hierarchies are discouraged anyway. If you're fighting LSP violations, the fix is usually composition, not more careful inheritance.

### Interface Segregation Principle

Keep interfaces small and focused. Don't force consumers to depend on methods they don't use.

**When it helps:** Reduces coupling. A node that only needs `take_damage()` shouldn't depend on an interface that also includes `equip_weapon()`.

**When it hurts:** GDScript doesn't have formal interfaces. Over-splitting signals or creating many tiny component scripts for ISP's sake adds indirection without benefit. In Godot, duck typing and signals naturally provide segregation.

### Dependency Inversion Principle

Depend on abstractions (signals, groups, EventBus), not concrete implementations (direct `get_node()` paths).

**When it helps:** Lets you rearrange the scene tree without breaking scripts. Lets you test modules in isolation.

**When it hurts:** For tightly co-located parent-child nodes that will always be together, a direct `%ChildNode` reference is simpler and clearer than an EventBus indirection.

---

## Composition & Architecture

### Composition over Inheritance

Build behavior by combining small, focused components rather than deep inheritance chains.

**When it helps:** Almost always in game development. Inheritance hierarchies break down when objects need flexible, dynamic behavior (an enemy that can also be ridden, a weapon that's also a shield). Godot's node tree is already composition-based — leverage it.

**When it hurts:** Scene inheritance is fine for structural/visual reuse (e.g., a BaseEnemy scene with health bar, collision shape, sprite that specific enemies extend). The anti-pattern is deep _behavior_ inheritance, not structural reuse.

**Godot pattern:**
```
# PREFER: Composition via child nodes
Enemy (CharacterBody2D)
├── HealthComponent
├── DamageComponent
├── AIController
└── AnimationController

# AVOID: Deep inheritance chains
Enemy -> MeleeEnemy -> FastMeleeEnemy -> FastMeleeEnemyWithShield
```

### Deep Modules (Ousterhout)

A good module has a simple interface hiding substantial implementation complexity. A shallow module (large interface relative to implementation) pushes complexity onto callers.

**When it helps:** Reduces cognitive load at the call site. A combat system with `resolve_attack(attacker, defender) -> Result` is better than one exposing `calculate_armor()`, `apply_modifier()`, `check_evasion()`, `compute_final_damage()` separately.

**When it hurts:** Hiding too much can make debugging harder. Ensure the interface still communicates intent — a single `do_everything()` method is deep but opaque. The interface should be simple, not absent.

**Test implication:** Deep modules enable behavior-level testing through the public interface, eliminating fragile tests that break on internal refactors.

### Coupling and Cohesion

**High cohesion:** Everything in a module works toward a common purpose. All health-related logic lives in HealthComponent, not scattered across Player, UI, and GameManager.

**Low coupling:** Modules are independent. Changing HealthComponent doesn't force changes in DamageComponent.

**When it helps:** High cohesion means you can understand a concept by reading one file. Low coupling means you can modify one system without cascading changes.

**When it hurts:** Maximizing both simultaneously isn't always possible. Sometimes the pragmatic choice is a slightly coupled module that's easy to understand vs. a perfectly decoupled one that requires indirection layers. Choose based on what actually changes together in practice, not in theory.

---

## Code Quality

### Code Smells — When to Refactor

These aren't bugs — they're indicators of design friction:

| Smell | Signal | Likely Fix |
|-------|--------|------------|
| **Long method** (>40 lines of logic) | Hard to name, does multiple things | Extract methods by intent |
| **God class** (script with unrelated responsibilities) | Changes for many different reasons | Split into focused components |
| **Feature envy** (script uses another script's data more than its own) | Coupling in the wrong direction | Move logic to the data owner |
| **Shotgun surgery** (one change touches 5+ files) | Low cohesion, scattered concept | Group related logic together |
| **Deep nesting** (>3 levels of if/for) | Hard to follow control flow | Early returns, extract methods |
| **Magic numbers/strings** | Intent unclear, duplicated values | Named constants or enums |
| **Long parameter list** (>4 params) | Method doing too much | Parameter object or split method |

**Important:** A smell is a signal to investigate, not an automatic refactoring trigger. If the code is clear, tested, and stable, a smell alone isn't reason to change it.

### When NOT to Apply Principles

| Situation | What to do instead |
|-----------|-------------------|
| Two functions look similar but serve different features | Let them duplicate — they have different reasons to change |
| A class is "too big" but everything in it changes together | Leave it — SRP is about reasons to change, not line count |
| You could add an abstraction layer "for flexibility" | Wait until you need the flexibility — YAGNI |
| A function is long but reads top-to-bottom clearly | Leave it — extraction would scatter a linear flow across methods |
| You want to mock something for testing | Check if you can test through the public interface first — mocking is often a sign of tight coupling, not a solution |
| A pattern from another language doesn't map to GDScript | Use Godot's native patterns (signals, scenes, resources) instead of forcing external paradigms |

---

## Principle Priority

When principles conflict, resolve in this order:

1. **Correctness** — Does it work? Does it handle edge cases?
2. **Clarity** — Can someone else (or future you) understand it?
3. **Simplicity** (KISS) — Is this the simplest approach that works?
4. **Testability** — Can behavior be verified through the public interface?
5. **Modularity** (SRP, cohesion) — Does related logic live together?
6. **Flexibility** (OCP, DIP) — Can it be extended without modification?

Lower-priority principles yield to higher ones. Don't sacrifice clarity for modularity. Don't sacrifice simplicity for flexibility you don't need.
