# gdUnit4Net Patterns Reference

## Test Structure

```csharp
using GdUnit4;
using static GdUnit4.Assertions;

[TestSuite]
public partial class TestMyComponent : TestSuite
{
    private MyComponent _subject = null!;

    [Before(Test)]
    public void Setup()
    {
        _subject = AutoFree(new MyComponent());
        AddChild(_subject);
    }

    [TestCase]
    public void TestInitialState()
    {
        AssertBool(_subject.IsActive).IsFalse();
    }

    [TestCase]
    public void TestActivateChangesState()
    {
        _subject.Activate();
        AssertBool(_subject.IsActive).IsTrue();
    }
}
```

- Extend `TestSuite`, annotate with `[TestSuite]`
- `[Before(Test)]` creates fresh subject per test
- One assertion concept per test
- Class must be `partial` (Godot codegen requirement)

## Node Lifecycle

**Always**: `AutoFree()` + `AddChild()`:

```csharp
// AutoFree registers for cleanup after test
_subject = AutoFree(new MyComponent());
AddChild(_subject);
```

Child nodes of an auto-freed parent don't need separate `AutoFree()`.

## Common Assertions

| Method | Purpose | Example |
|---|---|---|
| `AssertInt(val)` | Integer | `.IsEqual(42)`, `.IsGreater(0)` |
| `AssertFloat(val)` | Float | `.IsEqual(1.0f)`, `.IsEqualApprox(1.0f, 0.01f)` |
| `AssertString(val)` | String | `.IsEqual("stone")`, `.Contains("error")` |
| `AssertBool(val)` | Boolean | `.IsTrue()`, `.IsFalse()` |
| `AssertObject(val)` | Object/null | `.IsNull()`, `.IsNotNull()` |
| `AssertArray(val)` | Array | `.HasSize(3)`, `.Contains(item)` |
| `AssertSignal(obj)` | Signal (await) | `.IsEmitted("signal_name")` |

Custom failure messages: `.OverrideFailureMessage("context info")`

## Signal Testing

```csharp
[TestCase]
public async Task TestDamageEmitsHealthChanged()
{
    MonitorSignals(_healthComp);
    _healthComp.TakeDamage(10.0f);
    await AssertSignal(_healthComp).IsEmitted("HealthChanged", 90.0f, 100.0f);
}
```

- Call `MonitorSignals()` BEFORE the triggering action
- Include expected args when signal has parameters
- Signal tests are `async Task` — use `await`
- **Do NOT** use `MonitorSignals()` on autoload singletons — use manual signal connections instead

## Autoload State Resets

Reset in `[Before(Test)]` or `[After(Test)]` to prevent test pollution.
Add reset methods to `TestHelper` in `tests/helpers/TestHelper.cs` as your project grows.

```csharp
[Before(Test)]
public void Setup()
{
    TestHelper.ResetMySystem(); // add your own resets
}
```

## Multiplayer Testing

Use `TestHelper.SetupOfflineMultiplayer(this)` to make `Multiplayer.IsServer()` return `true` in tests:

```csharp
[Before(Test)]
public void Setup()
{
    TestHelper.SetupOfflineMultiplayer(this);
    _subject = AutoFree(new NetworkManager());
    AddChild(_subject);
}
```

## What to Test

| Category | Test? | Example |
|---|---|---|
| Pure logic/calculations | Yes | `CalculateValue(n)` |
| State transitions | Yes | FSM state changes |
| Signal emission | Yes | `ValueChanged` on update |
| Data classes | Yes | Typed data containers |
| Component behavior | Yes | `TakeDamage()` |
| Visual rendering | No | Sprite appearance, animations |
| Physics feel | Manual | Collision response, knockback |
| UI layout | Manual | HUD positioning, menu flow |
| Multiplayer sync | Manual | RPC delivery across peers |

## Naming

- Test files: `Test<Module>.cs` in `tests/`
- Test methods: `Test<WhatIsTested>()`
- Regression tests: `TestRegression<Description>()`
- Helper methods: private `Make<Thing>()` or `Setup<Thing>()`
- Private fields: `_camelCase`
