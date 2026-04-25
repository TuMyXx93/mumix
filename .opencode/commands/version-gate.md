# Version Gate Command

Alias: `/version-gate`

Action:
1. Verify branch with `git branch --show-current`
2. If branch is `main`, block non-hotfix code changes
3. Run: `flutter analyze`
4. Run: `flutter test test/features/`
5. Run: `flutter build apk --debug`
6. Return PASS, PASS WITH WARNINGS, or FAIL with reasons