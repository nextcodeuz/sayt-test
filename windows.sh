#!/usr/bin/env bash
set -euo pipefail

log() { printf '[k6-windows] %s\n' "$*"; }
die() { printf '[k6-windows][error] %s\n' "$*" >&2; exit 1; }

is_windows() {
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT) return 0 ;;
    *) return 1 ;;
  esac
}

is_windows || log "Windows-specific script detected; continuing via Windows tooling."

if command -v winget >/dev/null 2>&1; then
  log "Using winget..."
  winget install k6 --source winget --accept-source-agreements --accept-package-agreements
elif command -v choco >/dev/null 2>&1; then
  log "Using Chocolatey..."
  choco install k6 -y
else
  log "winget/choco not found; using portable ZIP fallback via PowerShell."

  ps1_file="$(mktemp --suffix=.ps1)"
  cat >"$ps1_file" <<'PS1'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/grafana/k6/releases/latest' -Headers @{ 'User-Agent' = 'k6-install-script' }
$asset = $release.assets | Where-Object { $_.name -match 'windows-amd64\.zip$' } | Select-Object -First 1
if (-not $asset) { throw "Could not locate a Windows amd64 ZIP asset in the latest k6 release." }

$installRoot = Join-Path $env:LOCALAPPDATA 'k6'
$binDir = Join-Path $installRoot 'bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null

$tempZip = Join-Path $env:TEMP 'k6-windows.zip'
$tempExtract = Join-Path $env:TEMP 'k6-windows-extract'
Remove-Item -Recurse -Force $tempExtract -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $tempExtract | Out-Null

Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip
Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

$exe = Get-ChildItem -Path $tempExtract -Recurse -Filter 'k6.exe' | Select-Object -First 1
if (-not $exe) { throw "k6.exe was not found after extracting the archive." }

Copy-Item -Force $exe.FullName (Join-Path $binDir 'k6.exe')

$path = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($path -notlike "*$binDir*") {
  [Environment]::SetEnvironmentVariable('Path', ($path + ';' + $binDir), 'User')
}

Write-Host "Installed to $binDir\k6.exe"
Write-Host "Open a new terminal, then run: k6 version"
PS1
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$ps1_file")"
  rm -f "$ps1_file"
fi

log "Verifying installation..."
if command -v k6 >/dev/null 2>&1; then
  k6 version
  log "Done."
else
  log "Installation completed, but k6 is not yet on PATH in this shell. Open a new terminal and run: k6 version"
fi
