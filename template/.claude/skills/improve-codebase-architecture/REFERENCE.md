# Dependency Categories & Testing Strategy

Reference material for the improve-codebase-architecture skill.

## Dependency Categories

When assessing whether modules can be deepened (merged behind a simpler interface), classify their dependencies:

### In-process dependencies
Pure computation and in-memory state, no I/O. Always deepenable — merge directly.

**Godot examples**: Utility functions, Resource subclasses, pure C# calculations, state machine logic.

### Local-substitutable dependencies
Test stand-ins available locally. Deepenable when the substitute exists.

**Godot examples**: Scene tree (instantiate test scenes), file I/O (use `res://` test fixtures), timer-based logic (use `await_idle_frame` in gdUnit4Net).

### Remote but owned dependencies
Your own networked services. Define a port interface at the module boundary with both production and test adapters.

**Godot examples**: Game server connections, lobby services, matchmaking. Create an in-memory adapter for testing the deep module as a unit.

### True external dependencies
Third-party services requiring mocking at the boundary. The deepened module accepts the dependency as an injected port.

**Godot examples**: Platform APIs (Steam, authentication providers), analytics services. Test with mock implementations.

## Testing Strategy

### Core Principle: Replace, Don't Layer

When you deepen a module:
1. **Eliminate** shallow unit tests that tested the old internal boundaries
2. **Write new tests** at the deepened module's public interface
3. **Tests describe behavior**, not implementation details
4. Tests should survive internal refactors without modification

### What Good Boundary Tests Look Like

```csharp
// Test the deep module through its public interface
[TestCase]
public void TestCombatSystemAppliesDamageWithArmorReduction()
{
    var combat = new CombatSystem();
    combat.Configure(baseDamage: 10, armor: 3);
    var result = combat.ResolveAttack();
    AssertInt(result.DamageDealt).IsEqual(7);
}

// NOT: TestCalculateArmorReduction, TestApplyDamageModifier, etc.
// Those test implementation details that may change during refactoring
```
