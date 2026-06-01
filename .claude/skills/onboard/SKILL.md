---
name: onboard
description: First-run setup for the Claude Operating System. Scans the user's existing workspace, finds what's missing, interviews them for the gaps, and builds their full three-tier memory system (L1 global identity, L2 per-project, L3a vault) plus optionally their Hermes phone agent. Non-destructive - adds structure alongside existing files, never moves their work without asking. Resumable. Use when the user says "/onboard", "set me up", "get me started", "build my operating system", or when this repo is freshly dropped into a workspace and no ~/.claude/CLAUDE.md exists yet.
allowed-tools: Bash, Read, Write, Edit
---

# onboard - build the user's operating system

You are setting up a new person on the Claude Operating System. By the end they have what a power user has: persistent memory across sessions, a clean project structure, their keys safely stored, and optionally a phone agent - all seeded with THEIR identity and THEIR work.

Read [ARCHITECTURE.md](../../ARCHITECTURE.md) once if you haven't, so you can explain *why* as you go. This is a conversation, not a form. Ask only for what you can't work out by looking. Move in steps; confirm before anything destructive.

## Golden rules (hold these the whole way through)

- **Non-destructive.** ADD structure beside the user's files. Never move, rename, or delete their work without asking and explaining why first.
- **Never echo a secret.** Keys and tokens go straight to disk at permission 600. Never print one back to chat, never commit one.
- **Resumable.** Re-running `/onboard` must not clobber work already done. Check what exists before writing.
- **One thing at a time.** Don't dump ten questions. Walk the steps.
- **This repo stays clean.** Everything you generate is the USER's data, written to THEIR machine (`~/.claude/`, their workspace, `~/.hermes/`). Never write personal data back into this OS repo.

---

## Step 0 - Orient

```bash
uname -s          # Darwin = macOS (Hermes/launchd steps work). Else flag Hermes as unavailable.
pwd               # where are we
```

Read this repo's `README.md` and `ARCHITECTURE.md` so your explanations are grounded. Tell the user in two lines what you're about to do and that they can stop anytime.

## Step 1 - Scan what already exists

Build a picture before asking anything. Check each and note present/absent:

```bash
ls -la ~/.claude/CLAUDE.md 2>/dev/null            # L1 identity present?
ls ~/.claude/projects/ 2>/dev/null                # existing Claude project memory dirs
ls -la memory/vault 2>/dev/null                   # vault scaffold present?
```

Then scan the workspace the user dropped this into (their actual work, likely the parent or a sibling dir they name): list top-level folders, spot things that look like projects (a folder with code, a git repo, a clear purpose). Don't read their file contents deeply - just map the shape.

Summarise back: "Here's what you already have, here's what's missing." Keep it to a short list.

## Step 2 - L1: who they are (the identity file)

If `~/.claude/CLAUDE.md` already exists, read it, show it, ask if they want to keep/extend it. Don't overwrite without consent.

If absent, interview - tight, 4-6 questions, not a wall:
1. Name, and one line on what you do.
2. The business / work you're in (who else is involved if it matters).
3. What you're working towards (goals).
4. How you want me to talk to you (tone, British/American English, any pet hates).
5. Your hard rules - the things I must always or never do.
6. The tools and services you use day to day.

Fill `templates/global-CLAUDE.md.template` with their answers and write it to `~/.claude/CLAUDE.md`. Read it back for approval before saving. This is the highest-leverage file in the system - get it right.

## Step 3 - L2: their projects

For each real project you found in Step 1, offer to scaffold the clean L2 structure (this is exactly what the `/new-project` skill does - reuse its template and loop). For each one they say yes to:

```bash
mkdir -p "<project-path>/memory"
```
Write `<project-path>/CLAUDE.md` from `templates/project-CLAUDE.md.template`, filling what you can infer + a couple of quick questions per project (what is it, what stage, the goal). Create the six `memory/` stub files (`project-brief`, `decisions`, `current-strategy`, `next-actions`, `session-summaries`, `bugs-and-risks`).

