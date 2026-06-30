# Vibe Deploy Kit - Netlify connection repair for Windows (PowerShell).
# Run this if Claude's Netlify connection shows "Failed" or you see
# "MCP error -32000: Connection closed".
#
#   irm https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/fix-netlify.ps1 | iex

$ErrorActionPreference = 'Continue'

Write-Host "Repairing the Netlify connection..."

if (-not (Get-Command node -ErrorAction SilentlyContinue) -or -not (Get-Command npx -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: Node.js isn't installed, so the Netlify server can't run."
  Write-Host "       Install Node.js 18+ from https://nodejs.org, then run this again."
  exit 1
}

# 1. Remove the corrupted npx cache (the usual culprit).
Write-Host "  - clearing the download cache"
$npxCache = Join-Path $env:USERPROFILE ".npm\_npx"
if (Test-Path $npxCache) { Remove-Item -Recurse -Force $npxCache -ErrorAction SilentlyContinue }
npm cache verify *> $null

# 2. Re-download the Netlify server cleanly.
Write-Host "  - re-downloading the Netlify server (please wait ~30s)"
try {
  $p = Start-Process -FilePath "npx" -ArgumentList "-y","@netlify/mcp" -PassThru -WindowStyle Hidden
  Start-Sleep -Seconds 30
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
} catch {}

Write-Host ""
Write-Host "Done. Now quit Claude Code, open it again, type  /mcp  and sign in."
Write-Host "If it still fails, tell Claude exactly what you see and it'll help."
