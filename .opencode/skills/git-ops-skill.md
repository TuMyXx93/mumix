# GitOps Skill

**Focus**: Clean Git history, conventional commits, and atomic versioning.

## Rules
1. **Conventional Commits**: ALL commits must follow the conventional format:
   - `feat(scope): ...` (New feature)
   - `fix(scope): ...` (Bug fix)
   - `refactor(scope): ...` (Code change that neither fixes a bug nor adds a feature)
   - `chore(scope): ...` (Build tasks, dependency updates, maintenance)
   - `test(scope): ...` (Adding or updating tests)
   - `docs(scope): ...` (Documentation only changes)
2. **Atomic Commits**: Commit changes immediately after a logical unit of work is completed and verified (e.g., tests passing). Do not pile up 10 features into a single commit.
3. **Descriptive Messages**: The commit message should briefly explain *what* and *why*, not just a generic "updated files".
4. **Release Safety Gates**: Before pushing or tagging release branches, ensure `flutter analyze` and `flutter test` pass, then verify the latest CI run status on GitHub.
5. **Engram Sync Hygiene**: For release-ready milestones (main branch promotions, version bumps), run `engram sync` and commit generated memory chunks when the team workflow uses shared Engram history. For cloud users, `engram sync --cloud --project <name>` syncs explicit project to Engram Cloud server.
6. **Remote Integrity**: Before first push after repo migration/rename, verify `origin` URL and upstream tracking (`git remote -v`, `git branch -vv`) to prevent publishing to the wrong repository.
7. **Project Name Hygiene**: Use `engram projects list` to audit consolidated project names. Merge variant names (e.g. `numix-calculator` → `numix`) via `mem_merge_projects` tool or `engram projects consolidate` to keep memory cohesive.
