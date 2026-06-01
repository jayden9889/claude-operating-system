# Architecture - how the operating system works

This is the canonical explanation. The `/how-it-works` skill reads this file to answer questions about the system. Read it top to bottom once and you'll understand the whole thing.

The operating system has **three parts**: two surfaces you talk to (Claude in the IDE, Hermes on your phone), and one shared memory underneath them. The memory is the part that matters. The surfaces are just doors into it.

---

## 1. The problem this solves

A raw LLM forgets everything between sessions. Every conversation starts from zero: you re-explain who you are, what you're building, what you decided last week. The model is brilliant and amnesiac at the same time.

This OS fixes that by giving Claude a **filesystem-based memory** in layers, plus a ritual (`/wrap-up`) that writes each session into that memory before it ends. The next session reads the memory first and picks up exactly where you left off. Do that for a few weeks and Claude starts behaving like a colleague who has been with you the whole time.

---

## 2. The three memory tiers (the core)

Based on Jack Roberts' three-tier CLAUDE.md pattern. Think of it like human memory: identity, working memory, and long-term recall.

### L1 - Identity (always loaded)
**File:** `~/.claude/CLAUDE.md` (global, every project, every session).

Who you are. Your role, your business, how you want Claude to talk to you, your hard rules. Small and stable - changes maybe once a quarter. This is the layer that makes Claude *yours* rather than generic. It loads into every single conversation automatically.

### L2 - Working memory (loaded per project)
**Files:** one `CLAUDE.md` per project + a `memory/` folder beside it.

What you're building *right now*, project by project. Each project gets a 6-section `CLAUDE.md` (what it is, the goal, the stack, locked decisions, a memory map, references) and a `memory/` folder with six named files:

| File | Holds |
|---|---|
| `project-brief.md` | The frozen kickoff brief |
| `decisions.md` | Dated, append-only decision log |
| `current-strategy.md` | The live, evolving focus |
| `next-actions.md` | The task queue |
| `session-summaries.md` | Last ~10 `/wrap-up` outputs |
| `bugs-and-risks.md` | Open issues and risks |

A project's `CLAUDE.md` auto-loads whenever Claude is working inside that directory. So context narrows to the right project without you doing anything.

There's also a **workspace-wide auto-memory pool** at `~/.claude/projects/<your-workspace>/memory/`, indexed by a `MEMORY.md` that loads every session. It holds cross-cutting facts (preferences, feedback, reference pointers) and the **RESUME handoff** - a short block at the top that says where the last session stopped.

**The segregation rule (this is what keeps the pool readable as it grows):**
- **One fact per file.** Each memory is a single small markdown file, not a section of a big file.
- **Segregate into subfolders by project/topic** - e.g. `<project-a>/`, `<project-b>/`, `references/`, `user/`, `feedback/`. Each project's cross-cutting memories live in its own subfolder, so projects stay cleanly separated.
- **One index, always loaded.** `MEMORY.md` at the pool root is the *only* file auto-loaded into context. It carries one line per memory (a title + a one-line hook + a relative link into the subfolder). The subfolder files themselves are pulled in only when relevant.
- **Net effect:** projects are segregated (own subfolders) but still readable from one place (the index). The always-loaded cost stays tiny - just the index - while the content can grow without bound.

If two people run identical operating systems (e.g. teammates), keeping this exact convention means their pools are structured the same way, so each person's Claude can read and reason about the other's memory layout without translation.

### L3 - Long-term recall (queried on demand)
Two halves:

- **L3a - the vault.** `memory/vault/` is a git-backed, Obsidian-compatible markdown vault. `/wrap-up` writes one cross-linked note per session here: what was discussed, decided, built, and what fought you. Because notes link to each other, you can raise a topic weeks later and pull every session that touched it. Git is also the sync layer (see §4).
- **L3b - living brains.** Curated long-form knowledge in Google NotebookLM (e.g. a research brain on a person or topic). You grow these over time and query them when you need deep domain knowledge that doesn't belong in context.

### How the tiers fit together
```
L1  ~/.claude/CLAUDE.md            ── always in context (identity)
L2  <project>/CLAUDE.md + memory/  ── in context when you're in that project
L2  .../<workspace>/memory/MEMORY.md ── always in context (cross-cutting + RESUME)
L3a memory/vault/                  ── queried/searched on demand (session history)
L3b NotebookLM brains              ── queried on demand (deep knowledge)
```

When in doubt about where something belongs: **identity → L1, what you're shipping → L2, what you already did → L3a, deep topic knowledge → L3b.**

---

## 3. The two surfaces

### Claude in the IDE
The main workhorse. Reads L1 + L2 automatically, queries L3 when asked. This is where you build.

### Hermes on your phone
A small open-source agent (Hermes, Nous Research) running as a background process on your Mac. You message it from anywhere via a private Telegram bot. It thinks using your Claude API key and reads the **same workspace files, the same git repo, and the same brains** as your IDE Claude.

