# AGENTS.md — Project Orchestrator

> This file is the **source of truth** for the project and the entry point for all agents.
> It defines code conventions, architecture rules, and orchestrates task dispatch to
> specialized agents, skills and commands configured in `.opencode/`.

## Project Overview

Flutter app for commercial math calculations (pricing, discounts, margins).

- **Framework**: Flutter SDK — Dart ^3.6.0
- **State Management**: `provider` + `shared_preferences`
- **Architecture**: Domain-Driven Feature-First (`lib/features/`, `lib/core/`)
- **Platform**: Android (primary), iOS (secondary)
- **Distribution**: Google Play Store (`.aab` bundles)

## Build / Lint / Test Commands

| Command                          | Description                                      |
| -------------------------------- | ------------------------------------------------ |
| `flutter pub get`                | Install all dependencies                         |
| `flutter run`                    | Run app on connected device / emulator           |
| `flutter analyze`                | Static analysis (required before any PR/push)    |
| `flutter test`                   | Run all unit and widget tests                    |
| `flutter test test/features/`    | Run feature-specific tests                       |
| `flutter build apk`              | Build debug APK                                  |
| `flutter build apk --release`    | Build release APK                                |
| `flutter build appbundle`        | Build release `.aab` for Play Store              |
| `dart format lib/`               | Format all Dart source files                     |
| `dart format --set-exit-if-changed lib/` | Format check (CI mode)                  |

### Running a Single Test

```sh
# Single test file
flutter test test/features/discount_calculator/discount_provider_test.dart

# Match by name pattern
flutter test --name "should calculate gross margin"
```

### Git Hooks & CI

- **Pre-push**: `flutter analyze` + `flutter test` must pass
- **CI Pipeline** (`.github/workflows/android-ci.yml`): lint + test + build `.aab`
- **Branch strategy**: develop on `dev`, only stable releases merge to `main`

## Code Style Guidelines

### Formatting (Dart)

- Follows `dart format` defaults (80-char line length)
- `analysis_options.yaml` defines linting rules — do not bypass them
- No `// ignore:` comments without a written justification

### Naming Conventions

| Element                         | Convention                  | Example                          |
| ------------------------------- | --------------------------- | -------------------------------- |
| Classes, Enums, Extensions      | UpperCamelCase              | `SalesPriceProvider`, `AppTheme` |
| Files, folders                  | snake_case                  | `sales_price_provider.dart`      |
| Variables, methods              | lowerCamelCase              | `calculateMarkup()`, `isValid`   |
| Private members                 | `_` prefix                  | `_price`, `_loadPreferences()`   |
| Constants                       | lowerCamelCase or SCREAMING | `kDefaultPadding`, `MAX_MARGIN`  |
| Test files                      | Source name + `_test.dart`  | `discount_provider_test.dart`    |

### Architecture Rules

| Layer         | Directory                            | Contains                                           |
| ------------- | ------------------------------------ | -------------------------------------------------- |
| Core          | `lib/core/`                          | Themes, constants, formatters, shared widgets      |
| Features      | `lib/features/<feature>/`            | screens/, providers/, widgets/, models/            |
| Entry point   | `lib/main.dart`                      | App bootstrap, MultiProvider registration          |

- `lib/core/` must have **zero** imports from `lib/features/`
- Features must be self-contained — no cross-feature UI imports unless via `lib/core/`
- Business logic lives exclusively in `ChangeNotifier` providers — never in widgets

### Flutter Widget Rules

- Widgets are "dumb": they only read state and dispatch events
- Use `Consumer<T>` to wrap only widgets that need to rebuild — never `context.watch()` at screen root
- Use `context.read<T>()` strictly for dispatching events (button callbacks, etc.)
- No `setState` for business logic — only for ephemeral UI state (animation controllers)
- Respect Material 3 theming: `Theme.of(context).colorScheme.*` — no hardcoded colors

### Math & Precision

- Always use `double.tryParse(value)` for user input — never `double.parse()`
- Format display values with `toStringAsFixed(2)` or `NumberFormat` (intl package)
- Markup formula: `Cost + (Cost * % / 100)`
- Gross Margin formula: `Cost / (1 - (% / 100))`
- Cascading discounts: apply each % to the **current subtotal**, not the original price
- Prevent negative prices, margins >= 100%, and invalid percentage inputs

### State Persistence

- User input values (text fields, toggles) must be saved to `SharedPreferences` inside the Provider
- On screen re-entry, restore values from Provider in `initState`

### Comments and Documentation

- Every file begins with a comment block describing its purpose
- Public provider methods and model constructors get `///` doc comments
- Inline comments for non-obvious business logic — especially math formulas
- Section dividers in large files: `// ========== SECTION NAME ==========`

---

## Pre-Task Security Gate

> CRITICAL: Before dispatching any code-modifying task to an agent, the orchestrator
> MUST verify the repository state by running `/version-gate`.

If the gate **FAILS** (there are BLOCKERS):

1. Report blockers to the user
2. Do NOT proceed until issues are resolved
3. Delegate resolution to the appropriate agent (`@devops` for CI/hooks, direct for code fixes)

If the gate **PASSES WITH WARNINGS**:

1. Report warnings to the user
2. Ask for confirmation before proceeding
3. Dispatch the task to the corresponding agent

If the gate **PASSES CLEAN**:

1. Proceed directly with the task

To run the gate manually: `/version-gate`
To create a release: `/version-bump <patch|minor|major>`

---

## Agent Orchestration System

