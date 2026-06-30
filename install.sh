#!/usr/bin/env bash
# Vibe Deploy Kit — one-line installer.
# Drops the deploy kit into the current project so a student can publish
# to Netlify just by talking to Claude Code. Safe to re-run: it merges
# into existing config instead of overwriting it.
#
# Run from inside your project folder:
#   curl -fsSL https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/install.sh | bash

set -uo pipefail

REPO_RAW="https://raw.githubusercontent.com/lior25659567/vibe-deploy/main"

echo "📦 Adding the Vibe Deploy Kit to this project..."

# --- Prerequisite checks (warn, don't crash) -------------------------------
if ! command -v curl >/dev/null 2>&1; then
  echo "❌ 'curl' isn't available, so I can't download the kit. Tell Claude and it'll help."
  exit 1
fi
HAVE_NODE=1
if ! command -v node >/dev/null 2>&1; then
  HAVE_NODE=0
  echo "⚠️  Node.js isn't installed. The kit will still install, but Netlify needs"
  echo "    Node.js 18 or newer. Install it from https://nodejs.org then re-run this."
fi

# Safe download helper: fail clearly instead of leaving a half-written file.
fetch() { # fetch <url> <dest>
  if ! curl -fsSL "$1" -o "$2"; then
    echo "❌ Couldn't download $(basename "$2"). Check your internet and try again."
    exit 1
  fi
}

# --- The skill (always safe to (over)write — it's our file) ----------------
mkdir -p .claude/skills/netlify-deploy
fetch "$REPO_RAW/.claude/skills/netlify-deploy/SKILL.md" .claude/skills/netlify-deploy/SKILL.md
fetch "$REPO_RAW/GET-ONLINE.md" GET-ONLINE.md
echo "   • installed the netlify-deploy skill + student guide"

# --- .gitignore: create if missing, otherwise top up missing lines ---------
NEEDED_IGNORES=("node_modules/" ".env" ".env.*" "dist/" "build/" ".DS_Store" ".netlify/")
if [ ! -f .gitignore ]; then
  fetch "$REPO_RAW/.gitignore" .gitignore
  echo "   • added .gitignore"
else
  ADDED=0
  for line in "${NEEDED_IGNORES[@]}"; do
    if ! grep -qxF "$line" .gitignore; then
      printf '%s\n' "$line" >> .gitignore
      ADDED=1
    fi
  done
  [ "$ADDED" = "1" ] && echo "   • topped up your .gitignore with missing entries" \
                      || echo "   • your .gitignore already covers the basics"
fi

# --- .mcp.json: MERGE the netlify server, never clobber other servers ------
fetch "$REPO_RAW/.mcp.json" .mcp.kit.json
if [ ! -f .mcp.json ]; then
  mv .mcp.kit.json .mcp.json
  echo "   • added .mcp.json (Netlify connector)"
elif [ "$HAVE_NODE" = "1" ]; then
  if node -e '
    const fs=require("fs");
    const kit=JSON.parse(fs.readFileSync(".mcp.kit.json","utf8"));
    let cur={}; try{cur=JSON.parse(fs.readFileSync(".mcp.json","utf8"));}catch(e){}
    cur.mcpServers=cur.mcpServers||{};
    for(const k in kit.mcpServers) cur.mcpServers[k]=kit.mcpServers[k];
    fs.writeFileSync(".mcp.json", JSON.stringify(cur,null,2)+"\n");
  ' 2>/dev/null; then
    rm -f .mcp.kit.json
    echo "   • merged the Netlify connector into your existing .mcp.json"
  else
    cp .mcp.json .mcp.json.bak; mv .mcp.kit.json .mcp.json
    echo "   • your .mcp.json looked unusual — backed it up to .mcp.json.bak and replaced it"
  fi
else
  cp .mcp.json .mcp.json.bak; mv .mcp.kit.json .mcp.json
  echo "   • replaced .mcp.json (backup saved as .mcp.json.bak; install Node to merge instead)"
fi

# --- CLAUDE.md: don't clobber the student's own instructions ---------------
fetch "$REPO_RAW/CLAUDE.md" .CLAUDE.kit.md
if [ ! -f CLAUDE.md ]; then
  mv .CLAUDE.kit.md CLAUDE.md
  echo "   • added CLAUDE.md"
elif grep -q "netlify-deploy" CLAUDE.md; then
  rm -f .CLAUDE.kit.md
  echo "   • your CLAUDE.md already references the deploy skill — left it alone"
else
  { printf '\n\n<!-- Vibe Deploy Kit -->\n'; cat .CLAUDE.kit.md; } >> CLAUDE.md
  rm -f .CLAUDE.kit.md
  echo "   • appended the deploy instructions to your existing CLAUDE.md"
fi

# --- Warm the Netlify connector so the first /mcp connects instantly -------
if [ "$HAVE_NODE" = "1" ]; then
  echo "   • warming up the Netlify connector (one-time, ~30s)..."
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"warm","version":"1.0"}}}' \
    | { npx -y @netlify/mcp >/dev/null 2>&1 & NPID=$!; sleep 30; kill "$NPID" 2>/dev/null; } || true
fi

echo ""
echo "✅ Done! The deploy kit is installed."
echo ""
echo "Next, do this ONE time:"
echo "  1. Quit Claude Code and open it again."
echo "  2. Type  /mcp  and sign in to Netlify (and GitHub if asked)."
echo ""
echo "After that, just tell Claude:  \"put my project online\"  🎉"
echo "(See GET-ONLINE.md for the friendly guide.)"
