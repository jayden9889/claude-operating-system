---
name: onboard
description: First-run setup for the Claude Operating System. FIRST scans the user's existing workspace AND their current memory to harvest what they already know about themselves, then builds their full system - three-tier memory (L1 global identity, L2 per-project, L3a vault), their keys, their GitHub sync, their Hermes phone agent, and their morning brief - as a clean cabinet for NEW work going forward. It only ever asks for genuine gaps, and it never moves, renames, or reorganises anything that already exists, so it cannot break what Claude has already built. Resumable. Use when the user says "/onboard", "set me up", "get me started", "build my operating system", "install this OS", or when this repo is freshly dropped into a workspace.
allowed-tools: Bash, Read, Write, Edit
---

# onboard - set up the operating system as a clean cabinet for new work

You are installing this operating system into a workspace that **already has the user's work in it**. By the end they have persistent memory across sessions, their keys stored, their GitHub wired as the sync layer, a phone agent (Hermes), and a daily morning brief - all on one shared brain, seeded with THEIR identity. The whole point: **add a clean structure for everything going forward, harvest what they already have, and never touch what already exists.**

Read [ARCHITECTURE.md](../../ARCHITECTURE.md) once so you can explain *why* as you go. This is a conversation, not a form. Move in steps.

## The prime directives (hold these the entire way)

1. **Harvest before asking.** FIRST read what already exists - the workspace, the memory pool, any identity files - and build a picture of what the user already says about themselves and their work. Only ever ask for genuine gaps. If the answer is already on disk (their name, business, tools, projects, GitHub), do NOT ask it. This applies to every step: identity, projects, tools, GitHub, all of it.
2. **Never reorganise. Add only.** Do NOT move, rename, restructure, or "tidy" any file or folder that already exists. Moving things breaks Claude's memory of where they are and breaks the path-keyed memory pool. The clean cabinet is for NEW work; existing work stays exactly where it is, named exactly what it's named. You may *point at* existing projects, never relocate them.
3. **Never overwrite their files.** They may already have a `CLAUDE.md`, `.gitignore`, `README`, `.env`, or a half-built memory setup. Read what exists. Add beside it, or merge only with explicit consent and a backup. NEVER clobber.
4. **Lose no memory, ever.** The auto-memory pool is keyed to the workspace's absolute path (Step 1). Resolve that path with the resolver, never by hand. If a past move de-linked memory, migrate it back.
5. **This OS repo stays its own folder.** Don't copy this repo's root files (`CLAUDE.md`, `README.md`, `.gitignore`, `.env.example`) into their workspace root - that would overwrite theirs. The user's NEW structure is written into THEIR workspace and `~/.claude/`, using `templates/`.
6. **Never echo or commit a secret.** Keys go to disk at permission 600. Never print one back, never commit one.
7. **Resumable.** Re-running `/onboard` re-scans and only fills gaps. Never redo done work.

---

## Step 0 - Orient

```bash
uname -s          # Darwin = macOS (Hermes works). Else note Hermes is unavailable here.
pwd               # where this repo was dropped
```
Read this repo's `README.md` and `ARCHITECTURE.md`. Tell the user in two lines: "I'll set up your memory, keys, GitHub sync, phone agent, and morning brief as a clean home for new work. I'll use whatever I can already find about you so I only ask what I'm missing, and I won't move or rename anything you already have."

**Establish the two locations out loud:**
- **OS repo dir** = where this repo lives (here).
- **Target workspace** = the folder holding their actual work that the OS should manage. Often the parent of this repo, or a sibling they name. Confirm it in one line before writing anything. Everything you build goes under the target workspace and `~/.claude/`, never back into the OS repo.

## Step 1 - Resolve memory paths the safe way (never hand-guess)

A workspace's auto-memory pool lives at `~/.claude/projects/<slug>/memory/`, where `<slug>` is the absolute path with every non-alphanumeric character turned into a hyphen. Guess it wrong and `MEMORY.md` silently never loads. Resolve it, then verify:

