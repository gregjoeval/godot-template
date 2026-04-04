# gdUnit4 Patterns Reference

## Test Structure

```gdscript
extends GdUnitTestSuite

var subject: MyComponent


func before_test() -> void:
    subject = auto_free(MyComponent.new())
    add_child(subject)


func test_initial_state() -> void:
    assert_bool(subject.is_active()).is_false()


func test_activate_changes_state() -> void:
    subject.activate()
    assert_bool(subject.is_active()).is_true()
```

- Extend `GdUnitTestSuite`
- `before_test()` creates fresh subject per test
- Two blank lines between functions (gdformat)
- One assertion concept per test

## Node Lifecycle

**Always**: `auto_free()` + `add_child()` with explicit type annotation:

```gdscript
# GOOD -- explicit type preserves type safety
var node: Node2D = auto_free(Node2D.new())
add_child(node)

# BAD -- auto_free returns Variant, loses type
var node := auto_free(Node2D.new())
```

Child nodes of an auto-freed parent don't need separate `auto_free()`.

## Common Assertions

| Method | Purpose | Example |
|---|---|---|
| `assert_int(val)` | Integer | `.is_equal(42)`, `.is_greater(0)` |
| `assert_float(val)` | Float | `.is_equal(1.0)`, `.is_equal_approx(1.0, 0.01)` |
| `assert_str(val)` | String | `.is_equal("stone")`, `.contains("error")` |
| `assert_bool(val)` | Boolean | `.is_true()`, `.is_false()` |
| `assert_object(val)` | Object/null | `.is_null()`, `.is_not_null()` |
| `assert_array(val)` | Array | `.has_size(3)`, `.contains([item])` |
| `assert_signal(obj)` | Signal (await) | `.call("is_emitted", "sig", [args])` |

Custom failure messages: `.override_failure_message("context info")`

## Signal Testing

```gdscript
func test_damage_emits_health_changed() -> void:
    monitor_signals(health_comp)
    health_comp.take_damage(10.0)
    await assert_signal(health_comp).call("is_emitted", "health_changed", [90.0, 100.0])
```

- Call `monitor_signals()` BEFORE the triggering action
- Use `.call()` syntax for `is_emitted`/`is_not_emitted`
- Include expected args when signal has parameters
- **Do NOT** use `monitor_signals()` on autoload singletons -- use manual signal connections instead

## Autoload State Resets

Reset in `before_test()` or `after_test()` to prevent test pollution.
Add reset methods to `GdUnitTestHelper` in `tests_gdunit4/helpers/test_helper.gd` as your project grows.

```gdscript
func before_test() -> void:
    GdUnitTestHelper.reset_my_system()  # add your own resets
```

## What to Test

| Category | Test? | Example |
|---|---|---|
| Pure logic/calculations | Yes | `calculate_value(n)` |
| State transitions | Yes | FSM state changes |
| Signal emission | Yes | `value_changed` on update |
| Data classes | Yes | Typed data containers |
| Component behavior | Yes | `take_damage()` |
| Visual rendering | No | Sprite appearance, animations |
| Physics feel | Manual | Collision response, knockback |
| UI layout | Manual | HUD positioning, menu flow |
| Multiplayer sync | Manual | RPC delivery across peers |

## Naming

- Test files: `test_<module>.gd` in `tests_gdunit4/`
- Test functions: `test_<what_is_tested>()`
- Regression tests: `test_regression_<description>()`
- Helper methods: `_make_<thing>()` (underscore prefix)
- Fixtures: no leading underscore on instance variables
