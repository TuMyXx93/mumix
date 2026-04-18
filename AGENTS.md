# AGENTS.md - Numix Orchestrator

Lean orchestrator for AI coding agents in this repo. Keep this file short and
operational. Put deep implementation details in `.opencode/skills/*`.

## Project Scope

- Flutter app for commercial math calculations (pricing, discounts, margins).
- Stack: Flutter + Dart, `provider`, `shared_preferences`.
- Architecture: Feature-First (`lib/features/`) + shared core (`lib/core/`).
- Branching: active development on `dev`, stable releases to `main`.

## Non-Negotiables

1. Before any code-modifying task, run `/version-gate`.
2. If gate has blockers, stop and report.
3. If gate has warnings, report and require user confirmation.
4. Never put business logic in widgets.
5. `lib/core/` must not import `lib/features/`.
6. Do not change existing UI layout/spacing unless explicitly requested.

## Fast Dispatch

Use the smallest path that solves the task.

1. Run gate (`/version-gate`).
2. Load only required skill(s), do not preload all skills.
3. Route to a specialized agent only when needed.

## Routing Map

- UI/screens/widgets -> `@ui-ux-agent` and/or `provider-state-skill`
- Design system/theming/component consistency -> `design-system-skill` (preferred first for UI refactors)
- Math formulas/precision/input validation -> `math-precision-skill` (mandatory)
- Tests/coverage/test fixes -> `@qa-integration-agent` (refer to `testing-qa-skill.md`)
- Android/iOS build, CI/CD, GitHub Actions -> `@devops-agent`
- Play Store release/signing/proguard -> `@play-store-architect-agent`
- Docs/changelog/commentary -> `@tech-writer-agent`
- Architecture/scaffolding -> `clean-architecture-skill`
- Commit/version/release flow -> `git-ops-skill` (use `@devops-agent` for release tags)

## Skills As Source of Detail

Do not duplicate long rulebooks here. Use:

- `.opencode/skills/clean-architecture-skill.md`
- `.opencode/skills/provider-state-skill.md`
- `.opencode/skills/design-system-skill.md`
- `.opencode/skills/testing-qa-skill.md`
- `.opencode/skills/math-precision-skill.md`
- `.opencode/skills/devsecops-workflow-skill.md`
- `.opencode/skills/git-ops-skill.md`

## Commands

- `/verify-math`: run `flutter analyze` + `flutter test test/features/`
- `/version-gate`: pre-task repository safety validation
- `/version-bump <patch|minor|major>`: version bump + changelog + tag

## Quality Gates

- Required before push: `flutter analyze` and `flutter test`
- Keep formatting with `dart format lib/`
- Avoid `// ignore:` unless justified in writing

## Memory Protocol (Engram)

Engram is mandatory in this project.

- Session start/after compaction: run `mem_context`; use `mem_search` if needed.
- For recall/research, use progressive disclosure: `mem_search` -> `mem_timeline` -> `mem_get_observation`.
- Save user intent for key requests with `mem_save_prompt` (especially release, architecture, and policy decisions).
- After meaningful work: save with `mem_save` (`bugfix`, `architecture`, `pattern`, `config`, `discovery`).
- For token-efficient capture, include `## Key Learnings:` bullets and persist with `mem_capture_passive` when appropriate.
- Wrap sensitive snippets in `<private>...</private>` before memory save to enforce redaction.
- Before ending: always run `mem_session_summary` with Goal, Instructions,
  Discoveries, Accomplished, Next Steps, Relevant Files.

Recommended topic keys:

- `architecture/feature-first`
- `architecture/provider-model`
- `pattern/math-formulas`
- `pattern/widget-conventions`
- `config/pubspec`
- `config/android-build`
