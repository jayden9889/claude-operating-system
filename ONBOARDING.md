# Onboarding - what `/onboard` does

You drop this repo into your workspace, say `/onboard`, and Claude builds your operating system for you. This page is the plain-English version of what happens. The actual logic lives in `.claude/skills/onboard/SKILL.md`.

Onboarding is a conversation, not a form. Claude only asks for what it can't work out by looking. You can stop and resume at any point - it checks what's already done before asking again.

---

## The seven steps

### 1. Look around
Claude detects your operating system and scans your existing workspace - the folders, the projects, whether you already have a `CLAUDE.md`, whether a memory system is partly set up. It builds a picture before asking you anything.

### 2. Find the gaps
It compares what a complete operating system needs against what you already have, and makes a short list of what's missing. You only get asked about the gaps.

### 3. Learn who you are (builds L1)
A few tight questions: your name, what you do, the business or work you're in, how you want Claude to talk to you, any hard rules. This becomes your global identity file at `~/.claude/CLAUDE.md` - loaded into every session, every project, forever.

### 4. Set up a clean home for new work (builds L2)
This is the clean cabinet, and it's for work going forward. New projects you start get the clean structure (a `CLAUDE.md` + a `memory/` folder). Your existing projects are **never moved, renamed, or reorganised** - Claude just registers them in the index so it knows they're there, and can optionally drop a `CLAUDE.md` *beside* one if you want, which moves nothing. It also stands up the always-loaded memory index (`MEMORY.md`) with the RESUME handoff block.

### 5. Collect your tools and keys
Claude asks what tools and services you use (Claude, plus anything else - databases, payment, calendars, whatever your work needs) and which ones need API keys. Keys go straight into `.env` at locked permissions. **Claude never prints a key back to you and never commits one.**

### 6. Stand up the long-term memory
The Obsidian-compatible vault (`memory/vault/`) is initialised so `/wrap-up` has somewhere to write. If you want deep research brains (NotebookLM), it points you at how to add them.

### 7. Stand up Hermes, your phone agent
Onboarding sets up Hermes for you, not "maybe later" - by the end you can message your own AI from your phone and it reads the same memory as your IDE Claude. Claude walks you through building it (hands off to the `hermes-setup` skill) and wires it to the same workspace. macOS only; if you're not on a Mac or you decline, it's skipped cleanly and you can run `/hermes-setup` anytime.

---

## When it's done

You'll have:
- A global identity file (L1) that makes Claude *yours*.
- Clean project structure (L2) for everything you're working on.
- A live long-term memory vault (L3a), and a path to research brains (L3b).
- Your keys safely in `.env`.
- Optionally, a phone agent wired to the same memory.

From then on, the only habit you need is: **say `/wrap-up` at the end of every working session.** That's what feeds the memory. Everything else takes care of itself.

---

## Non-negotiables (so you can trust it)

- **It never moves or renames your existing work. Full stop.** It only adds a clean structure for new work going forward. It does not "tidy" or reorganise your old files, because moving things would break Claude's memory of where they are. The past stays exactly where it is; the future gets a clean home.
- **It never overwrites your files.** If you already have a `CLAUDE.md`, `.gitignore`, `.env`, or a partial memory setup, it reads and merges with consent - it never clobbers.
- **It never loses memory.** Memory paths are resolved exactly, not guessed. If you've renamed or moved your workspace, it detects the old memory and migrates it across, and your in-workspace handoff survives the move regardless.
- **It never leaks a secret.** Keys are written to disk at permission 600, never echoed, never committed.
- **It's resumable.** Stop halfway and run `/onboard` again later - it picks up from what's missing.