```bash
bash "<os-repo>/scripts/memory-paths.sh" "<target-workspace-abs-path>"
```
Prints `SLUG`, `POOL_DIR`, `MEMORY_MD`, `FOUND`.
- `FOUND=1` - Claude Code already tracks this path. `POOL_DIR` is correct.
- `FOUND=0` - brand-new workspace (fine, you'll create it) OR it was renamed/moved earlier and an older pool exists under a different slug. The script lists the other dirs. If one clearly belongs to this work, run **Move recovery** first.

### Move recovery (only when memory already de-linked from a past move)
With consent, copy (never move):
```bash
mkdir -p "$NEW_POOL_DIR"
cp -n "$OLD_POOL_DIR"/* "$NEW_POOL_DIR"/ 2>/dev/null || true
cp -rn "$OLD_POOL_DIR"/*/ "$NEW_POOL_DIR"/ 2>/dev/null || true
```
Leave the old dir as a backup. Confirm `MEMORY.md` now exists at the new path.

## Step 2 - Scan workspace AND current memory first (harvest, don't ask)

This is the most important step. Before asking the user anything, read what's already on disk and build a profile of what they already know about themselves. Look, never touch.

```bash
# Identity + memory already present?
cat ~/.claude/CLAUDE.md 2>/dev/null                  # global identity, if any
cat "$MEMORY_MD" 2>/dev/null                          # the auto-memory index + RESUME
ls -R "$POOL_DIR" 2>/dev/null                         # pooled facts (user/, feedback/, project subfolders)
ls "<target>/memory/vault" 2>/dev/null                # vault present?
find "<target>" -maxdepth 2 -iname 'CLAUDE.md' 2>/dev/null   # any local CLAUDE.md doing identity duty
ls -la "<target>"/.gitignore "<target>"/.env 2>/dev/null     # files to NOT clobber
git -C "<target>" remote -v 2>/dev/null               # already connected to GitHub?
```
Then map the workspace shape: top-level folders, which look like real projects, which already have a `CLAUDE.md`. Don't deep-read project code - just map it.

**Harvest into a working profile:** from everything above, pull what the user has ALREADY told the system about themselves - name, business, role, tone, rules, tools, projects, GitHub remote. Hold this. Every later step checks this profile first and only asks for what's genuinely missing.

Summarise back: "Here's what I already know about you from your files, here's what's missing, here's what I'll add (and where). I won't move or rename anything." The output is a list of things to ADD plus a short list of gaps to ask, never a list of things to reorganise.

## Step 3 - L1: who they are (global identity) - fill only the gaps

Goal: a correct global `~/.claude/CLAUDE.md`, built from the harvested profile, asking only what's missing.

**Case A - global already exists.** Read it, show it, ask to keep/extend. Never overwrite without consent.

**Case B - identity is sitting in a local `CLAUDE.md`.** Often a local `CLAUDE.md` mixes *identity* (who they are, tone, rules, business) with *project* content. Identity belongs in global L1. When there's no global file: copy the identity parts UP into `templates/global-CLAUDE.md.template` and write `~/.claude/CLAUDE.md`. **Leave their original local file exactly as it is** - do not rewrite or trim it (that's reorganising). Tell them: "I copied your identity up so it loads everywhere; your file is untouched, slim it down yourself later if you want."

**Case C - nothing exists.** Interview from scratch.

**Then fill only the gaps.** Whatever the Step 2 profile already covers, do NOT re-ask. Compare against what L1 needs - name, what they do, business, goals, tone, English (British/American), hard rules, tools - and ask only the missing ones, 4-6 questions max. Read the finished file back for approval.

## Step 4 - L2: a clean home for NEW work (never reorganise the old)

The "clean cabinet", for work going forward. **You do not restructure existing projects.**
- **Brand-new projects:** scaffold the clean pattern (what `/new-project` does) - a `CLAUDE.md` + a `memory/` folder with the six stubs (`project-brief`, `decisions`, `current-strategy`, `next-actions`, `session-summaries`, `bugs-and-risks`).
- **Existing projects:** never move/rename/restructure. Two additive options, only if wanted: **register** them in the index (Step 5), or **drop a `CLAUDE.md` beside** one (in its own folder) so Claude works better with it - this adds a label, moves nothing. If it already has a `CLAUDE.md`, leave it (merge only with consent + backup).

There is no "tidy the workspace" step. Loose files, old folders, odd names - all stay exactly as they are.

## Step 5 - The always-loaded index + RESUME

Create `POOL_DIR` if absent and write `MEMORY.md` from `templates/MEMORY.md.template`, including the RESUME block. Run it on the **segregation rule** (ARCHITECTURE §2): one fact per file, subfolders by project/topic (`<project>/`, `references/`, `user/`, `feedback/`), one always-loaded `MEMORY.md` index with one line per memory. Seed `user/` with the harvested profile facts. Add one index line per project - new ones you scaffolded AND existing ones you're pointing at.

## Step 6 - Tools and keys (.env in THEIR workspace, never echoed)

