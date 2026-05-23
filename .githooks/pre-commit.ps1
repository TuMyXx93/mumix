# Pre-commit hook for Numix + Engram integration
# PowerShell version for Windows compatibility
# Location: .githooks/pre-commit.ps1

$ErrorActionPreference = "Stop"

Write-Host "Running pre-commit checks for Numix..."

# Run Flutter analyze
Write-Host "Running Flutter static analysis..."
flutter analyze --fatal-infos --fatal-warnings
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter analyze failed. Fix errors before committing."
    exit 1
}

# Check Engram status if available
if (Get-Command engram -ErrorAction SilentlyContinue) {
    Write-Host "Checking Engram memory health..."
    engram doctor --project numix || Write-Host "Warning: Engram health check returned non-zero"
}

Write-Host "Pre-commit checks passed."
exit 0
