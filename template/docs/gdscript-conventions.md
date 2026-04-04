# GDScript Conventions

Typing rules and known toolchain pitfalls for this project.

## Typed Collections

Always use `Array[T]` and `Dictionary[K, V]` for new code.
Godot 4.6 enforces types at runtime, catching mismatches early.

## Nested Generic Limitation

gdtoolkit (gdformat/gdlint) cannot parse nested generics like `Type[Type[...]]`.
Flatten the outer container and add a doc comment showing the intended type.

```gdscript
# BAD - breaks gdformat/gdlint
var items: Array[Dictionary[String, Variant]] = []

# GOOD - flatten outer, doc comment for intent
var items: Array[Dictionary] = []  ## Array[Dictionary[String, Variant]]
```

A pre-commit hook (`nested-generics`) catches these before gdtoolkit fails.

## Accessing Flattened Container Elements

Elements extracted from a flattened container (e.g., `Array[Dictionary]`) arrive as
the bare type at runtime. Use `NodeCast` helpers or typed data classes to safely
access these elements without `@warning_ignore`.

```gdscript
# BAD - runtime type error (element is bare Dictionary, not Dictionary[K, V])
var item: Dictionary[String, Variant] = items[0]

# GOOD - use bare type (the cast is safe since the container enforces the type)
var item: Dictionary = items[0]

# BEST - use a typed data class instead of Dictionary
var item := MyDataClass.new(items[0])
```

## Bare Dictionary with Doc Comment

When a type cannot be expressed due to nested generics, use the bare type with a
`##` doc comment showing the intended type.

```gdscript
var _cells: Dictionary[Vector2i, Array] = {}  ## values are Array[Node2D]
```

## Freed Node Safety

Iterating a typed array that may contain freed instances crashes at the type check
before user code runs. Connect `tree_exiting` to auto-remove, or use `NodeCast`
to filter valid instances.

```gdscript
# BAD - crashes if array contains a freed node
for node: Node2D in potentially_stale_array:
    node.do_something()

# GOOD - auto-cleanup prevents freed nodes in the array
# (connect tree_exiting to unregister)
for node: Node2D in clean_array:
    node.do_something()
```

## 2D Arrays

GDScript does not support `Array[Array[int]]`. Use `Array[Array]` instead.

```gdscript
# BAD - parse error
var grid: Array[Array[int]] = []

# GOOD
var grid: Array[Array] = []  ## Array[Array[int]]
```

## Line Length

gdformat enforces a 100-character line limit. Type annotations often push lines
past this. Break long declarations across lines or shorten variable names.

## Implicit Type Inference

Prefer `:=` (inferred type) over explicit type annotations when the type is obvious
from the right-hand side. This reduces noise and keeps declarations concise.

### CONVERT to `:=`

```gdscript
# Primitive literals matching the declared type
var health := 100
var speed := 200.0
var name := "Player"
var alive := true

# Constructors
var pos := Vector2(10, 20)
var color := Color.RED

# const declarations (always inferred)
const GRAVITY := 980.0

# @onready with constructor calls (NOT $ or % paths)
@onready var timer := Timer.new()
@onready var tween := create_tween()

# StringName and NodePath literals
var action := &"ui_accept"
var path := ^"Player/Sprite"
```

### DO NOT CONVERT — keep explicit types

```gdscript
# @export — inspector needs the type
@export var max_health: int = 100
@export var move_speed: float = 200.0

# @onready with $ or % node paths — editor uses type for autocompletion
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = %ScoreLabel

# Typed containers with empty literals — type would be lost
var enemies: Array[Enemy] = []
var scores: Dictionary[String, int] = {}

# Declarations without assignment
var target: Node2D

# Function parameters and return types
func take_damage(amount: int) -> void:
    pass

# int-to-float coercion (see pitfall below)
var speed: float = 100

# Downcasts — right-hand side type is broader than intended
var node: Node2D = get_node("path")
var resource: PackedScene = load("res://scene.tscn")
```

### Pitfall: int-to-float coercion

Integer literals like `100` have type `int`. Using `:=` infers `int`, not `float`.

```gdscript
# BAD — speed is inferred as int, breaks float math
var speed := 100

# GOOD — explicit float type with int literal
var speed: float = 100

# ALSO GOOD — float literal, safe to infer
var speed := 100.0
```

## Type Narrowing After `is` Checks

GDScript does not narrow the original variable after `if x is Subtype:`. Always create
a new typed local variable.

```gdscript
# BAD — checker still sees `child` as Node
for child: Node in group:
    if child is PlayerController:
        child.is_dead  # Error: not present on Node

# GOOD — typed local after guard
for child: Node in group:
    if not (child is PlayerController):
        continue
    var pc: PlayerController = child
    pc.is_dead  # OK
```

## Loop Variable Shadowing

Do not name a loop variable the same as a property in the base class.

## Enum Literals

Use the enum constant or an explicit cast instead of a bare integer for enum-typed
properties.

```gdscript
# BAD
center.layout_mode = 1

# GOOD
center.layout_mode = 1 as Control.LayoutMode
```

## Dictionary Value Access

Values retrieved from an untyped `Dictionary` are `Variant`. Assign to a typed local
before passing to a function that expects a concrete type.

```gdscript
# BAD — int() receives Variant
map_generator.configure(int(data["width"]), int(data["height"]))

# GOOD
var w: int = data["width"]
var h: int = data["height"]
map_generator.configure(w, h)
```

## `collision_layer` Access

`collision_layer` is defined on `CollisionObject2D`, not `Node2D`. When checking
collision layers on physics bodies, cast to `CollisionObject2D` first.

```gdscript
# BAD — Node2D has no collision_layer
for body: Node2D in area.get_overlapping_bodies():
    if body.collision_layer & 2:  # Error

# GOOD
for body: Node2D in area.get_overlapping_bodies():
    if not (body is CollisionObject2D):
        continue
    var co: CollisionObject2D = body
    if co.collision_layer & 2:
        pass
```

## Shader Rules

`return` is banned inside shader processor functions (`fragment`, `vertex`, `light`).
Use `if`/`else` blocks instead of early returns.

A pre-commit hook (`shader-no-return`) enforces this automatically.

## Type Safety Policy

`@warning_ignore` annotations are **banned** in all GDScript files. The only exceptions
are `scripts/util/config_helper.gd` and `scripts/util/node_cast.gd`, which centralize
unavoidable casts. A pre-commit hook (`no-warning-ignore`) enforces this automatically.

### What to use instead

| Problem | Solution |
|---|---|
| Raw `Dictionary` with known keys | Create a typed data class |
| `ConfigFile.get_value()` returns `Variant` | Use `ConfigHelper.get_string()`, `.get_int()`, etc. |
| Node downcasting (`get_node()` returns broad type) | Use `NodeCast.as_node_2d()`, `.as_sprite()`, etc. |
| Typed `Array.pop_back()` returns `Variant` | Use `NodeCast.pop_back_node()` |
| Freed nodes in typed arrays | Auto-cleanup via `tree_exiting` signal |

### Project-level suppressions

Only `integer_division` and `unused_signal` are suppressed at the project level
(GDScript warning level 0 in `project.godot`). These do not require per-file annotations.

### Adding new unavoidable warnings

If you encounter a warning that genuinely cannot be resolved with typed code:

1. Check if `ConfigHelper` or `NodeCast` can handle it — add a method there if needed
2. If not, create a new utility file with a focused purpose
3. Add the new file to the `exclude` list in `.pre-commit-config.yaml`
4. Never scatter `@warning_ignore` across feature code