> The entire agent system lives in `.opencode/`. This AGENTS.md acts as the orchestrator:
> reads project context, identifies the task type, and dispatches to the appropriate
> agent, skill or command. Agents inherit the active model from the session (model-agnostic).

### Available Agents

| Agent                     | Mode     | Purpose                                                                                 | Invocation                          |
| ------------------------- | -------- | --------------------------------------------------------------------------------------- | ----------------------------------- |
| **ui-ux-agent**           | subagent | Flutter widget tree, Material 3, animations, responsive design                          | `@ui-ux-agent <task>`               |
| **qa-integration-agent**  | subagent | Self-healing test loops, math coverage, widget tests                                    | `@qa-integration-agent <scope>`     |
| **devops-agent**          | subagent | Native Android/iOS builds, Gradle, GitHub Actions, CI/CD                                | `@devops-agent <task>`              |
| **play-store-architect**  | subagent | Google Play policies, app signing, `.aab` bundling, ProGuard                            | `@play-store-architect <task>`      |
| **tech-writer-agent**     | subagent | Documentation, READMEs, code comments, changelogs                                       | `@tech-writer-agent <scope>`        |

### Available Commands

| Command          | Arguments              | Description                                                          |
| ---------------- | ---------------------- | -------------------------------------------------------------------- |
| `/verify-math`   | none                   | Runs `flutter analyze` + `flutter test test/features/` and reports  |
| `/version-gate`  | `$ARGUMENTS` optional  | Pre-task security gate: validates repo state before any task         |
| `/version-bump`  | `$1` = patch/minor/major | Executes version bump with changelog and git tag                   |

### Available Skills (lazy-load on demand)

| Skill                       | Description                                                                                        |
| --------------------------- | -------------------------------------------------------------------------------------------------- |
| `clean-architecture-skill`  | Feature-First directory rules, naming conventions, layer boundaries                                |
| `provider-state-skill`      | ChangeNotifier patterns, Consumer usage, SharedPreferences persistence                             |
| `math-precision-skill`      | Floating-point handling, safe parsing, markup/margin/discount formulas                             |
| `git-ops-skill`             | Conventional Commits, atomic versioning, descriptive messages                                      |
| `devsecops-workflow-skill`  | Branch strategy (dev → main), secret blocking, CI/CD pre-validation                               |

### Dispatch Rules

CRITICAL: When a task arrives, follow these dispatch rules in order:

0. **Pre-task validation** (before any code-modifying task) → run `/version-gate`
1. **Flutter UI / widget / screen work** → use `@ui-ux-agent` or load `provider-state-skill`
2. **Math logic, formulas, calculations** → load `math-precision-skill` first, then implement
3. **Tests, coverage, test fixes** → use `@qa-integration-agent`
4. **Android build, Gradle, CI/CD, GitHub Actions** → use `@devops-agent`
5. **Play Store submission, signing, `.aab`, ProGuard** → use `@play-store-architect`
6. **Documentation, READMEs, comments** → use `@tech-writer-agent`
7. **Architecture, feature scaffolding** → load `clean-architecture-skill`
8. **Git commits, versioning, releases** → load `git-ops-skill`, use `@devops-agent` for release tags
9. **General development tasks** → use the Build agent (default) directly

### Lazy Loading Instructions

When you need specific instructions for a task, load the skill using the `skill()` tool.
Do NOT preload all skills at startup — only load what you need for the current task.

### MCP Servers

- **context7**: Library documentation search. Use `use context7` when you need to look up Flutter, Dart, Provider, Material 3, or any other project dependency docs.
- **engram**: Persistent memory across sessions. Use its tools to save decisions, recover prior context, and avoid losing work across sessions or after compaction.

---

## Persistent Memory (Engram)

> The project uses Engram as the persistent memory system across sessions.
> The OpenCode plugin (`~/.config/opencode/plugins/engram.ts`) automatically injects
> the Memory Protocol into the system prompt. The rules below are additional to the
> base protocol and are specific to this project's context.

### Memory Rules (mandatory)

**1. Post-compaction / session start:**
Before doing any work, if there are signs of compaction or if it is a new session:

```
mem_context           → recover summary from previous sessions
mem_search <keywords> → search for specific context if mem_context is not enough
```

**2. Save after significant work (immediately — do not wait until the end):**

| Event                                    | Action                                                     |
| ---------------------------------------- | ---------------------------------------------------------- |
| Bug fix completed                        | `mem_save` type=`bugfix`, What/Why/Where/Learned           |
| Architecture decision made               | `mem_save` type=`architecture`, use a stable `topic_key`   |
| Pattern established (naming, structure)  | `mem_save` type=`pattern`                                  |
| Config or pubspec change                 | `mem_save` type=`config`                                   |
| Non-obvious discovery about the codebase | `mem_save` type=`discovery`                                |

Recommended topic keys for this project:

- `architecture/feature-first` — feature directory structure decisions
- `architecture/provider-model` — state management patterns
- `pattern/widget-conventions` — Flutter widget naming and structure
- `pattern/math-formulas` — implemented business formulas and their rationale
- `config/pubspec` — dependency and SDK version decisions
- `config/android-build` — Gradle, signing, and build configuration

**3. Proactive search before starting a feature:**

```
mem_search "<feature or module>" → verify if this was worked on before
```

If there are relevant results, use `mem_get_observation <id>` for the full content.

**4. Session close (MANDATORY before saying "done" or ending):**

```
mem_session_summary → with structure:
  ## Goal
  ## Instructions
  ## Discoveries
  ## Accomplished
  ## Next Steps
  ## Relevant Files
```

**This is not optional.** Without this step, the next session starts without context.
