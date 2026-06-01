---
name: onboard
description: First-run setup for the Claude Operating System. Scans the user's existing workspace, figures out the safest way to install around their real work, and builds their full three-tier memory system (L1 global identity, L2 per-project, L3a vault), sets up their Hermes phone agent, and tidies their projects - all without moving files blindly or losing any memory. Non-destructive and resumable. Use when the user says "/onboard", "set me up", "get me started", "build my operating system", "install this OS", or when this repo is freshly dropped into a workspace.
allowed-tools: Bash, Read, Write, Edit
---

# onboard - build the user's operating system, safely, around their real work

You are installing a stranger's operating system into a workspace that **already has their work in it**. By the end they have persistent memory across sessions, a clean project structure, their keys safely stored, and a phone agent (Hermes) - all seeded with THEIR identity and THEIR work. You figure out the right approach dynamically by reading their actual workspace first. You break nothing and you lose no memory.

Read [ARCHITECTURE.md](../../ARCHITECTURE.md) once so you can explain *why* as you go. This is a conversation, not a form. Move in steps, confirm before anything that touches their files.

## The prime directives (hold these the entire way)

1. **Lose no memory, ever.** The auto-memory pool is keyed to the workspace's absolute path (see Step 1). Resolve that path with the resolver, never by hand. If anything could de-link memory (a rename, a move), detect it and migrate rather than abandon.
2. **Never overwrite their files.** They may already have a `CLAUDE.md`, `.gitignore`, `README`, `.env`, or a half-built memory setup. Read what exists. Add beside it or merge with consent. NEVER clobber.
3. **This OS repo stays its own folder.** Do not copy this repo's root files (`CLAUDE.md`, `README.md`, `.gitignore`, `.env.example`) into their workspace root - that would overwrite theirs. The repo sits as its own directory; you write the user's NEW structure into THEIR workspace (the parent dir, or a dir they name), using the templates in `templates/`.
4. **Move nothing blindly.** "Optimise the workspace" means add structure and *propose* tidying. Show the plan, get a yes, then act. Never reorganise their files under them.
5. **Never echo or commit a secret.** Keys go to disk at permission 600. Never print one back, never commit one.
6. **Resumable.** Re-running `/onboard` re-scans and only fills gaps. Never redo done work.

---

## Step 0 - Orient

```bash
uname -s          # Darwin = macOS (Hermes works). Else note Hermes is unavailable here.
pwd               # where this repo was dropped
```
Read this repo's `README.md` and `ARCHITECTURE.md`. Tell the user in two lines what you'll do and that they can stop anytime.

**Establish the two locations clearly, out loud:**
- **OS repo dir** = where this repo lives (here).
- **Target workspace** = the folder holding their actual work that the OS should manage. Often the parent of this repo, or a sibling they point you at. Confirm it in one line before writing anything. Everything you build for the user goes under the target workspace and `~/.claude/`, never back into the OS repo.

## Step 1 - Resolve memory paths the safe way (never hand-guess)

The single fragile coupling in Claude Code: a workspace's auto-memory pool lives at `~/.claude/projects/<slug>/memory/`, where `<slug>` is the absolute path with every non-alphanumeric character turned into a hyphen. Guess it wrong and `MEMORY.md` silently never loads. So resolve it, then verify:

