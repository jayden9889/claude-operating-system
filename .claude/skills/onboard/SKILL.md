---
name: onboard
description: First-run setup for the Claude Operating System. Scans the user's existing workspace, then builds their full system - three-tier memory (L1 global identity, L2 per-project, L3a vault), their keys, and their Hermes phone agent - as a clean cabinet for NEW work going forward. It never moves, renames, or reorganises anything that already exists, so it cannot break what Claude has already built. Resumable. Use when the user says "/onboard", "set me up", "get me started", "build my operating system", "install this OS", or when this repo is freshly dropped into a workspace.
allowed-tools: Bash, Read, Write, Edit
---

# onboard - set up the operating system as a clean cabinet for new work

You are installing this operating system into a workspace that **already has the user's work in it**. By the end they have persistent memory across sessions, their keys safely stored, and a phone agent (Hermes) - all wired to the same brain, all seeded with THEIR identity. The whole point of this skill: **add a clean structure for everything going forward, and do not touch a single thing that already exists.** You break nothing because you change nothing that's already there - you only add.

Read [ARCHITECTURE.md](../../ARCHITECTURE.md) once so you can explain *why* as you go. This is a conversation, not a form. Move in steps.

## The prime directives (hold these the entire way)

1. **Never reorganise. Add only.** Do NOT move, rename, restructure, or "tidy" any file or folder that already exists. Moving or renaming things breaks Claude's memory of where they are and breaks the path-keyed memory pool. The clean cabinet is for NEW work going forward; the existing work stays exactly where it is, named exactly what it's named. You may *point at* existing projects so Claude knows they're there, never relocate them.
2. **Never overwrite their files.** They may already have a `CLAUDE.md`, `.gitignore`, `README`, `.env`, or a half-built memory setup. Read what exists. Add beside it, or merge only with explicit consent and a backup. NEVER clobber.
3. **Lose no memory, ever.** The auto-memory pool is keyed to the workspace's absolute path (Step 1). Resolve that path with the resolver, never by hand. If a past move already de-linked memory, migrate it back rather than abandon it.
4. **This OS repo stays its own folder.** Do not copy this repo's root files (`CLAUDE.md`, `README.md`, `.gitignore`, `.env.example`) into their workspace root - that would overwrite theirs. The repo sits as its own directory; the user's NEW structure is written into THEIR workspace and `~/.claude/`, using the templates in `templates/`.
5. **Never echo or commit a secret.** Keys go to disk at permission 600. Never print one back, never commit one.
6. **Resumable.** Re-running `/onboard` re-scans and only fills gaps. Never redo done work.

---

## Step 0 - Orient

