---
name: tdd
description: Guide test-driven development using red-green-refactor cycles with gdUnit4Net. Emphasizes vertical slices (one test drives one implementation), behavior-driven testing through public interfaces, and C# conventions. Use when implementing features, fixing bugs with TDD, or when user mentions "tdd", "test first", or "red green".
---

# Test-Driven Development (gdUnit4)

## Philosophy

Tests verify **behavior through public interfaces**, not implementation details. A good test reads like a specification and survives internal refactors. See [testing-philosophy.md](testing-philosophy.md).

## Anti-Pattern: Horizontal Slices

**DO NOT** write all tests first, then all implementation. This produces tests that verify imagined behavior.

```
WRONG:  RED: test1,test2,test3  ->  GREEN: impl1,impl2,impl3
RIGHT:  RED->GREEN: test1->impl1,  RED->GREEN: test2->impl2, ...
```

## Workflow

### 1. Planning

- [ ] Confirm which behaviors to test (prioritize with user)
- [ ] Identify what to test vs skip (see `docs/testing-conventions.md` "What to Test" table)
- [ ] List behaviors, not implementation steps
- [ ] Get user approval on the plan

### 2. Tracer Bullet

Write ONE test confirming ONE behavior. See [gdunit4-patterns.md](gdunit4-patterns.md) for syntax.

```
RED:   Write test -> test fails
GREEN: Write minimal code -> test passes
```

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test -> fails
GREEN: Minimal code to pass -> passes
```

- One test at a time, one vertical slice
- Only enough code to pass current test
- Don't anticipate future tests
- Bug fixes: name tests `test_regression_<description>`

### 4. Refactor

After all tests pass:

- [ ] Extract duplication
- [ ] Simplify interfaces (deep modules)
- [ ] Run tests after each refactor step
- [ ] **Never refactor while RED** -- get to GREEN first

## Per-Cycle Checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

## References

- [gdunit4-patterns.md](gdunit4-patterns.md) -- assertions, lifecycle, signals, multiplayer
- [testing-philosophy.md](testing-philosophy.md) -- deep modules, mocking, refactoring
- `docs/testing-conventions.md` -- project naming, file structure, helpers
