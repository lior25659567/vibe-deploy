#!/usr/bin/env bash
# Vibe Deploy Kit — one-line installer.
# Drops the deploy kit into the current project so a student can publish
# to Netlify just by talking to Claude Code.
#
# Run from inside your project folder:
#   curl -fsSL https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/install.sh | bash

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/lior25659567/vibe-deploy/main"

echo "📦 Adding the Vibe Deploy Kit to this project..."

# Make the skill folder.
mkdir -p .claude/skills/netlify-deploy

# Fetch each kit file from the repo.
curl -fsSL "$REPO_RAW/.mcp.json"                                  -o .mcp.json
curl -fsSL "$REPO_RAW/CLAUDE.md"                                  -o CLAUDE.md
curl -fsSL "$REPO_RAW/GET-ONLINE.md"                              -o GET-ONLINE.md
curl -fsSL "$REPO_RAW/.claude/skills/netlify-deploy/SKILL.md"    -o .claude/skills/netlify-deploy/SKILL.md

# Only add .gitignore if the project doesn't already have one (don't clobber).
if [ ! -f .gitignore ]; then
  curl -fsSL "$REPO_RAW/.gitignore" -o .gitignore
  echo "   • added .gitignore"
else
  echo "   • kept your existing .gitignore (left it alone)"
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
