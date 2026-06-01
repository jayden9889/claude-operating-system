---
name: new-project
description: Scaffold a new project on the three-tier memory pattern. Creates a project directory with a 6-section CLAUDE.md (A-F + optional G) and a memory/ subfolder with the 6 named files (project-brief, decisions, current-strategy, next-actions, session-summaries, bugs-and-risks). Use when the user says "/new-project <name>", "start a new project", "scaffold a project for X", "set up a clean folder for Y". This is the L2 bootstrap - every new project starts neat and future-proof instead of accreting mess.
allowed-tools: Bash, Write, Read
---

# new-project - scaffold a clean L2 project

Every new project starts on the same L2 pattern so it's neat from day one and Claude always knows where things live. This is the "one CLAUDE.md per project + a memory/ folder beside it" pattern, wired into the operating system's memory architecture.

## When this fires
- `/new-project billing-app`
- "I want to build X" → scaffold first, then build
- "set up a clean folder for Y"

## What it produces
```
<project-path>/
├── CLAUDE.md                  # 6-section template (A-F + optional G), max 200 lines
└── memory/
    ├── project-brief.md       # frozen brief - fill at kickoff, then freeze
    ├── decisions.md           # dated decision log, append-only
    ├── current-strategy.md    # live, evolving focus
    ├── next-actions.md        # task queue
    ├── session-summaries.md   # last 10 /wrap-up outputs (auto-appended)
    └── bugs-and-risks.md      # open issues + risks
```

## The action loop

### 1. Resolve the path + slug
- **Slug:** kebab-case from the name (`billing-app`).
- **Path:** ask where it lives if not obvious. Confirm the path in one line. This is the only gate.

### 2. Interview just enough to fill the brief
Ask 3-4 tight questions, not a form:
- What is this and what stage (idea / sandbox / shipped / paused / sunset)?
- What's the goal - the problem it kills, and what "done" looks like?
- What's the stack (if known - "TBD" is fine)?
- Any decisions already made that shouldn't be re-litigated?

If they say "just scaffold it", create the files with `{{TBD}}` placeholders and move on. Don't block.

### 3. Create the structure
```bash
mkdir -p <project-path>/memory
```
Write `<project-path>/CLAUDE.md` from `templates/project-CLAUDE.md.template`. Write the 6 memory files - `project-brief.md` gets what you learned in step 2; the rest start as headed stubs.

### 4. Register in the workspace MEMORY.md index
Add one line under the right heading in the auto-memory `MEMORY.md` so the project is discoverable:
```
- [<Project Name>](../../<project-path>/CLAUDE.md) - <one-line hook>
```

### 5. Report
Tell them: path created, that the CLAUDE.md auto-loads when they work in that dir, and that `/wrap-up` will append to its `session-summaries.md`. Then start the actual build if that was the request.

## The memory file stubs
- **project-brief.md:** `# <Project> - Project Brief (FROZEN <date>)` + the kickoff answers. Frozen once filled.
- **decisions.md:** `# <Project> - Decisions Log` + "Append-only. To override, add a new dated entry."
- **current-strategy.md:** `# <Project> - Current Strategy` + "Active focus. When stable, move to decisions.md."
- **next-actions.md:** `# <Project> - Next Actions` + an empty checklist.
- **session-summaries.md:** `# <Project> - Session Summaries` + "Last 10 /wrap-up outputs, auto-appended."
- **bugs-and-risks.md:** `# <Project> - Bugs and Risks` + "Open issues. When fixed, move to decisions.md with the fix date."

## Constraints
- **200-line ceiling on CLAUDE.md.** Past that Claude skims - push detail into the matching `memory/` file.
- **One CLAUDE.md per project**, not per repo. Monorepos get one per meaningful subfolder.
- **Always set the date** in the header. A stale brief is worse than none.
- **Don't over-fill at kickoff.** `{{TBD}}` is honest - the files grow as the project does.
- **One confirmation gate** - the path in step 1. After that, scaffold autonomously.