# AGENTS.md - Numix Orchestrator

This file is the source of truth for AI-assisted work. Keep it concise — detailed protocols live in specialized files and Engram memory.

Research-backed: The "evaluando-agents" study (ETH Zurich, 2026) shows context files reduce task success and increase cost 20%+ when verbose. Keep requirements minimal.

## Project Overview

Flutter app for commercial math calculations (pricing, discounts, margins).
Stack: Flutter 3.27+ / Dart 3.7+ / provider / shared_preferences.
Architecture: Feature-First (`lib/features/`) + shared core (`lib/core/`).
Deployment: Play Store (Android), future iOS.

## Branch Policy

- `dev`: development (all work starts here)
- `main`: stable production branch

**Rules**: Implement in `dev` or feature branches. Merge to `main` only after validations pass.

## Validation Commands

See `.opencode/commands/` for specs:

- `/version-gate` — branch check + flutter analyze + flutter test + flutter build apk --debug
- `/verify-math` — flutter analyze + flutter test test/features/
- `/audit-orchestrator` — consistency audit for AGENTS, agents, skills, commands

## Architecture Rules

- `lib/features/`: feature modules (screens, providers, models)
- `lib/core/`: shared utilities, themes, constants
- `lib/core/` must NOT import `lib/features/`
- Business logic lives in providers, never in widgets

## Pre-Task Gate

Before code modifications, run `/version-gate`.

- FAIL: stop and fix blockers
- PASS WITH WARNINGS: proceed with caution and report risks
- PASS: implement directly

## Agent System

Assets live in `.opencode/`.

### Agents

| Agent                       | Role                                                    |
| --------------------------- | ------------------------------------------------------- |
| `ui-ux-agent`               | Flutter UI, Material 3, animations, accessibility        |
| `qa-integration-agent`      | Tests, coverage, quality regressions                    |
| `devops-agent`              | Android/iOS build, CI/CD, native tooling                |
| `play-store-architect-agent` | Play Store releases, signing, AAB, proguard             |
| `tech-writer-agent`         | docs, changelog, README                                 |

Each agent must return: Scope touched, Decisions made, Risks and follow-up actions, Memory saves triggered.

See `.opencode/agents/` for guidelines per agent.

### Commands

| Command                      | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
| `/version-gate`              | Pre-task: branch + analyze + test + build            |
| `/verify-math`               | Math validation: analyze + feature tests              |
| `/version-bump <patch\|major\|minor>` | Release workflow                            |
| `/audit-orchestrator`        | Consistency audit for orchestrator files             |
| `/engram-status`             | Memory health and project hygiene                    |

See `.opencode/commands/` for action specs.

### Skills

- `clean-architecture-skill`
- `provider-state-skill`
- `design-system-skill`
- `testing-qa-skill`
- `math-precision-skill`
- `git-ops-skill`
- `devsecops-workflow-skill`

See `.opencode/skills/` for detailed rules.

## Dispatch Order

1. Run `/version-gate` for code edits
2. UI/layout/animation → `ui-ux-agent`
3. Math/precision → `math-precision-skill` (mandatory)
4. Tests/quality → `qa-integration-agent`
5. Build/CI → `devops-agent`
6. Play Store → `play-store-architect-agent`
7. Docs → `tech-writer-agent`

## MCP and Memory

### MCP Tools

**context7**: Dependency/framework documentation resolver. Use to fetch up-to-date library docs.

**engram**: Persistent memory system for AI coding agents. 16 tools available:

| Category          | Tools                                                                                              |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| Save & Update     | `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key`                                    |
| Search & Retrieve | `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation`                                 |
| Session Lifecycle | `mem_session_start`, `mem_session_end`, `mem_session_summary`                                      |
| Utilities         | `mem_save_prompt`, `mem_stats`, `mem_capture_passive`, `mem_merge_projects`, `mem_current_project` |

### Engram Cloud (opt-in — documentation only, pending server)

Background push/pull replication for multi-machine sync.

**Enable autosync** (all three env vars required, when server available):
```
ENGRAM_CLOUD_AUTOSYNC=1
ENGRAM_CLOUD_TOKEN=<token>
ENGRAM_CLOUD_SERVER=<url>
```

**CLI commands** (for when server is configured):
```
engram cloud config --server <url>      # configure cloud endpoint
engram cloud enroll <project>           # enroll project for cloud sync
engram cloud upgrade doctor --project <name>   # readiness diagnosis
engram cloud upgrade repair --project <name>   # repair planner/apply
engram cloud upgrade bootstrap --project <name> # resumable enroll/push/verify
engram cloud upgrade status --project <name>   # show stage/class/reason
engram projects list|consolidate|prune       # project hygiene
```

**Status reason codes**: `blocked_unenrolled`, `auth_required`, `cloud_config_error`, `policy_forbidden`, `paused`, `transport_failed`

**Current status**: Cloud NOT configured. Pending: Docker + Postgres server setup.

### Memory Protocol

Detailed protocol stored in Engram — retrieve via `mem_context` on session start. Key rules:

**When to Save**: Call `mem_save` immediately after bug fix, architecture decision, non-obvious discovery, config change, pattern established, or user preference learned.

**When to Search**: When user asks to recall ("remember", "recall", "what did we do") or proactively when starting work on something potentially done before.

**Session Close Protocol**: Before ending a session, call `mem_session_summary`. After compaction, call `mem_session_summary` immediately then `mem_context` to recover.

**Passive Capture**: Include `## Key Learnings:` section in responses — Engram auto-extracts numbered items.

**Project Hygiene**: All project names normalized (lowercase, trim, collapse). Use `mem_merge_projects` to consolidate variants. Run `engram projects list` periodically.

### PDF Documentation Pipeline

When encountering PDF documentation during research, chain the PDF parser tools with Engram memory:

1. `pdf_parser_analyze_pdf_to_markdown` — convert PDF to searchable markdown
2. `pdf_parser_extract_pdf_metadata` — extract metadata for indexing context
3. `pdf_parser_extract_figures` — extract embedded figures as base64 for vision LLMs
4. Save key learnings as observations via `mem_save` or `mem_capture_passive`

Query via `mem_search` when needed.

## Save Notable Decisions

Save bugfixes, architecture decisions, and config changes as memory immediately after completing them.