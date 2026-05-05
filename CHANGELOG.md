# Changelog

## [Unreleased] — Breaking: agent-workflow content removed

The template is now scoped to engine/build/test scaffolding only. Agent-workflow content
was removed because it evolves rapidly in live projects and a templated snapshot drifts
out of date immediately.

### Removed
- `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/settings.local.json`
- `scripts/tools/setup-gh-app.sh.jinja`, `gh-app-token.sh.jinja`, `cleanup-worktrees.sh`
- Copier variable `reviewer_github_app_name` (and its conditional `_exclude` entries)
- `Makefile.jinja` target `setup-gh-app`
- `.gitignore` entries: `.claude/worktrees/`, `.campfire/`
- `.claude/settings.json` permissions: `Bash(rd *)`, `Bash(cf *)`; the `hooks.PostToolUse` block
- `CLAUDE.md.jinja` sections: Session Isolation/Worktree, Overseer Role, Architect Launch Protocol, Execution Protocol, Developer/Reviewer Cycles, Environment Bootstrap, Campfire, Ready Quick Reference, Backlog Management, PR Merge Rules, Permission Model, Persistent Agent Memory

### Added
- `scripts/tools/check_tres_casing.sh` — pre-commit check for snake_case property names in `.tres` `[resource]` sections (won't bind to PascalCase `[Export]`)
- `scripts/tools/SmokeTest.cs` — generic Godot smoke runner for CI (loads main scene, runs 120 frames, exits)
- pre-commit hook: `tres-casing-check`
- editorconfig: `CA1707` suppression for underscore-separated test names (`Method_Scenario_Expected`)
- `README.md.jinja` scoping note declaring the template's intentional minimalism

### Changed
- `scripts/tools/normalize_scenes.sh` — runs `dotnet build` before headless import so `[GlobalClass]` attributes are discovered and `global_script_class_cache.cfg` is populated; without this, UIDs aren't assigned and `.tres` `ext_resource` entries aren't updated
- `scripts/tools/merge-guard.sh.jinja` → `scripts/tools/merge-guard.sh` (no Copier vars left): branch+SHA filter for `gh < 2.30` compatibility; personal-repo `--admin` fallback when App-token merge is rejected by branch protection. App-token usage is now opt-in via the `APP_TOKEN` env var.

### Migration
Downstream projects running `copier update` will see large deletions. Recommended migration:

1. Commit current state.
2. Run `copier update`.
3. If you rely on agent workflow content (Architect/Daemon/Reviewer protocols, Campfire, Ready), copy your live project's `.claude/` and CLAUDE.md sections back in manually after the update — those lived in the template snapshot but are now project-local concerns.
4. If you used a GitHub App for PR merges, generate the App token externally and export `APP_TOKEN` before invoking `merge-guard.sh`. The template no longer bundles `gh-app-token.sh`.
