---
name: wrap-up
description: Close a working session so the NEXT session (IDE Claude or Hermes on the phone) picks up exactly where this one left off. Does three jobs - (1) writes an always-loaded RESUME handoff so the next agent instantly knows where things are, what's open, and what broke; (2) writes the session into long-term memory (the vault, as a cross-linked, queryable note); (3) keeps the memory system sorted (project summaries, decisions, next-actions). Use when the user says "/wrap-up", "wrap up", "save where we are", "log this session", "capture this", or at the natural end of a substantial session. Do NOT fire for trivial one-question chats.
allowed-tools: Bash, Read, Write, Edit
---

# wrap-up - the ritual that makes memory work

**Read this first, and say it to the user the first few times you run it:** this is the habit the entire operating system depends on. Nothing reaches long-term memory unless a session is wrapped. Run `/wrap-up` at the end of *every* real working session - a build, a decision, a debugging win, an unresolved blocker. Skip it and the next session starts blind, and the memory stays empty. **Saving every conversation into memory is the user's job, and `/wrap-up` is how they do it.** Remind them of this whenever a substantial session is ending unwrapped.

It does **three jobs**, in order. Job 1 is non-negotiable and comes first.

The long-term backend is the git-backed markdown vault at `memory/vault/`. Git is the sync layer between the IDE surface and the phone (Hermes) surface.

## When to fire
Fire on: `/wrap-up`, "wrap up", "save where we are", "log this session", or the natural end of a session with real substance.
Do NOT fire for: trivial one-question chats or quick lookups.

---

## JOB 1 - The RESUME handoff (always, first)

This is what makes the next session "just know". Write the SAME short handoff to **both** places so both surfaces pick it up:

**(a) The auto-memory `MEMORY.md`** in the Claude project memory dir. **Resolve that path, never hand-guess the slug** (a wrong guess writes the handoff where the next session won't read it):
```bash
bash "<os-repo>/scripts/memory-paths.sh"   # prints MEMORY_MD for this workspace
```
It is auto-loaded into context every session. Overwrite the block between the markers (create them at the top, just under the heading, if absent):

```
<!-- RESUME:START - overwritten by /wrap-up; where the last session left off -->
## ▶ Resume - <YYYY-MM-DD>: <session title>
- **Did:** <1-2 lines, the substance of the session>
- **Left off:** <the exact point we stopped at>
- **Open / blockers:** <what's unresolved or what fought us>
- **Next:** <the first thing to do next session>
- Full note: memory/vault/sessions/<YYYY-MM-DD>-<slug>.md
<!-- RESUME:END -->
```

**(b) The vault `memory/vault/_RESUME.md`** - identical content plus a one-line frontmatter `updated: <date>`. This is the copy Hermes reads (Hermes shares the vault, not the IDE auto-memory pool). It also lives *inside* the workspace, so it survives a folder rename/move even if the path-keyed pool (a) de-links - it's the move-proof handoff. Always write both.

Keep it tight, 5-8 lines. Overwrite each time; never append - this is "current state", not history. Full history lives in the session note.

---

## JOB 2 - Write the session into long-term memory

### 2a. Session note (the durable, queryable record)
`memory/vault/sessions/<YYYY-MM-DD>-<short-slug>.md`:

```markdown
---
date: <YYYY-MM-DD>
type: session
project: <slug>
tags: [<topic-tags>]
links: ["[[<decisions/lessons/topics this session touched>]]"]
---

# <Session title>

**Discussed:** <1-3 sentences>
**Decided:** <bullets - link each real decision to its note>
**Built:** <bullets - concrete artefacts, file paths, commands, commits>
**Difficulties / what fought us:** <bullets - problems, dead-ends, blockers, so they're never re-hit blind>
**Open / next:** <carry-forward items>
```

Use **basename** wikilinks (`[[three-tier-memory]]`, never `[[../path]]`). Cross-link every topic touched - that's what makes topic-recall work weeks later.

### 2b. Make the topic recallable later
For each meaningful topic, ensure a page exists in `memory/vault/knowledge/` and link the session to it (and back). A topic page accumulating `[[session]]` backlinks is how "bring up the same thing next month and know what we said" works. Only create a page for something with lasting value - don't manufacture.

---

## JOB 3 - Keep the system sorted

- **Project session-summaries:** append a tight 2-3 line entry (newest on top, keep ~last 10) to `<project>/memory/session-summaries.md`, referencing the full note. If the project has no `memory/` folder, say so and offer `/new-project` - don't silently skip.
- **Persistent difficulties:** if a blocker will matter next time, add it to `<project>/memory/bugs-and-risks.md`, not just the session note.
- **Next actions:** update `<project>/memory/next-actions.md` with carry-forward items.
- **Decisions (only if a real one happened):** `memory/vault/decisions/<date>-<slug>.md` - the call, why, what it cost or risked, the context.
- **Lessons (only if durable wisdom emerged):** `memory/vault/lessons/<slug>.md`. Rare. Don't manufacture.

## JOB 3b - Promote durable changes to the RIGHT CLAUDE.md (not by default)

Do NOT touch CLAUDE.md every wrap-up. Route deliberately:
- **Session state / where-we-left-off** → never CLAUDE.md. That's the RESUME handoff (Job 1).
- **A durable convention that will shape FUTURE builds** → the LOCAL project `CLAUDE.md` (or workspace-level if workspace-wide). Only when genuinely reusable.
- **The GLOBAL `~/.claude/CLAUDE.md`** is almost never touched - life/identity/business facts only. Analyse the chat yourself for any such fact; if one clearly surfaced, flag it in one line and let the user confirm rather than writing unprompted.

## JOB 4 - Commit + push (cross-surface sync)

Git is the sync layer. After writing, **ask the user to commit** (never auto-commit), then commit + push so Hermes sees it:
```
git add memory/vault/ <project>/memory/
git commit -m "wrap-up: <session title>"
git push
```
(The auto-memory `MEMORY.md` lives outside the repo, so its RESUME block syncs to the IDE automatically; the vault `_RESUME.md` is what carries the handoff to Hermes.)

## Report
One line: the RESUME handoff written (both places), the session note path, any decision/lesson/topic pages touched, and whether it's pushed so Hermes is in sync.

## Constraints
- **Job 1 always runs.** Even a light session updates the RESUME handoff.
- **Difficulties are mandatory when they happened** - never re-hit the same wall blind.
- **Tight notes, not transcripts.** A wrap-up the user won't re-read is wasted.
- **Decisions/lessons are extracted, not manufactured.**
- **Basename wikilinks only**, no `..` paths.
- **No em dashes.**
- **If Hermes is set up,** mirror this skill at `~/.hermes/skills/wrap-up/SKILL.md` and keep both in sync.