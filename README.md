# Vibe Deploy Kit (Instructor README)

A drop-in "deploy kit" that lets absolute-beginner students put their projects online by **only talking to Claude Code in plain language** — no terminal commands, no Netlify dashboard, no Git knowledge. Students copy a handful of files into their project root, sign in once, and from then on say things like "put my project online" or "update my live site." Claude does all the Git and Netlify work itself via its tools and the Netlify connector. The student-facing explainer is `GET-ONLINE.md`.

## Bilingual: English & Hebrew 🇬🇧🇮🇱
The kit works in **both English and Hebrew**. Claude triggers the same deploy flow either way and **replies in whatever language the student wrote in** — the live link and any error explanations come back in that language too. The underlying Git/Netlify commands are identical; only the conversation language changes. The one-time install command stays in English (it's a system command, not something to translate).

Everyday phrases students can use:

| English | עברית |
|---|---|
| "put my project online" | "תעלה לי את הפרויקט לאינטרנט" |
| "update my live site" | "תעדכן את האתר שלי" |
| "publish my site" | "תפרסם את האתר" |
| "give me a link to share" | "אני רוצה לינק לשתף" |
| "can people see this?" | "אפשר שאנשים יראו את זה?" |

## What's in the kit
- `.mcp.json` — wires the Netlify connector (project scope).
- `CLAUDE.md` — short, always-loaded instructions pointing Claude at the deploy skill.
- `.claude/skills/netlify-deploy/SKILL.md` — the skill that does Git + Netlify setup and everyday deploys.
- `.gitignore` — sensible defaults so students don't leak secrets or commit junk.
- `GET-ONLINE.md` — the warm, jargon-free student guide.

## Adding it to a course starter repo
Commit `.mcp.json`, `CLAUDE.md`, `.gitignore`, `GET-ONLINE.md`, and the entire `.claude/` folder into your course starter template. Because they live in the repo, **every student gets the kit automatically when they clone or fork** the starter — no per-student setup beyond signing in.

## Two ways for students to get the kit into THEIR project

### Option A — "Use this template" (zero commands, recommended for new projects)
In this repo's GitHub **Settings → General**, tick **"Template repository."** Students then click **"Use this template" → "Create a new repository"** and get a fresh project with the entire kit already inside — nothing to copy, no commands. Best when a student is starting a brand-new project.

### Option B — One-line installer (for projects that already exist)
For students who already started a project, they run this **once** from inside their project folder:

```
curl -fsSL https://raw.githubusercontent.com/lior25659567/vibe-deploy/main/install.sh | bash
```

This `install.sh` fetches `.claude/`, `.mcp.json`, `CLAUDE.md`, `GET-ONLINE.md` (and `.gitignore` if they don't have one) straight into the project. It won't overwrite an existing `.gitignore`.

> Note: this one command is the *only* terminal line in the whole experience, and it's part of one-time setup (just like `/mcp`). Everyday use stays 100% conversational.
>
> The installer is **safe to re-run** — it merges into an existing `.mcp.json`/`CLAUDE.md`/`.gitignore` instead of overwriting them, and warns (rather than crashing) if Node.js or curl is missing.

**Windows note:** the installer is a bash script, so on native Windows students should run it in **Git Bash** or a **GitHub Codespace** (recommended for the course — `gh` and `curl` are pre-installed there). On macOS/Linux/Codespaces it just works.

## How deployment is wired
- The **Netlify connector** is configured via `.mcp.json` at **project scope**, so it travels with the repo. Each student authenticates **once** by typing `/mcp` and signing in to Netlify in the browser. After that, Claude deploys conversationally.
- **Restart requirement:** after a student first copies these files into a project, they must **quit and reopen Claude Code** so it picks up the new `.mcp.json` and `.claude/` files. (Flag this clearly — it's the most common "why isn't it working" cause.)

## GitHub side
The skill pushes to GitHub on the student's behalf. In **Codespaces**, `gh` is usually pre-authenticated, so pushes just work. On a **personal laptop**, the student signs in to GitHub once (browser prompt); Claude handles every push from then on.
