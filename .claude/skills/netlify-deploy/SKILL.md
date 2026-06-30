---
name: netlify-deploy
description: Put a project online and keep it updated. Use WHENEVER the user wants to publish, deploy, ship, "go live", "make it public", get a shareable link/URL, host their site, update their live site, or mentions Netlify or GitHub hosting — even if the word "deploy" is never said. If they ask "can people see this?" or "how do I send this to someone?", that counts too.
---

# Netlify Deploy

## Golden rule
The student NEVER types terminal commands and NEVER touches the Netlify dashboard. You run every Git and Netlify step yourself with your own tools. The only thing a student ever does by hand is a one-time browser sign-in (via `/mcp`). Talk warmly, in plain language, and do the work for them.

## Step 1 — Figure out where things stand
Quietly check (don't make the student do this):
- **Is this a Git repo yet?** `git rev-parse --is-inside-work-tree` (or look for a `.git/` folder).
- **Is there a GitHub remote?** `git remote -v` — look for an `origin`.
- **Is Netlify connected?** Check whether the Netlify connector/MCP tools are available, and whether a site is already linked (look for `.netlify/state.json` or ask the connector to list the user's sites).

Tell the student what you found in friendly terms ("Looks like this isn't online yet — I'll set that up for you now.").

## Step 2 — Do the Git setup yourself
If it's not a repo or not on GitHub, handle all of it:
1. `git init` (if needed) and make sure the branch is `main`.
2. Confirm a `.gitignore` exists with at least `node_modules/`, `.env`, `.env.*`, `dist/`, `build/`, `.DS_Store`, `.netlify/`. Create it if missing — this prevents leaking secrets and bloating the repo.
3. Stage and make the first commit: `git add -A && git commit -m "Initial commit"`.
4. Create the GitHub repo and push. Prefer `gh repo create <name> --source=. --public --push`. In Codespaces `gh` is usually already signed in; on a personal laptop the student signs into GitHub once in the browser, then you handle every push after that.

## Step 3 — Connect to Netlify (stay conversational)
**Prefer the Netlify connector / CLI** so it all happens through your tools:
- Use the connector to create a new Netlify site and link it to the GitHub repo, enabling continuous deploys from `main`.
- Set the build command and publish directory using the cheat sheet below.
- When it's live, give the student the URL plainly: "Your site is live at https://…".

**Browser fallback (only if the connector isn't available).** Walk the student through this one-time checklist, warmly, one step at a time:
1. Go to app.netlify.com → "Add new site" → "Import an existing project".
2. Choose GitHub and pick this repo.
3. Set the build command + publish directory (cheat sheet below).
4. Click "Deploy". After this first time, future updates are automatic — they just talk to you.

## Step 4 — Everyday updates ("update my live site")
Once it's set up, publishing a change is:
1. `git add -A && git commit -m "<short description of what changed>"`.
2. `git push`.
3. If continuous deploys are on, Netlify rebuilds automatically — confirm and share the link. If continuous deploys are NOT set up, trigger a deploy through the Netlify connector yourself.

Never make the student run these — you run them and report back.

## Build-settings cheat sheet
| Project type | Build command | Publish directory |
|---|---|---|
| Plain HTML/CSS/JS | *(leave blank)* | the folder containing `index.html` (often the repo root or `public/`) |
| Vite | `npm run build` | `dist` |
| Create React App (CRA) | `npm run build` | `build` |
| Astro | `npm run build` | `dist` |
| Next.js | *(auto-detected by Netlify)* | *(auto)* |

## Netlify connection fails ("MCP error -32000: Connection closed" / "Failed")
This almost always means npx left a **corrupted/half-downloaded cache** of the Netlify server, so it crashes on launch. Fix it yourself — don't make the student debug:
1. Run the repair: `curl -fsSL https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/fix-netlify.sh | bash` (or, if the file is local, `bash fix-netlify.sh`). It clears `~/.npm/_npx`, re-downloads the server cleanly, and confirms it boots.
2. Tell the student to quit and reopen Claude Code, then type `/mcp` and sign in again.
3. If it still fails, check Node is version 18+ (`node -v`) — the Netlify server needs a recent Node.

## Common beginner failures (check these when a deploy looks broken)
- **Wrong publish directory** — the build succeeds but the site is blank or 404s. Match the table above to the project type.
- **Missing lockfile** — no `package-lock.json` committed, so the build can't install dependencies reliably. Make sure it's committed.
- **Pushed to the wrong branch** — Netlify watches `main`; if changes went to another branch, nothing updates. Get them onto `main`.
- **Leaked `.env`** — secrets got committed. Make sure `.env` is in `.gitignore`; if it was already pushed, help them remove it from history and rotate the secret.

## Tone reminder
These are absolute beginners. Be warm and encouraging, skip the jargon, run every command for them, and celebrate when their site goes live.
