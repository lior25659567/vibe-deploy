---
name: netlify-deploy
description: Put a project online and keep it updated. Use WHENEVER the user wants to publish, deploy, ship, "go live", "make it public", get a shareable link/URL, host their site, update their live site, or mentions Netlify or GitHub hosting — even if the word "deploy" is never said. If they ask "can people see this?" or "how do I send this to someone?", that counts too. ALSO triggers on Hebrew requests, e.g. "תעלה לי את הפרויקט לאינטרנט", "תפרסם את האתר", "תוציא את זה לאוויר", "אני רוצה לינק לשתף", "תעדכן את האתר שלי", "תעלה את האתר", "איך אני מעלה את זה לאינטרנט", "אפשר שאנשים יראו את זה?", or any Hebrew phrasing about putting a project/site online, publishing, hosting, sharing a link, or updating a live site.
---

# Netlify Deploy

## Golden rule
The student NEVER types terminal commands and NEVER touches the Netlify dashboard. You run every Git and Netlify step yourself with your own tools. The only thing a student ever does by hand is a one-time browser sign-in (via `/mcp`). Talk warmly, in plain language, and do the work for them.

## Speak the student's language
**Reply in whatever language the student wrote in.** If they wrote in Hebrew, respond entirely in Hebrew — warm, friendly, and jargon-free — and give the final live link in Hebrew too (e.g. "האתר שלך עלה לאוויר! הנה הלינק: …"). The Git/Netlify commands you run stay the same; only your words to the student change. Match their language for the whole conversation, including error explanations and reassurance.

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

**ALWAYS verify the WHOLE project is actually committed — even on an existing repo.** A common trap: only one file (e.g. `README.md`) got committed and all the real code is still untracked, so the deployed site is empty. Don't assume; check:
- `git status --short` — any `??` (untracked) or `M` (modified) lines mean work isn't saved yet.
- `git ls-tree -r --name-only HEAD | wc -l` — if HEAD has far fewer files than the project folder, the first commit was incomplete.
- Fix by staging and committing everything: `git add -A && git commit -m "Add full project"`, then push.
- Then confirm nothing is unpushed: `git log origin/main..HEAD --oneline` should be empty after the push.

**If `git push` fails** (`error: RPC failed; HTTP 400`, `send-pack: unexpected disconnect`, `the remote end hung up`), it's almost always a large push (big images/assets). Fix it yourself:
1. Raise the buffer and retry: `git config http.postBuffer 524288000 && git push origin main`.
2. If it still fails, the repo has very large binaries (screenshots, videos, datasets). Consider whether they belong online — large preview images can be removed or shrunk. Never silently drop the student's real content; tell them warmly what's oversized and why.

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

## Single-page apps (React Router, Vue Router, etc.) — fix refresh 404s
If the app uses client-side routing, the homepage works but **refreshing any other page (or sharing a deep link) shows "Page not found."** Netlify needs a redirect telling it to serve `index.html` for all routes. Add it yourself:
- Create `public/_redirects` (so it's copied into the build output) containing exactly:
  `/*    /index.html   200`
- Or add to `netlify.toml`:
  `[[redirects]]\n  from = "/*"\n  to = "/index.html"\n  status = 200`
Commit and push. This is the #1 "it worked then broke" issue for React apps.

## Secrets and environment variables (never commit keys)
If the project needs an API key or secret (Anthropic, OpenAI, a database URL, etc.):
- It must live in **Netlify's environment variables** (set via the connector or Site settings → Environment variables), NOT in the code and NOT in a committed file.
- Frontend bundles are public — a key used in browser code is exposed to everyone. Keys belong in a backend/serverless function (e.g. a Netlify Function), read from `process.env`.
- Make sure `.env` is git-ignored. If a key was already committed, help the student remove it from history AND rotate (regenerate) the key — assume the old one is compromised.

## Project isn't at the repo root (monorepo / subfolder)
If the actual app lives in a subfolder (e.g. `app/`, `frontend/`, `web/`), set Netlify's **base directory** to that folder, and the publish directory relative to it (e.g. base `frontend`, build `npm run build`, publish `dist`). Otherwise the build runs in the wrong place and finds no `package.json`.

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
- **Incomplete first commit** — only the README (or a couple of files) is in the repo and the real code is untracked, so the live site is empty. See Step 2's "verify the WHOLE project is committed" check.
- **Push rejected as too big** (`HTTP 400` / `RPC failed`) — large images/assets. See Step 2's `http.postBuffer` fix.
- **AI SDK / secret-using code in a browser app** — if the build logs show `Module "node:path"/"node:fs" has been externalized for browser compatibility` (often from `@anthropic-ai/sdk`, `openai`, database drivers, etc.), the student is calling a server-only SDK directly from frontend code. Two problems: (1) it won't actually work in the browser, and (2) **any API key it uses would be shipped inside the public site bundle — a leaked secret.** Warn the student clearly and kindly, and don't treat the deploy as "done" until they know. The real fix is to move that call to a backend/serverless function (e.g. a Netlify Function) with the key stored as a Netlify environment variable — never in frontend code or committed files. The site may still deploy, but that feature will be broken and the key exposed.

## Tone reminder
These are absolute beginners. Be warm and encouraging, skip the jargon, run every command for them, and celebrate when their site goes live.