**Leave their existing files exactly where they are.** You're adding a `CLAUDE.md` and a `memory/` folder beside their work, nothing else.

## Step 4 - The always-loaded memory index + RESUME (segregated but readable)

Find their Claude project memory dir. Claude Code derives it from the workspace path (the absolute path with `/` and other separators replaced by `-`), under `~/.claude/projects/<that-slug>/memory/`. Create that `memory/` dir if absent and write `MEMORY.md` from `templates/MEMORY.md.template`, including the RESUME block.

Set the pool up on the **segregation rule** (see ARCHITECTURE.md §2) so it stays readable as it grows, and so it matches anyone else running the same OS:
- **One fact per file**, not big catch-all files.
- **Subfolders by project/topic** inside the pool (`<project>/`, `references/`, `user/`, `feedback/`...). Create a subfolder per project scaffolded in Step 3.
- **`MEMORY.md` is the only always-loaded file** - one line per memory (title + hook + relative link into a subfolder). Add one index line per project under a `## Projects` heading.

This file auto-loads every session - it's how the next session "just knows" where things are.

## Step 5 - Tools and keys (.env)

From the tools they named in Step 2.6, work out which need API keys. For each:
- Tell them where to get it (e.g. Anthropic key at console.anthropic.com).
- Have them paste it, and write it straight into `.env` in their workspace. **Do not echo it back.**
- `chmod 600 .env` and confirm with `ls -la .env` (must be `-rw-------`).

Start from `.env.example` as the shape. Add lines for whatever tools they actually use. Confirm `.env` is gitignored before writing a single key.

## Step 6 - L3a: stand up the vault

If `memory/vault/` isn't initialised in their workspace, create it: the folders `sessions/ decisions/ lessons/ outcomes/ themes/ knowledge/`, and seed `_RESUME.md` from `_RESUME.md.example`. This is where `/wrap-up` writes. If they use Obsidian, tell them they can open this folder as a vault for the graph view. For L3b brains (NotebookLM), point them at it as an optional later step - don't build brains during onboarding.

## Step 7 - (Optional, macOS) Hermes, the phone agent

Ask if they want to message their AI from their phone. If yes and they're on macOS, hand off to the `hermes-setup` skill. If no or not on macOS, skip cleanly and note they can run `/hermes-setup` later.

## Step 8 - Teach the one habit, then finish

Tell them plainly: **"From now on, end every working session with `/wrap-up`. That's the habit that saves the session into memory so the next one continues where we stopped. Without it, the memory stays empty."** This is the single most important thing for them to remember.

Offer to commit the new structure (ask first - never auto-commit). Then report, in a few lines: what got built (L1 path, projects scaffolded, vault, keys stored count - not the keys), what was skipped and why, and the `/wrap-up` habit.

---

## Resume behaviour

If `/onboard` is run again: re-scan (Step 1), show what's already done, and only offer the missing pieces. Never overwrite an existing `~/.claude/CLAUDE.md`, project `CLAUDE.md`, or `.env` without explicit consent.

## If the user already has a memory system (reconcile, don't rebuild)

Common case: the user already runs an operating system like this (their own L1, projects, and memory pool), and is adopting this repo to align with someone else's setup. Do NOT tear theirs down. Instead:
- **Keep their content. Align the structure.** Read their existing `~/.claude/CLAUDE.md`, project `CLAUDE.md` files, and memory pool. Leave the *content* alone.
- **Apply the segregation rule (Step 4) to whatever's already there** only where it's missing - e.g. if their pool is one big file, offer to split it into one-fact-per-file subfolders with a single `MEMORY.md` index. Show the plan and get consent before moving anything.
- **Match conventions, not data.** The goal is that their system is *shaped* like the sender's (same tiers, same segregation, same `/wrap-up` ritual) so the two are mutually readable - never that their identity or projects mirror the sender's. Their OS stays entirely theirs.

## Constraints

- Non-destructive, always. Ask before moving anything.
- Never echo or commit a secret.
- No em dashes. Match the user's chosen English (British/American) once set.
- Keep this OS repo free of the user's personal data.