# Dependency Categories & Testing Strategy

Reference material for the improve-codebase-architecture skill.

## Dependency Categories

When assessing whether modules can be deepened (merged behind a simpler interface), classify their dependencies:

### In-process dependencies
Pure computation and in-memory state, no I/O. Always deepenable — merge directly.

**Godot examples**: Utility functions, Resource subclasses, pure GDScript calculations, state machine logic.

### Local-substitutable dependencies
Test stand-ins available locally. Deepenable when the substitute exists.

**Godot examples**: Scene tree (instantiate test scenes), file I/O (use `res://` test fixtures), timer-based logic (use `await_idle_frame` in gdUnit4).

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

```gdscript
# Test the deep module through its public interface
func test_combat_system_applies_damage_with_armor_reduction() -> void:
    var combat = CombatSystem.new()
    combat.configure(base_damage = 10, armor = 3)
    var result = combat.resolve_attack()
    assert_int(result.damage_dealt).is_equal(7)

# NOT: test_calculate_armor_reduction, test_apply_damage_modifier, etc.
# Those test implementation details that may change during refactoring
```