Hermes has its own home at `~/.hermes/` with a `SOUL.md` (its identity, mirrored from your L1) and its own skills. A macOS `launchd` watchdog restarts it if it crashes; a `pmset` rule keeps the Mac awake on wall power so it's always reachable. Full build in the `hermes-setup` skill.

The point of two surfaces: **one memory, two doors.** Capture a thought on the phone, and the laptop has it. Make a decision at the desk, and the phone knows.

---

## 4. The glue: git + the wrap-up ritual

Two mechanisms hold it together.

**Git is the sync layer.** The vault and the workspace are a git repo. When `/wrap-up` writes a session note and you push, Hermes (which shares the same checkout) sees it. No special protocol - just a shared repo and a shared SSH key.

**`/wrap-up` is the heartbeat.** Nothing reaches long-term memory unless a session is wrapped. The skill does three jobs every time:
1. Writes the **RESUME handoff** (where we are, what's open, what broke, what's next) so the next session instantly continues.
2. Writes the durable, cross-linked **session note** into the vault.
3. Keeps the system sorted (project summaries, decisions, next-actions).

**This is the one habit the whole system depends on.** Run `/wrap-up` at the end of every real session. Skip it and the memory stays empty - the architecture is only as good as the ritual feeding it.

**`/morning-brief` closes the loop.** Wrap-up writes memory at night; the morning brief reads it back in the morning. A scheduled two-phase routine (a silent deep scan, then a short delivery to your phone via Hermes or printed in the IDE) reads your RESUME handoff, next-actions, recent git log, and calendar, then hands you one non-negotiable for the day. Same memory, read instead of written. Full build in the `morning-brief` skill.

---

## 5. How onboarding builds all of this for a new person

`/onboard` (the centrepiece skill) doesn't assume anything. It:
1. Detects the OS and scans your existing workspace - what's already here, what's missing.
2. Interviews you for the gaps: who you are, your business, your tools, your API keys.
3. Writes your L1 global `CLAUDE.md` and a L2 `CLAUDE.md` for each real project it finds.
4. Stands up the auto-memory pool (`MEMORY.md` + RESUME block) and the L3a vault.
5. Slots your keys into `.env` (never echoing them) and, if you want, stands up Hermes.
6. Does all of this **non-destructively** - it adds structure alongside your files, it doesn't move your work around.

You end with the same operating system the author has, seeded entirely with *your* identity and *your* work.

---

## 6. Design rules (why it's shaped this way)

- **Files, not a database.** Memory is plain markdown you can read, edit, grep, and back up. No vendor lock-in.
- **Small always-loaded core, large queried tail.** L1 + RESUME stay tiny so they fit in every context cheaply; L3 can be huge because it's only pulled when needed.
- **One CLAUDE.md per project, 200-line ceiling.** Past ~200 lines Claude skims. Detail spills into the `memory/` files.
- **The ritual is mandatory.** Memory that isn't written is memory that doesn't exist. `/wrap-up` is non-optional.
- **Your machine, your keys, your data.** Nothing about this OS requires a third party to hold your information.

---

## 7. Robustness - what survives moving your workspace

This matters when you install the OS into a workspace that already has work in it, then later rename or move that folder. Most of the system is move-proof by design; exactly one piece is fragile, and it's handled.

| Layer | If you rename/move the workspace | Why |
|---|---|---|
| L1 `~/.claude/CLAUDE.md` | **Survives** | Global, path-independent. Loads in every session regardless of where your work lives. |
| L2 project `CLAUDE.md` | **Survives** | Lives *inside* the project folder. Claude Code loads it by proximity to the current directory, not by an absolute path. It moves with the folder. |
| L3a vault `memory/vault/` | **Survives** | Lives *inside* the workspace, referenced by relative paths. Moves with the folder. The `_RESUME.md` handoff is here, so it survives too. |
| Auto-memory pool `MEMORY.md` | **Breaks (then recovered)** | Claude Code keys this to a **slug of the workspace's absolute path** (`~/.claude/projects/<slug>/`). Rename the folder and the slug changes, so the pool de-links. This is Claude Code's design, not ours. |

**How the one fragile layer is handled:**
- **Resolve, never guess.** Every skill that touches the pool calls `scripts/memory-paths.sh`, which computes the slug the exact way Claude Code does (every non-alphanumeric character in the absolute path becomes a hyphen, per Unicode code point) and verifies the directory exists. No skill ever hand-types a slug, because a wrong guess loses memory silently.
- **A move-proof duplicate.** `/wrap-up` writes the RESUME handoff to *both* the path-keyed pool and the in-workspace `memory/vault/_RESUME.md`. The vault copy moves with your folder, so the "where did we leave off" handoff is never lost to a rename.
- **Automatic migration.** If you moved the folder, `/onboard` detects the old pool under its old slug and migrates it to the new one (copy, not move, so the old stays as a backup). Run `/onboard` after any rename and your cross-cutting memory follows.

The practical rule: your identity, your project files, and your session history all move with your work. The only thing a rename can briefly de-link is the cross-cutting pool index, and `/onboard` re-links it on demand.