```bash
uname -s          # Darwin = macOS (Hermes works). Else note Hermes is unavailable here.
pwd               # where this repo was dropped
```
Read this repo's `README.md` and `ARCHITECTURE.md`. Tell the user in two lines what you'll do: "I'll set up your memory system, your keys, and your phone agent as a clean home for new work. I won't move or rename anything you already have." They can stop anytime.

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
- `FOUND=0` - brand-new workspace (fine, you'll create it) OR it was renamed/moved earlier and an older pool exists under a different slug. The script lists the other existing dirs. If one clearly belongs to this work, run **Move recovery** before anything else.

### Move recovery (only when memory already de-linked from a past move)
If a previous pool exists under an old slug and the current one is empty, with consent:
```bash
mkdir -p "$NEW_POOL_DIR"
cp -n "$OLD_POOL_DIR"/* "$NEW_POOL_DIR"/ 2>/dev/null || true
cp -rn "$OLD_POOL_DIR"/*/ "$NEW_POOL_DIR"/ 2>/dev/null || true
```
Copy, never move. Leave the old dir as a backup. Confirm `MEMORY.md` now exists at the new path.

## Step 2 - Scan what already exists (look, don't touch)

Build a picture before asking anything:
```bash
ls -la ~/.claude/CLAUDE.md 2>/dev/null              # L1 identity present?
ls -la "$MEMORY_MD" 2>/dev/null                     # pool already set up?
ls -la "<target>/memory/vault" 2>/dev/null          # vault present?
ls -la "<target>"/.gitignore "<target>"/CLAUDE.md "<target>"/.env 2>/dev/null  # files to NOT clobber
```
Map the target workspace: top-level folders, which look like real projects (code, a git repo, a clear purpose), whether any already has a `CLAUDE.md`. Don't deep-read content - just map the shape so you know what to point at.

Summarise back: "Here's what you have, here's what's missing, here's what I'll add (and where). I won't move or rename anything." The output of this step is a list of things to ADD, never a list of things to reorganise.

## Step 3 - L1: who they are (global identity)

Goal: end with a correct global `~/.claude/CLAUDE.md`, built from what they ALREADY wrote where possible, asking only for what's missing.

**Case A - global already exists.** Read it, show it, ask to keep/extend. Never overwrite without consent. Go to gap-fill.

**Case B - identity is sitting in a local `CLAUDE.md` (very common).** Often a single local `CLAUDE.md` mixes *identity* (who they are, tone, hard rules, business) with *project* content. Identity belongs in global L1 so every project gets it. When there's no global file:
1. **Read it and copy the identity parts up.** Pull the identity content into `templates/global-CLAUDE.md.template` and write `~/.claude/CLAUDE.md`.
2. **Leave their original local file exactly as it is.** Do not rewrite or trim it - that's reorganising. Just tell them: "I copied your identity up to the global file so it loads everywhere. Your existing file is untouched; you can slim it down yourself later if you want." Additive, not destructive.

**Case C - nothing exists.** Interview from scratch.

**Then fill only the gaps.** Whatever you found in A or copied in B, do NOT re-ask. Compare against what L1 needs - name, what they do, business, goals, tone, English (British/American), hard rules, tools - ask only the missing ones, 4-6 questions max. Read the finished file back for approval. Highest-leverage file in the system.

## Step 4 - L2: a clean home for NEW work (never reorganise the old)

This is the "clean cabinet". It is for work going forward. **You do not restructure existing projects.**

- **Brand-new projects** the user starts from here: scaffold the clean pattern (this is what `/new-project` does) - a `CLAUDE.md` + a `memory/` folder with the six stubs (`project-brief`, `decisions`, `current-strategy`, `next-actions`, `session-summaries`, `bugs-and-risks`).
- **Existing projects:** do NOT move, rename, or restructure them. Two safe, additive options only, and only if the user wants them:
  - **Register** them in the memory index (Step 5) so Claude knows they exist and where - a pointer, nothing moved.
  - **Optionally drop a `CLAUDE.md` beside** an existing project (in its own folder, alongside its files) so Claude works better with it going forward. This adds a label next to the work; it moves nothing. If that project already has a `CLAUDE.md`, leave it - or merge missing sections only with consent and a backup.

There is no "tidy the workspace" step. Loose files, old folders, weird names - all stay exactly as they are.

## Step 5 - The always-loaded index + RESUME

Create `POOL_DIR` if absent and write `MEMORY.md` from `templates/MEMORY.md.template`, including the RESUME block. Run it on the **segregation rule** (ARCHITECTURE §2): one fact per file, subfolders by project/topic (`<project>/`, `references/`, `user/`, `feedback/`), one always-loaded `MEMORY.md` index with one line per memory. Add one index line per project - new ones you scaffolded AND existing ones you're pointing at - so the index is the single map to everything, new and old.

## Step 6 - Tools and keys (.env in THEIR workspace, never echoed)

From the tools they named, work out which need keys. For each: tell them where to get it, have them paste it, write it straight into `<target>/.env`. **Confirm `.env` is gitignored first; if they already have a `.env`, append to it, never overwrite.** Then `chmod 600` and confirm `-rw-------`. Start from `.env.example` as the shape. Never print a key back.

## Step 7 - L3a: stand up the vault (the move-proof memory)

If `<target>/memory/vault/` isn't initialised, create it: folders `sessions/ decisions/ lessons/ outcomes/ themes/ knowledge/`, seed `_RESUME.md` from `_RESUME.md.example`. Lives *inside* the workspace, so it survives renames and is the copy Hermes reads. L3b brains (NotebookLM) are an optional later step - don't build them now.

## Step 8 - Hermes: set up their phone agent (default yes on macOS)

The user should leave with a working phone agent, not a "maybe later". If `uname -s` is Darwin, say "Next I'll set up Hermes so you can message this same system from your phone, reading the same memory" and hand off to the `hermes-setup` skill, passing the target workspace path so both surfaces share one brain. Skip only if they decline or aren't on macOS (note they can run `/hermes-setup` later). Mirror this OS's `wrap-up` (and `morning-brief`, if they want it) into `~/.hermes/skills/` so the phone can wrap and brief too. This is the "connect everything" step - don't quietly skip it.

## Step 9 - Teach the one habit, then finish

Tell them plainly: **"From now on, end every working session with `/wrap-up`. That's the habit that saves the session into memory so the next one continues where we stopped. Without it, the memory stays empty."** Offer the morning brief (`/morning-brief`) as the read-side of the same loop.

Offer to commit the new structure (ask first, never auto-commit; commit + push together once approved). Then report in a few lines: what got ADDED (L1 path, new projects scaffolded, existing projects registered, vault, keys stored count - not the keys, Hermes yes/no), what was skipped and why, and the `/wrap-up` habit. Confirm explicitly that nothing existing was moved or renamed.

---

## Resume behaviour
Re-running `/onboard`: re-run Step 1 (paths) and Step 2 (scan), show what's done, offer only the gaps. Never overwrite an existing `~/.claude/CLAUDE.md`, project `CLAUDE.md`, or `.env` without explicit consent.

## If the user already runs a memory system (reconcile, don't rebuild)
They may be adopting this to align with someone else's setup. Keep their content and their layout. Read their existing files and pool; leave them alone. Only ADD what's missing (e.g. the index, the vault, Hermes). Match conventions, never reorganise their data - their OS stays entirely theirs.

## Constraints
- **Additive only. Never move, rename, or restructure anything that exists.** The clean cabinet is for new work; the past is untouchable.
- Resolve memory paths with `scripts/memory-paths.sh`. Never hand-guess a slug.
- Read-before-write on every existing file. Never overwrite; merge only with consent and a backup.
- Never echo or commit a secret.
- No em dashes. Match the user's chosen English once set.
- Keep this OS repo free of the user's personal data - everything you generate is theirs, written to their machine.
