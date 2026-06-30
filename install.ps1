# Vibe Deploy Kit - one-line installer for Windows (PowerShell).
# Drops the deploy kit into the current project so a student can publish
# to Netlify just by talking to Claude Code. Safe to re-run: it merges
# into existing config instead of overwriting it.
#
# Run from inside your project folder (PowerShell):
#   irm https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$RepoRaw = 'https://raw.githubusercontent.com/lior25659567/vibe-deploy/main'

Write-Host "Adding the Vibe Deploy Kit to this project..."

# --- Prerequisite check (warn, don't crash) --------------------------------
$HaveNode = [bool](Get-Command node -ErrorAction SilentlyContinue)
if (-not $HaveNode) {
  Write-Host "WARNING: Node.js isn't installed. The kit will still install, but"
  Write-Host "         Netlify needs Node.js 18+. Get it from https://nodejs.org"
}

function Fetch($url, $dest) {
  try { Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing }
  catch { Write-Host "ERROR: couldn't download $dest. Check your internet and try again."; exit 1 }
}

# --- The skill + student guide (our files, safe to overwrite) --------------
New-Item -ItemType Directory -Force -Path ".claude/skills/netlify-deploy" | Out-Null
Fetch "$RepoRaw/.claude/skills/netlify-deploy/SKILL.md" ".claude/skills/netlify-deploy/SKILL.md"
Fetch "$RepoRaw/GET-ONLINE.md" "GET-ONLINE.md"
Write-Host "  - installed the netlify-deploy skill + student guide"

# --- .gitignore: create if missing, else top up missing lines --------------
$Needed = @('node_modules/','.env','.env.*','dist/','build/','.DS_Store','.netlify/')
if (-not (Test-Path '.gitignore')) {
  Fetch "$RepoRaw/.gitignore" ".gitignore"
  Write-Host "  - added .gitignore"
} else {
  $existing = Get-Content '.gitignore'
  $added = $false
  foreach ($line in $Needed) {
    if ($existing -notcontains $line) { Add-Content '.gitignore' $line; $added = $true }
  }
  if ($added) { Write-Host "  - topped up your .gitignore with missing entries" }
  else        { Write-Host "  - your .gitignore already covers the basics" }
}

# --- .mcp.json: MERGE the netlify server, never clobber other servers ------
Fetch "$RepoRaw/.mcp.json" ".mcp.kit.json"
if (-not (Test-Path '.mcp.json')) {
  Move-Item '.mcp.kit.json' '.mcp.json'
  Write-Host "  - added .mcp.json (Netlify connector)"
} elseif ($HaveNode) {
  $merged = $false
  try {
    node -e 'const fs=require("fs");const kit=JSON.parse(fs.readFileSync(".mcp.kit.json","utf8"));let cur={};try{cur=JSON.parse(fs.readFileSync(".mcp.json","utf8"));}catch(e){}cur.mcpServers=cur.mcpServers||{};for(const k in kit.mcpServers)cur.mcpServers[k]=kit.mcpServers[k];fs.writeFileSync(".mcp.json",JSON.stringify(cur,null,2)+"\n");'
    if ($LASTEXITCODE -eq 0) { $merged = $true }
  } catch { $merged = $false }
  if ($merged) {
    Remove-Item '.mcp.kit.json'
    Write-Host "  - merged the Netlify connector into your existing .mcp.json"
  } else {
    Copy-Item '.mcp.json' '.mcp.json.bak'; Move-Item -Force '.mcp.kit.json' '.mcp.json'
    Write-Host "  - your .mcp.json looked unusual - backed it up to .mcp.json.bak and replaced it"
  }
} else {
  Copy-Item '.mcp.json' '.mcp.json.bak'; Move-Item -Force '.mcp.kit.json' '.mcp.json'
  Write-Host "  - replaced .mcp.json (backup saved as .mcp.json.bak; install Node to merge instead)"
}

# --- CLAUDE.md: don't clobber the student's own instructions ---------------
Fetch "$RepoRaw/CLAUDE.md" ".CLAUDE.kit.md"
if (-not (Test-Path 'CLAUDE.md')) {
  Move-Item '.CLAUDE.kit.md' 'CLAUDE.md'
  Write-Host "  - added CLAUDE.md"
} elseif (Select-String -Path 'CLAUDE.md' -Pattern 'netlify-deploy' -Quiet) {
  Remove-Item '.CLAUDE.kit.md'
  Write-Host "  - your CLAUDE.md already references the deploy skill - left it alone"
} else {
  Add-Content 'CLAUDE.md' "`r`n`r`n<!-- Vibe Deploy Kit -->"
  Get-Content '.CLAUDE.kit.md' | Add-Content 'CLAUDE.md'
  Remove-Item '.CLAUDE.kit.md'
  Write-Host "  - appended the deploy instructions to your existing CLAUDE.md"
}

# --- Warm the Netlify connector so the first /mcp connects instantly -------
if ($HaveNode) {
  Write-Host "  - warming up the Netlify connector (one-time, ~30s)..."
  try {
    $p = Start-Process -FilePath "npx" -ArgumentList "-y","@netlify/mcp" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 30
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  } catch {}
}

Write-Host ""
Write-Host "Done! The deploy kit is installed."
Write-Host ""
Write-Host "Next, do this ONE time:"
Write-Host "  1. Quit Claude Code and open it again."
Write-Host "  2. Type  /mcp  and sign in to Netlify (and GitHub if asked)."
Write-Host ""
Write-Host 'After that, just tell Claude:  "put my project online"'
Write-Host "(See GET-ONLINE.md for the friendly guide.)"
