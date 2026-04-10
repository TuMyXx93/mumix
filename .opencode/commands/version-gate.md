# Version Gate Command

**Alias**: `/version-gate`

**Action**:
When invoked, run a pre-task repository safety gate and report one of:
- `BLOCKERS` (stop work)
- `WARNINGS` (require user confirmation)
- `CLEAN` (proceed)

Checks:
1. Verify current branch is not `main` for normal development.
2. Verify git remote has no embedded credentials.
3. Verify no merge conflict markers exist in tracked files.
4. Run `flutter analyze`.
5. Run `flutter test test/features/`.

Output format:
- Gate status
- Blockers list
- Warnings list
- Recommended next action
