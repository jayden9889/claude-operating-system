---
name: morning-brief
description: Build and maintain the user's daily morning brief - a short, context-aware briefing delivered each morning (to the phone via Hermes/Telegram, or printed in the IDE) that reads the user's own memory and tells them the one thing that matters today. Use when the user says "/morning-brief", "set up my morning brief", "give me my brief", "what should I focus on today", or wants a daily debrief routine. Mirrors a two-phase dreaming-then-delivery pipeline. Design-principles skill - it teaches Claude how to build the routine, not a fixed cron config.
allowed-tools: Bash, Read, Write, Edit
---

# morning-brief - the daily debrief

The morning brief is the system reading itself back to the user. Each morning it scans their own memory (where they left off, what's open, what's on the calendar) and hands them a tight briefing with one non-negotiable for the day. It is the read-side counterpart to `/wrap-up`: wrap-up writes memory at night, the brief reads it back in the morning. Together they close the loop.

This skill captures the **design pattern**, not a frozen config. Build the routine the user asks for, on these principles.

## Architecture - two phases

```
[Dreaming]  ──context──▶  [Delivery]
  early AM                  later AM
  silent                    → Hermes/Telegram (or IDE)
  deep scan                 assembles the brief
  writes to a file          reads dreaming output, ships it
```

- **Phase 1 - Dreaming (silent).** A deep analytical scan across the user's data sources. Produces a few strategic recommendations plus a single non-negotiable for the day. Writes to a file (e.g. `~/.hermes/cron/dreaming-output.md` if Hermes is set up, else a workspace temp file). No delivery.
- **Phase 2 - Delivery.** Assembles the brief from the dreaming output plus light extras (calendar, optional weather, optional quote) and ships it. If Hermes is set up, delivery is a scheduled job that sends to Telegram; if not, `/morning-brief` prints it in the IDE on demand.

Chain the two so the delivery phase receives the dreaming output as context. Keep dreaming heavy and delivery light.

## Data sources (read the user's OWN memory, in priority order)

The brief is only as good as what it reads. Pull from the operating system's own memory first:

1. **RESUME handoff** - `memory/vault/_RESUME.md` and the RESUME block in the auto-memory `MEMORY.md`. This is where the last session left off. Highest-signal source.
2. **Next actions** - each active project's `memory/next-actions.md`.
3. **Git log** - `git log --oneline --since="5 days ago" -30` in the workspace. The real activity log.
4. **The vault** - latest notes in `memory/vault/sessions/` and `memory/vault/decisions/` for recent context.
5. **Project state** - active `CLAUDE.md` files reveal current focus.
6. **Calendar** - if a calendar tool is wired, today's events.
7. **L3b brains** - only if reliably authenticated; otherwise skip (see Hard rule 1).

## Hard rules (every routine must obey)

### 1. Never hang
Every data source in the dreaming phase is OPTIONAL. If a source hangs, times out, or errors, skip it and move on. Wrap external calls (`timeout 20 ...`, `curl --max-time 10`). A partial brief that ships on time beats a complete one that never arrives. **Never query a source that might be unauthenticated (e.g. a NotebookLM brain) without verifying access first** - a model with no data will fabricate rather than report the gap.

### 2. Surface gaps
If a source failed, say so in one line: "Heads-up: [source] was unavailable this morning - [fix]." The user fixes infrastructure instead of the brief silently degrading.

### 3. Context-aware over static
Never just rotate a static list when real context exists. Use the dreaming output and memory to make the brief fit where the user actually is that day. Static rotation is the fallback, not the default.

### 4. Hardcoded fallbacks
Every external call (weather, quote, calendar) needs a fallback that ships in under a second. API down → a sane local default or a plain "unavailable" line. The brief always ships.

### 5. Goals-aligned
Every recommendation must serve at least one of the user's goals (read them from `~/.claude/CLAUDE.md`). The single non-negotiable is the one action that moves them closest to those goals today. Recommendations that serve no goal are noise - cut them.

## Delivery format (tight - the user reads it in 20 seconds)

```
Good morning.

▶ Where you are: <1-2 lines from the RESUME handoff>
▶ Today's non-negotiable: <the single highest-leverage action>
▶ Also open: <2-3 carry-forward items, max>
▶ Calendar: <today's events, or "clear">
<optional: weather line / one verified quote>
<only if something failed: Heads-up: ... >
```

Keep it short. A brief the user won't read is wasted. No transcript, no filler.

## Building it for the user

1. **Decide the surface.** Hermes set up and on macOS → build it as two scheduled jobs (dreaming early, delivery later) delivering to Telegram. No Hermes → `/morning-brief` is invoked on demand in the IDE and prints the brief.
2. **Wire the dreaming phase** to read the sources above with timeouts, write its output to a file.
3. **Wire the delivery phase** to read that file, assemble the format, ship it.
4. **Scheduling:** on Hermes, use its cron; in Claude Code, use a routine or the user's own cron. Keep the two phases ~1-2 hours apart so dreaming finishes before delivery reads it.
5. **Optional extras** (weather, quote) are opt-in - ask before adding, and give each a hardcoded fallback.

## Constraints
- Never hang. Never fabricate a source you could not read. Always surface gaps.
- Goals come from the user's L1 `~/.claude/CLAUDE.md` - never hardcode someone else's goals.
- Reads the same memory as `/wrap-up` writes - keep the loop closed.
- No em dashes.
