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
