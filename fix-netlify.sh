#!/usr/bin/env bash
# Vibe Deploy Kit — Netlify connection repair.
# Run this if Claude's Netlify connection shows "Failed" or you see an
# "MCP error -32000: Connection closed" message.
#
# It clears the broken npx download cache and re-fetches the Netlify
# server cleanly, which fixes the most common cause of that error.
#
#   curl -fsSL https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/fix-netlify.sh | bash

set -uo pipefail

echo "🔧 Repairing the Netlify connection..."

# Netlify's server needs Node.js. If it's missing, stop with a clear message.
if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "❌ Node.js isn't installed, so the Netlify server can't run."
  echo "   Install Node.js 18+ from https://nodejs.org, then run this again."
  exit 1
fi

# 1. Remove the corrupted npx cache (the usual culprit).
echo "   • clearing the download cache"
rm -rf "${HOME}/.npm/_npx" 2>/dev/null || true
npm cache verify >/dev/null 2>&1 || true

# 2. Re-download the Netlify server cleanly and confirm it boots.
echo "   • re-downloading the Netlify server (please wait ~30s)"
BOOT_OK=$(
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"fix","version":"1.0"}}}' \
  | { npx -y @netlify/mcp 2>/dev/null & NPID=$!; sleep 35; kill "$NPID" 2>/dev/null; } \
  | grep -c "netlify-mcp" || true
)

echo ""
if [ "${BOOT_OK:-0}" != "0" ]; then
  echo "✅ Fixed! The Netlify server is healthy again."
  echo ""
  echo "Now: quit Claude Code, open it again, type  /mcp  and sign in."
else
  echo "⚠️  Still not booting. Tell Claude exactly what you see and it'll help."
  echo "   (Make sure Node.js 18 or newer is installed: run  node -v )"
fi
