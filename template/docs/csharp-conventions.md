# C# Conventions

Typing rules, Godot C# patterns, and analyzer configuration for this project.

## Naming Conventions

- **PascalCase** for classes, methods, properties, events, and signals
- **camelCase** for local variables and parameters
- **_camelCase** for private fields (prefix with underscore)
- **UPPER_SNAKE_CASE** for constants

## No Namespaces

This project uses flat global classes (no namespaces) to mirror the GDScript `class_name` pattern.
The `.csproj` sets `<RootNamespace />` to empty. Roslyn diagnostics for missing namespaces are
suppressed in `.editorconfig` (`CA1050`, `MA0047`, `IDE0160`, `IDE0161`, `RCS1110`).

## Godot C# Patterns

### Partial Classes

All Godot node classes must be `partial` — Godot's source generator creates the other half.
Never seal Godot node classes.

```csharp
public partial class Player : CharacterBody2D
{
    [Export] public float Speed { get; set; } = 200f;
}
```

### Exports

Use `[Export]` attribute instead of GDScript's `@export`. Exported properties are set by the
engine after construction, so they appear uninitialized to the compiler — `CS8618` is suppressed
in `.editorconfig`.

### Signals

Define signals with the `[Signal]` attribute on a delegate:

```csharp
[Signal] public delegate void HealthChangedEventHandler(int newHealth);
```

Emit with: `EmitSignal(SignalName.HealthChanged, newHealth);`

### Node Access

Use `GetNode<T>()` for typed access instead of `$` syntax:

```csharp
var sprite = GetNode<Sprite2D>("Sprite2D");
```

### Autoloads

Access autoloads via `GetNode<T>("/root/AutoloadName")` or dependency injection patterns.

## Roslyn Analyzers

This project uses **Meziantou.Analyzer** and **Roslynator.Analyzers** with `TreatWarningsAsErrors`.
The `.editorconfig` suppresses Godot-incompatible rules:

| Rule | Reason |
|------|--------|
| `IDE0055` | CSharpier owns formatting |
| `CA1050`, `MA0047` | No namespaces convention |
| `MA0053`, `MA0076`, `MA0048` | Godot requires partial (non-sealed, non-static) classes |
| `MA0016` | Godot Resource mutable collections are `List<T>` by convention |
| `MA0001`, `MA0006` | Godot string methods don't accept `StringComparison` |
| `IDE0290` | Primary constructors not relevant for Godot Node/Resource classes |
| `IDE0300`–`IDE0305` | Collection expression suggestions — prefer explicit `new()` |

### Test-Specific Suppressions

In `tests/**/*.cs`:
- `CA1822` — gdUnit4Net test methods use reflection, must be instance methods
- `CA1001` — gdUnit4Net manages test class lifecycle
- `CA1861` — Static readonly arrays add noise for one-off test data

## CSharpier

Code formatting is handled by **CSharpier** (not `dotnet format`). Configuration in `.csharpierrc.yaml`:
- `printWidth: 100`

Run manually: `dotnet csharpier check .` (note: no double-dash before `check`)

## Testing

Tests use **gdUnit4Net** (`gdUnit4.api` + `gdUnit4.test.adapter` NuGet packages).
Run with `dotnet test`. See `docs/testing-conventions.md` for patterns and structure.

## Type Safety

- `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` — all warnings are build errors
- `<Nullable>enable</Nullable>` — nullable reference types enforced
- `<AnalysisLevel>latest-recommended</AnalysisLevel>` — latest Roslyn analysis rules
- `<EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>` — code style rules enforced at build time