```bash
bash "<os-repo>/scripts/memory-paths.sh" "<target-workspace-abs-path>"
```
This prints `SLUG`, `POOL_DIR`, `MEMORY_MD`, and `FOUND`.
- `FOUND=1` - Claude Code already tracks this path. `POOL_DIR` is correct. Good.
- `FOUND=0` - either a brand-new workspace (fine, you'll create it) OR the workspace was renamed/moved and an older pool exists under a different slug. The script lists the other existing project dirs. If one clearly belongs to this same work (the user renamed the folder), go to the **Move recovery** block below before doing anything else.

### Move recovery (run only when memory may have de-linked)
If a previous pool exists under an old slug and the current one is empty:
1. Show the user both: "Your memory was under `<old-slug>`; this workspace is now `<new-slug>`. I'll migrate it so nothing's lost."
2. Migrate (copy, never move-and-pray), only after they confirm:
   ```bash
   mkdir -p "$NEW_POOL_DIR"
   cp -n "$OLD_POOL_DIR"/* "$NEW_POOL_DIR"/ 2>/dev/null || true
   cp -rn "$OLD_POOL_DIR"/*/ "$NEW_POOL_DIR"/ 2>/dev/null || true
   ```
3. Confirm `MEMORY.md` now exists at the new path. Leave the old dir untouched as a backup. Tell them the in-workspace `memory/vault/_RESUME.md` already survived the move regardless (that copy is path-independent - see ARCHITECTURE §Robustness).

## Step 2 - Scan what already exists (decide the approach from real data)

Build a picture before asking anything:
```bash
ls -la ~/.claude/CLAUDE.md 2>/dev/null              # L1 identity present?
ls -la "$MEMORY_MD" 2>/dev/null                     # pool already set up?
ls -la "<target>/memory/vault" 2>/dev/null          # vault present?
ls -la "<target>"/.gitignore "<target>"/CLAUDE.md "<target>"/.env 2>/dev/null  # files we must NOT clobber
```
Then map the target workspace: top-level folders, which look like real projects (code, a git repo, a clear purpose), whether any already has a `CLAUDE.md`. Don't deep-read their content - just map the shape.

Summarise back: "Here's what you have, here's what's missing, here's what I'll add and where." Adapt the plan to what you found. A messy workspace gets more tidying proposals; a clean one gets less.

## Step 3 - L1: who they are (global identity)

If `~/.claude/CLAUDE.md` exists, read it, show it, ask to keep/extend. Never overwrite without consent.
If absent, interview tight (4-6 questions): name + one line on what they do; their work/business (who else is involved); goals; how they want Claude to talk to them (tone, British/American English, pet hates); hard rules; the tools they use.
Fill `templates/global-CLAUDE.md.template`, read it back, then write to `~/.claude/CLAUDE.md`. Highest-leverage file in the system - get it right.

## Step 4 - L2: their projects (add beside, tidy with consent)

For each real project found in Step 2, offer the clean L2 structure (this is what `/new-project` does - reuse it):
```bash
mkdir -p "<project-path>/memory"
```
Write `<project-path>/CLAUDE.md` from `templates/project-CLAUDE.md.template` (infer what you can + 2-3 quick questions per project). Create the six `memory/` stubs (`project-brief`, `decisions`, `current-strategy`, `next-actions`, `session-summaries`, `bugs-and-risks`).

**If a project already has a `CLAUDE.md`:** read it, and *merge* the missing sections in rather than replacing. Show the diff, get consent.

**Optimising / organising (only with a shown plan and a yes):** if their workspace is messy (loose files, no structure), you may *propose* a tidy - e.g. "these three scripts could live under `project-x/`". Present it, never execute a move without explicit approval, and prefer adding structure over relocating their files. Leave existing files where they are by default.

## Step 5 - The always-loaded index + RESUME (segregated, move-proof copy in the vault)

Create `POOL_DIR` if absent and write `MEMORY.md` from `templates/MEMORY.md.template`, including the RESUME block. Set the pool up on the **segregation rule** (ARCHITECTURE §2) so it stays readable and matches anyone else running this OS:
- One fact per file. Subfolders by project/topic (`<project>/`, `references/`, `user/`, `feedback/`). One always-loaded `MEMORY.md` index, one line per memory.
Add one index line per project scaffolded in Step 4.

## Step 6 - Tools and keys (.env in THEIR workspace, never echoed)

From the tools they named, work out which need keys. For each: tell them where to get it, have them paste it, write it straight into `<target>/.env`. **Confirm `.env` is gitignored first; if they already have a `.env`, append to it, do not overwrite.** Then `chmod 600` and confirm `-rw-------`. Start from `.env.example` as the shape. Never print a key back.

## Step 7 - L3a: stand up the vault (the move-proof memory)

If `<target>/memory/vault/` isn't initialised, create it: folders `sessions/ decisions/ lessons/ outcomes/ themes/ knowledge/`, seed `_RESUME.md` from `_RESUME.md.example`. This lives *inside* the workspace, so it survives renames and is the copy Hermes reads. For L3b brains (NotebookLM), mention as an optional later step - don't build them now.

## Step 8 - Hermes: set up their phone agent (default yes on macOS)

Onboarding includes Hermes - the user should leave with a working phone agent, not a "maybe later". If `uname -s` is Darwin, say "Next I'll set up Hermes so you can message this same system from your phone" and hand off to the `hermes-setup` skill, passing the target workspace path so both surfaces share one memory. Only skip if they decline or they're not on macOS (then note they can run `/hermes-setup` later). Mirror this OS's `wrap-up` (and `morning-brief`, if they want it) into `~/.hermes/skills/` so the phone can wrap and brief too.

## Step 9 - Teach the one habit, then finish

Tell them plainly: **"From now on, end every working session with `/wrap-up`. That's the habit that saves the session into memory so the next one continues where we stopped. Without it, the memory stays empty."** Offer the morning brief too (`/morning-brief`) as the read-side of the same loop.

Offer to commit the new structure (ask first, never auto-commit; commit + push together once approved). Then report in a few lines: what got built (L1 path, projects scaffolded, vault, keys stored count - not the keys, Hermes yes/no), what was skipped and why, any memory migrated, and the `/wrap-up` habit.

---

## Resume behaviour
Re-running `/onboard`: re-run Step 1 (paths) and Step 2 (scan), show what's done, offer only the gaps. Never overwrite an existing `~/.claude/CLAUDE.md`, project `CLAUDE.md`, or `.env` without explicit consent.

## If the user already runs a memory system (reconcile, don't rebuild)
Common case: they're adopting this to align with someone else's setup. Keep their content, align the structure. Read their existing `~/.claude/CLAUDE.md`, project files, and pool; leave the *content* alone; apply the segregation rule only where missing, with consent. Match conventions, never data - their OS stays entirely theirs.

## Constraints
- Resolve memory paths with `scripts/memory-paths.sh`. Never hand-guess a slug.
- Non-destructive, always. Read-before-write on every existing file. Ask before any move.
- Never echo or commit a secret.
- No em dashes. Match the user's chosen English once set.
- Keep this OS repo free of the user's personal data - everything you generate is theirs, written to their machine.
