# DevSecOps Workflow Skill

**Focus**: Secure code pipelines, Git branch management, and CI/CD pre-validation.

## Rules
1. **Branch Bunkering**:
   - **Never code on `main`**. All active development must be done on the `dev` branch or a specific feature branch off `dev`.
   - `main` is strictly for stable releases pushed to GitHub/Play Store.
2. **Pre-Push Validation**:
   - Before attempting to push or proposing a pull request to `main`, run `flutter analyze` and `flutter test`.
   - Ensure the `.gitignore` strictly prevents committing secrets (`.env`, `key.properties`, `*.jks`, `*.keystore`).
3. **Secret Management**:
   - NEVER echo or output real API keys or keystore passwords in logs or chats.
   - For Play Store signing, use local environment configurations or GitHub Action Secrets.
4. **CI/CD Alignment**:
   - The `.github/workflows/android-ci.yml` is the ultimate source of truth. If local tests pass but CI fails, the AI must diagnose the CI logs to fix the discrepancy.
