# Version Bump Command

**Alias**: `/version-bump <patch|minor|major>`

**Action**:
1. Validate working tree and branch safety.
2. Update version in `pubspec.yaml` according to argument.
3. Update changelog/release notes if available.
4. Create a commit with conventional message.
5. Create a git tag for the new version.

Notes:
- Do not run on dirty state unless user explicitly confirms.
- Use semantic versioning and preserve build metadata format.
