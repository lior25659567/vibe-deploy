# Vibe Deploy Kit (Instructor README)

A drop-in "deploy kit" that lets absolute-beginner students put their projects online by **only talking to Claude Code in plain language** — no terminal commands, no Netlify dashboard, no Git knowledge. Students copy a handful of files into their project root, sign in once, and from then on say things like "put my project online" or "update my live site." Claude does all the Git and Netlify work itself via its tools and the Netlify connector. The student-facing explainer is `GET-ONLINE.md`.

## What's in the kit
- `.mcp.json` — wires the Netlify connector (project scope).
- `CLAUDE.md` — short, always-loaded instructions pointing Claude at the deploy skill.
- `.claude/skills/netlify-deploy/SKILL.md` — the skill that does Git + Netlify setup and everyday deploys.
- `.gitignore` — sensible defaults so students don't leak secrets or commit junk.
- `GET-ONLINE.md` — the warm, jargon-free student guide.

## Adding it to a course starter repo
Commit `.mcp.json`, `CLAUDE.md`, `.gitignore`, `GET-ONLINE.md`, and the entire `.claude/` folder into your course starter template. Because they live in the repo, **every student gets the kit automatically when they clone or fork** the starter — no per-student setup beyond signing in.

## How deployment is wired
- The **Netlify connector** is configured via `.mcp.json` at **project scope**, so it travels with the repo. Each student authenticates **once** by typing `/mcp` and signing in to Netlify in the browser. After that, Claude deploys conversationally.
- **Restart requirement:** after a student first copies these files into a project, they must **quit and reopen Claude Code** so it picks up the new `.mcp.json` and `.claude/` files. (Flag this clearly — it's the most common "why isn't it working" cause.)

## GitHub side
The skill pushes to GitHub on the student's behalf. In **Codespaces**, `gh` is usually pre-authenticated, so pushes just work. On a **personal laptop**, the student signs in to GitHub once (browser prompt); Claude handles every push from then on.
