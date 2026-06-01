# CLAUDE.md - The Claude Operating System (installer)

This repo is a drop-in **operating system for Claude**: persistent three-tier memory, a phone agent (Hermes), and a guided setup. When this file is in context, you (Claude) are running inside that installer. Your job is to get the user set up, then get out of the way.

> Full design: [ARCHITECTURE.md](ARCHITECTURE.md). What setup does: [ONBOARDING.md](ONBOARDING.md).

---

## First action, every session (the session-start contract)

1. **Check for a RESUME handoff.** Look for `memory/vault/_RESUME.md` and the RESUME block at the top of the user's auto-memory `MEMORY.md`. If either exists, read it first - it says where the last session left off. Continue from there.
2. **Check whether onboarding has run.** If there is no `~/.claude/CLAUDE.md` (no L1 identity) and no RESUME handoff, this is a fresh install. Say so in one line and offer to run `/onboard` now. Do not start building anything else until the user has an operating system to build it into.

---

## What you must tell a new user (once, early)

Two sentences, plainly:
- "Say `/onboard` and I'll set up your whole memory system and phone agent, tailored to you."
- "At the end of every working session, say `/wrap-up` - that's the habit that saves the session into memory so the next one continues where we stopped. Without it, the memory stays empty."

The `/wrap-up` habit is load-bearing. Reinforce it whenever a substantial session is ending and the user hasn't wrapped.

---

## The skills in this repo

| Skill | Use it for |
|---|---|
| `/onboard` | First-run setup. Scans the workspace, interviews the user, builds their L1/L2/L3 memory and (optionally) Hermes. |
| `/how-it-works` | Explain any part of the operating system back to the user, grounded in ARCHITECTURE.md. |
| `/wrap-up` | Close a session: RESUME handoff + vault session note + keep memory sorted. Run every session. |
| `/morning-brief` | The daily debrief. Reads your memory back to you each morning with one non-negotiable. The read-side counterpart to `/wrap-up`. |
| `/new-project` | Scaffold a new project into the clean L2 pattern (CLAUDE.md + memory/ folder). |
| `/hermes-setup` | Stand up the phone agent on the user's Mac (macOS only). |

---

## Hard rules while running this installer

- **Never echo a secret.** API keys and tokens go straight into `.env` (or `~/.hermes/.env`) at file permission 600. Never print them back into chat, never commit them.
- **Non-destructive.** When optimising the user's existing workspace, ADD structure alongside their files. Do not move or rename their work without asking first and explaining why.
- **Ask before committing.** Git is the sync layer, but never auto-commit. Offer, then commit + push together once approved.
- **This is architecture, not anyone's business.** This repo ships with zero personal data. Keep it that way - everything you generate during onboarding is the *adopter's* data, written to *their* machine, not back into this repo.
- **No em dashes.** Hyphens or full stops.
