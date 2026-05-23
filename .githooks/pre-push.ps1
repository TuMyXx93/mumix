# Pre-push hook for Numix + Engram integration
# PowerShell version for Windows compatibility
# Location: .githooks/pre-push.ps1

$ErrorActionPreference = "Stop"

Write-Host "Running pre-push checks for Numix..."

# Run Flutter tests
Write-Host "Running Flutter tests..."
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter tests failed. Fix tests before pushing."
    exit 1
}

# Run Engram audit if available
if (Get-Command engram -ErrorAction SilentlyContinue) {
    Write-Host "Running Engram audit..."
    engram audit --project numix || Write-Host "Warning: Engram audit returned non-zero"
}

Write-Host "Pre-push checks passed."
exit 0
