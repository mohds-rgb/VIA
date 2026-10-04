$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$evidenceDir = Join-Path $repo 'evidence'
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$outFile = Join-Path $evidenceDir "windows-verification-$stamp.txt"

function Write-Log([string]$Value) {
  Add-Content -Path $outFile -Value $Value -Encoding utf8
  Write-Host $Value
}

function Run-Step([string]$Name, [string]$Command, [string]$WorkingDirectory) {
  Write-Log "`n===== $Name ====="
  Write-Log "COMMAND: $Command"
  Push-Location $WorkingDirectory
  try {
    $output = cmd.exe /d /c "$Command 2>&1" | Out-String
    Write-Log $output.TrimEnd()
    $code = $LASTEXITCODE
    Write-Log "EXIT_CODE: $code"
  } catch {
    Write-Log ("EXCEPTION: " + $_.Exception.Message)
    Write-Log 'EXIT_CODE: 1'
  } finally {
    Pop-Location
  }
}

Write-Log 'VIA local portfolio verification evidence'
Write-Log "Timestamp: $(Get-Date -Format o)"
Write-Log 'Project: VIA'
Write-Log 'Purpose: source-level portfolio verification; no APK/release step is required.'

Run-Step 'Demo data validation' 'python scripts/validate-demo-data.py' $repo
Run-Step 'Repository validation' 'python scripts/validate-repository.py' $repo
Run-Step 'Flutter version' 'flutter --version' $repo
Run-Step 'Dart version' 'dart --version' $repo
Run-Step 'Node version' 'node --version' $repo
Run-Step 'npm version' 'npm --version' $repo
Run-Step 'Firebase CLI version' 'firebase --version' $repo
Run-Step 'Git version' 'git --version' $repo
Run-Step 'Flutter doctor' 'flutter doctor -v' $repo
Run-Step 'Flutter dependencies' 'flutter pub get' (Join-Path $repo 'apps/mobile')
Run-Step 'Flutter analyze' 'flutter analyze --no-pub' (Join-Path $repo 'apps/mobile')
Run-Step 'Flutter tests' 'flutter test --no-pub' (Join-Path $repo 'apps/mobile')
Run-Step 'Backend npm install' 'npm.cmd install --no-audit --no-fund' (Join-Path $repo 'functions')
Run-Step 'Backend lint' 'npm.cmd run lint' (Join-Path $repo 'functions')
Run-Step 'Backend typecheck' 'npm.cmd run typecheck' (Join-Path $repo 'functions')
Run-Step 'Backend tests' 'npm.cmd test' (Join-Path $repo 'functions')

Write-Log "`n===== Dependency lockfiles ====="
Write-Log ("apps/mobile/pubspec.lock: " + $(if (Test-Path (Join-Path $repo 'apps/mobile/pubspec.lock')) { 'PRESENT' } else { 'MISSING' }))
Write-Log ("functions/package-lock.json: " + $(if (Test-Path (Join-Path $repo 'functions/package-lock.json')) { 'PRESENT' } else { 'MISSING' }))
Write-Log "`n===== Interpretation ====="
Write-Log 'The raw output may contain machine/device identifiers and should stay local.'
Write-Log 'Do not add passwords, access tokens, private keys, service-account JSON, signing keys, or customer data.'
Write-Host "Evidence written to: $outFile"
