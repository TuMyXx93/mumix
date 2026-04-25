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

Engram is mandatory in this project. All memory tools use MCP via the Engram binary configured in `opencode.json`.

### Session Start Protocol

1. **First call**: `mem_current_project` — confirm which project Engram detected before writing.
2. **After compaction**: Call `mem_session_summary` with compacted content first, then `mem_context`.

### Recall Protocol

Progressive disclosure for research/recall: `mem_search` → `mem_timeline` → `mem_get_observation`.

### Save Protocol (When)

Call `mem_save` immediately after:
- Bug fix completed
- Architecture or design decision made
- Non-obvious discovery about the codebase
- Configuration change or environment setup
- Pattern established (naming, structure, convention)
- User preference or constraint learned

### Save Protocol (Format)

```
**title**: Verb + what — short, searchable (e.g. "Fixed N+1 query in UserList")
**type**: bugfix | decision | architecture | discovery | pattern | config | preference | learning
**scope**: project (default) | personal
**topic_key** (optional): stable key for evolving topics — call `mem_suggest_topic_key` first if unsure
**content**:
  **What**: One sentence — what was done
  **Why**: What motivated it (user request, bug, performance, etc.)
  **Where**: Files or paths affected
  **Learned**: Gotchas, edge cases, things that surprised you (omit if none)
```

**Note**: Project is auto-detected from the server's working directory. Do NOT pass `project` to write tools — it is silently discarded.

### Topic Update Rules

- Different topics must not overwrite each other
- Reuse the same `topic_key` to update an evolving topic instead of creating a new observation
- Use `mem_update` when correcting an existing observation by ID

### User Prompts

Save user intent with `mem_save_prompt` for key requests (especially release, architecture, and policy decisions).

### Passive Capture

Include `## Key Learnings:` bullets in responses. Use `mem_capture_passive` to extract structured learnings automatically. Duplicates are skipped.

### Session Close Protocol (Mandatory)

Before ending: always `mem_session_summary` with:

```
## Goal
[What we were working on this session]

## Instructions
[User preferences or constraints discovered — skip if none]

## Discoveries
- [Technical findings, gotchas, non-obvious learnings]

## Accomplished
- [Completed items with key details]

## Next Steps
- [What remains to be done — for the next session]

## Relevant Files
- path/to/file — [what it does or what changed]
```

### Recommended Topic Keys

- `architecture/feature-first`
- `architecture/provider-model`
- `pattern/math-formulas`
- `pattern/widget-conventions`
- `config/pubspec`
- `config/android-build`
