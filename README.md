# godot-template

A [Copier](https://copier.readthedocs.io/) template that scaffolds production-ready Godot 4.x game projects with strict typing, automated testing, CI/CD, and optional multiplayer support.

## What You Get

- **GDScript strict typing** enforced by Godot's built-in type checker
- **gdtoolkit** linting and formatting (100-char line limit)
- **gdUnit4** test framework with helpers and TDD workflow
- **12 pre-commit hooks** covering format, lint, type check, scene normalization, and more
- **GitHub Actions CI** gate (lint, type check, smoke test, gdUnit4, scene normalization) with change detection
- **GitHub Actions build** workflow for Linux/Windows exports
- **Claude Code integration** with agent definitions, skills, safety hooks, and a comprehensive `CLAUDE.md`
- **Conventional commits** via commitizen with version bumping
- **Makefile** with `test`, `test-single`, `lint`, `check`, `bump` targets
- **Optional multiplayer scaffolding** with server-authoritative NetworkManager and RPC patterns

## Prerequisites

- Python 3
- [Copier](https://copier.readthedocs.io/) 9+
- Godot 4.x
- Git

## Quick Start

```sh
uvx copier copy gh:gregjoeval/godot-template my-game
cd my-game
```

Follow the setup instructions in the generated `README.md` to install git hooks and tooling.

To pull template updates into an existing project:

```sh
uvx copier update
```

## Template Options

| Variable | Type | Default | Description |
|---|---|---|---|
| `project_name` | str | `My Godot Game` | Human-readable project name |
| `project_slug` | str | *(derived from name)* | Kebab-case slug for directories and build artifacts |
| `multiplayer` | bool | `false` | Include NetworkManager autoload and RPC scaffolding |
| `godot_version` | str | `4.6` | Godot version (must be 4.x) |

## Generated Project Structure

```
my-game/
  .claude/             # Claude Code agents, skills, hooks, settings
  .github/workflows/   # CI gate + build/export
  docs/                # GDScript conventions, testing conventions, decisions, principles
  scenes/              # Godot scenes (main.tscn)
  scripts/
    tools/             # Quality-gate scripts (type check, lint, normalize, etc.)
    network/           # NetworkManager (multiplayer only)
  tests_gdunit4/       # gdUnit4 tests and helpers
  .pre-commit-config.yaml
  CLAUDE.md
  Makefile
  project.godot
  pyproject.toml
```

## Quality Gates

Generated projects include 12 pre-commit hooks:

`godot-normalize` · `nested-generics` · `preload-shadows` · `no-warning-ignore` · `type-narrowing` · `gdformat` · `gdlint` · `shader-no-return` · `gdtypecheck` · `gdtest` · `commitizen`

See the generated `docs/gdscript-conventions.md` for details on the rules these enforce.

## Template Development

To test the template locally:

```sh
uvx copier copy --defaults --trust . /tmp/test-output
```

The template's own CI (`.github/workflows/template-test.yml`) generates projects with both `multiplayer=false` and `multiplayer=true`, then runs type checks, linting, and gdUnit4 tests on each.
