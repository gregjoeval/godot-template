# Testing Philosophy

## Deep Modules

A deep module has a **small, simple interface** hiding **significant implementation complexity**. Test the interface, not the internals.

Good: test `MyComponent.calculate_value(weight)` returns expected values for various inputs.
Bad: test that `calculate_value` internally uses a specific formula with specific constants.

When designing code for testability, prefer deep modules -- they give you a stable test surface that survives refactoring.

## Mocking Guidelines

**Prefer real code paths over mocks.** Most of our code can be tested with real objects using `auto_free()` + `add_child()`.

**When to mock:**
- External dependencies (network, filesystem) -- but prefer `OfflineMultiplayerPeer` for multiplayer
- Autoload state that's expensive to reset -- but we have `GdUnitTestHelper.reset_*()` methods

**When NOT to mock:**
- Internal collaborators (components within a scene)
- Simple data objects
- Anything you can test directly through the public interface

**Warning sign:** If your test breaks when you refactor internals but behavior hasn't changed, you're testing implementation, not behavior.

## Refactoring in TDD

1. **Never refactor while RED** -- get to GREEN first
2. Run tests after each refactor step
3. Refactoring should not change behavior -- tests must still pass
4. Look for refactor opportunities after all tests pass:
   - Extract duplication
   - Simplify interfaces
   - Move complexity behind simpler APIs
   - Consider what new code reveals about existing code

## Test Sensitivity

A well-calibrated test:
- **Fails** when user-facing behavior breaks
- **Passes** when behavior is preserved despite internal changes
- **Reads like a specification** -- someone unfamiliar with the code can understand what the system does

A poorly-calibrated test:
- Fails when you rename an internal function
- Passes when actual behavior is broken
- Tests the shape of data rather than outcomes