From the tools in the harvested profile + any they name, work out which need keys, and skip any key already present in their `.env`. For each missing one: tell them where to get it, have them paste it, write it straight into `<target>/.env`. **Confirm `.env` is gitignored first; if they already have a `.env`, append, never overwrite.** Then `chmod 600`, confirm `-rw-------`. Never print a key back.

## Step 7 - L3a: stand up the vault (the move-proof memory)

If `<target>/memory/vault/` isn't initialised, create it: folders `sessions/ decisions/ lessons/ outcomes/ themes/ knowledge/`, seed `_RESUME.md` from `_RESUME.md.example`. Lives *inside* the workspace, survives renames, is the copy Hermes reads, and is an Obsidian-compatible vault (tell them they can open this folder in Obsidian for the graph view). L3b brains (NotebookLM) are an optional later step.

## Step 8 - GitHub: the sync layer (skip if already connected)

Git is what syncs the vault and workspace between the laptop and the phone (Hermes), and across machines. Wire it - but **first check whether it's already connected, and if so, skip this entirely** (harvest rule):
```bash
git -C "<target>" rev-parse --is-inside-work-tree 2>/dev/null   # already a repo?
git -C "<target>" remote -v 2>/dev/null                          # already has a remote?
git -C "<target>" config user.name 2>/dev/null                   # identity set?
```
- **Already a repo with a remote that pushes** - say "GitHub already connected, skipping" and move on. Do not re-ask.
- **A repo but no remote** - help them create a repo on their GitHub (private by default for a personal OS) and add it as the remote. Use the `gh` CLI if present, otherwise walk them through creating it in the browser and `git remote add origin`.
- **Not a repo yet** - `git init`, ensure `.env` and secrets are gitignored BEFORE the first commit, make the first commit, then connect the remote.
Verify with a real `git push`. Tell them this is what lets the phone and laptop share one memory. Never commit `.env` or keys - confirm they're ignored first.

## Step 9 - Hermes: set up their phone agent (default yes on macOS)

The user should leave with a working phone agent. If `uname -s` is Darwin, say "Next I'll set up Hermes so you can message this same system from your phone, reading the same memory" and hand off to the `hermes-setup` skill, passing the target workspace path so both surfaces share one brain over the GitHub repo from Step 8. Skip only if they decline or aren't on macOS (note they can run `/hermes-setup` later). Mirror this OS's `wrap-up` and `morning-brief` into `~/.hermes/skills/` so the phone can wrap and brief too. This is the "connect everything" step - don't quietly skip it.

## Step 10 - Build the morning brief, teach the one habit, finish

**Build their morning brief now** (don't just offer it). Hand off to the `morning-brief` skill to stand up the two-phase daily brief, wired to read their RESUME handoff, next-actions, git log, and calendar. If Hermes was set up, deliver it to their phone on a schedule; otherwise set it up as `/morning-brief` on demand. Tell them it gets sharper as their memory fills - the more `/wrap-up` runs, the better the brief.

Then teach the habit, plainly: **"From now on, end every working session with `/wrap-up`. That's what saves the session into memory so the next one continues where we stopped. Without it, the memory stays empty."**

Offer to commit the new structure (ask first; commit + push together once approved). Report in a few lines: what got ADDED (L1 path, new projects, existing projects registered, vault, keys stored count - not the keys, GitHub remote, Hermes yes/no, morning brief built), what was skipped because it already existed, and the `/wrap-up` habit. Confirm explicitly that nothing existing was moved or renamed.

---

## Resume behaviour
Re-running `/onboard`: re-run Step 1 (paths) and Step 2 (scan + harvest), show what's done, offer only the gaps. Never overwrite an existing `~/.claude/CLAUDE.md`, project `CLAUDE.md`, or `.env` without explicit consent.

## If the user already runs a memory system (reconcile, don't rebuild)
They may be adopting this to align with someone else's setup. Keep their content and layout. Read their existing files and pool; leave them alone. Only ADD what's missing (index, vault, GitHub, Hermes, morning brief). Match conventions, never reorganise their data.

## Constraints
- **Harvest first, ask only gaps.** Never ask for something already on disk.
- **Additive only. Never move, rename, or restructure anything that exists.**
- Resolve memory paths with `scripts/memory-paths.sh`. Never hand-guess a slug.
- Read-before-write on every existing file. Never overwrite; merge only with consent and a backup.
- Never echo or commit a secret. Confirm `.env` is gitignored before any commit.
- No em dashes. Match the user's chosen English once set.
- Keep this OS repo free of the user's personal data - everything you generate is theirs, written to their machine.
