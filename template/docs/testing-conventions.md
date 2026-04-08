# Testing Conventions

gdUnit4Net test patterns and conventions for this project.

## File Organization

All automated tests live in `tests/`, discovered by `dotnet test`.

```
tests/
  Test<Module>.cs             # one file per module
  helpers/
    TestHelper.cs             # shared utilities
  integration/
    TestIntSmoke.cs           # integration tests
  manual/
    test_<feature>.md         # manual test plans for visual/physics checks
```

- **Naming:** `Test<Module>.cs` — one test file per module or script under test
- **Helpers:** shared setup utilities in `tests/helpers/TestHelper.cs`
- **Integration:** multi-system tests in `tests/integration/`
- **Manual plans:** markdown checklists in `tests/manual/` for things that cannot be automated

## Test Structure

Every test file follows this template:

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

## Running Tests

### Command line

```bash
dotnet test
```

### Pre-commit bypass

The `dotnet-test` pre-commit hook runs tests on commit. To skip:

```bash
SKIP=dotnet-test git commit -m "your message"
```

## What to Test vs Not

| Category | Test? | Example |
|---|---|---|
| Pure logic/calculations | Yes | `CalculateSlowdown(weight)` |
| State transitions | Yes | FSM state changes |
| Signal emission | Yes | `HealthChanged` on damage |
| Data classes | Yes | Typed data containers |
| Component behavior | Yes | `TakeDamage()` |
| Visual rendering | No | Sprite appearance, animations |
| Physics feel | Manual | Collision response, knockback |
| UI layout | Manual | HUD positioning, menu flow |
| Multiplayer sync | Manual | RPC delivery across peers |
