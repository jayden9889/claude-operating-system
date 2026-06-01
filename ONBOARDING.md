# Onboarding - what `/onboard` does

You drop this repo into your workspace, say `/onboard`, and Claude builds your operating system for you. This page is the plain-English version of what happens. The actual logic lives in `.claude/skills/onboard/SKILL.md`.

Onboarding is a conversation, not a form. Claude only asks for what it can't work out by looking. You can stop and resume at any point - it checks what's already done before asking again.

---

## The steps

### 1. Look around AND read what you already have
First, Claude scans two things: your workspace (folders, projects, any `CLAUDE.md`) **and your current memory** - your global identity file, your memory pool, anything you've already told the system about yourself. It harvests all of that into a profile before asking you a single question.

### 2. Find the gaps
It compares what a complete operating system needs against what it just harvested, and makes a short list of what's genuinely missing. **You only ever get asked about the gaps** - anything already on disk (your name, business, tools, projects, GitHub) is never re-asked.

### 3. Learn who you are (builds L1)
Using what it already harvested, it fills your global identity file at `~/.claude/CLAUDE.md` and asks only for the missing pieces - your name, what you do, your business, tone, hard rules. This file loads into every session, every project, forever.

### 4. Set up a clean home for new work (builds L2)
This is the clean cabinet, and it's for work going forward. New projects you start get the clean structure (a `CLAUDE.md` + a `memory/` folder). Your existing projects are **never moved, renamed, or reorganised** - Claude just registers them in the index so it knows they're there, and can optionally drop a `CLAUDE.md` *beside* one if you want, which moves nothing. It also stands up the always-loaded memory index (`MEMORY.md`) with the RESUME handoff block.

### 5. Collect your tools and keys
Claude asks what tools and services you use (Claude, plus anything else - databases, payment, calendars, whatever your work needs) and which ones need API keys. Keys go straight into `.env` at locked permissions. **Claude never prints a key back to you and never commits one.**

### 6. Stand up the long-term memory
The Obsidian-compatible vault (`memory/vault/`) is initialised so `/wrap-up` has somewhere to write. Open that folder in Obsidian and you get the graph view of your whole history. If you want deep research brains (NotebookLM), it points you at how to add them.

### 7. Connect your GitHub (skipped if you're already connected)
Git is the sync layer - it's what lets your laptop and your phone (Hermes) share one memory, and what keeps your OS backed up across machines. If your workspace is already connected to a GitHub repo, Claude sees that and skips this. If not, it helps you create one (private by default) and wires it up, making sure your `.env` and keys are never committed.

### 8. Stand up Hermes, your phone agent
Onboarding sets up Hermes for you, not "maybe later" - by the end you can message your own AI from your phone and it reads the same memory as your IDE Claude, over the GitHub repo from step 7. Claude walks you through building it (hands off to the `hermes-setup` skill). macOS only; if you're not on a Mac or you decline, it's skipped cleanly and you can run `/hermes-setup` anytime.

### 9. Build your morning brief
Claude builds your daily morning brief - a short briefing that reads your memory back to you each morning (where you left off, your one non-negotiable for the day, your calendar). It delivers to your phone via Hermes, or on demand in the IDE. It gets sharper as your memory fills: the more you `/wrap-up`, the better the brief.

---

## When it's done

You'll have:
- A global identity file (L1) that makes Claude *yours*, built from what you already had plus a few gap questions.
- A clean home (L2) for all new work, with your existing projects registered but untouched.
- A live long-term memory vault (L3a), Obsidian-ready, and a path to research brains (L3b).
- Your keys safely in `.env`.
- Your GitHub wired as the sync layer.
- A phone agent (Hermes) on the same memory.
- A daily morning brief that improves as your memory grows.

From then on, the only habit you need is: **say `/wrap-up` at the end of every working session.** That's what feeds the memory. Everything else takes care of itself.

---

## Non-negotiables (so you can trust it)

- **It reads before it asks.** It harvests what you already have - your workspace and your existing memory - and only ever asks you for the genuine gaps. It never makes you re-tell it something that's already on disk.
- **It never moves or renames your existing work. Full stop.** It only adds a clean structure for new work going forward. It does not "tidy" or reorganise your old files, because moving things would break Claude's memory of where they are. The past stays exactly where it is; the future gets a clean home.
- **It never overwrites your files.** If you already have a `CLAUDE.md`, `.gitignore`, `.env`, or a partial memory setup, it reads and merges with consent - it never clobbers.
- **It never loses memory.** Memory paths are resolved exactly, not guessed. If you've renamed or moved your workspace, it detects the old memory and migrates it across, and your in-workspace handoff survives the move regardless.
- **It never leaks a secret.** Keys are written to disk at permission 600, never echoed, never committed.
- **It's resumable.** Stop halfway and run `/onboard` again later - it picks up from what's missing.