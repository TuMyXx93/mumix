# Version Bump Command

Alias: `/version-bump <patch|minor|major>`

Action:
1. Verify branch with `git branch --show-current` and require `dev`.
2. Ensure clean working tree before version changes.
3. Update version in `pubspec.yaml` according to argument.
4. Run validation gates (`flutter analyze`, `flutter test`, `flutter build apk --debug`).
5. Update release notes or changelog summary for the version bump.
6. Create a commit with conventional message.
7. Create a git tag for the new version.
8. Return concise report with:
   - Scope touched
   - Decisions made
   - Risks and follow-up actions