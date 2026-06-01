# The Claude Operating System

A drop-in repo that turns Claude into a system that **knows who you are, what you're building, and what you said last week** - and follows you between your laptop and your phone.

This is not a list of prompts. It's the *architecture* of a working second brain: Claude in your IDE, a personal agent (Hermes) on your phone, and a three-tier memory that survives across every session. You install it once, it interviews you, and by the end your Claude is set up the way a power user's is - tailored entirely to you.

> You bring the work. This repo brings the structure.

---

## What you get

1. **Memory that persists.** Claude stops forgetting. It remembers who you are, your projects, your decisions, and where you left off - automatically, every session.
2. **A phone agent (Hermes).** Message your own AI from anywhere via Telegram. It reads the same files and the same memory your IDE Claude does. A thought on the phone in the morning is available to Claude on the laptop in the afternoon.
3. **A workspace that organises itself.** New projects scaffold into a clean, future-proof structure instead of accreting mess.
4. **A guided setup.** You don't wire any of this by hand. Drop the repo in, and Claude runs the onboarding for you.

---

## The 60-second mental model

```
        YOU
         │  talk to it from two places
   ┌─────┴───────────────┐
   ▼                     ▼
 IDE Claude          Hermes (phone, via Telegram)
   │                     │
   └─────────┬───────────┘
             ▼
     ┌───────────────────────────────────┐
     │        THREE-TIER MEMORY           │
     │  L1  who you are (always loaded)   │
     │  L2  what you're building now      │
     │  L3  what you already did + know   │
     └───────────────────────────────────┘
```

Both surfaces read the same memory. That shared memory is what makes Claude feel like it *knows you*. Full detail in [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Quick start

1. **Clone this repo as its own folder** next to (or inside) the workspace that holds your real work. Keep it as its own directory - don't copy its files into your project root, so it never overwrites your existing `CLAUDE.md`, `.gitignore`, or `README`.
2. **Open it in Claude Code and say `/onboard`.** Claude reads your actual workspace, figures out the safe way to install around your existing work, asks only for what's missing, and builds the rest - identity, project structure, memory, keys, and your Hermes phone agent. It adds structure beside your files and never moves or overwrites anything without showing you first. See [ONBOARDING.md](ONBOARDING.md).
3. **At the end of every working session, say `/wrap-up`.** This is the habit that makes the whole thing work - it saves the session into memory so the next one continues seamlessly. Skip it and the memory stays empty.

That's it. No manual config files, no copy-pasting keys into the wrong place.

### Installing into a workspace you already work in

`/onboard` is built for exactly this, and it follows one rule: **it never moves, renames, or reorganises anything you already have.** It only adds a clean cabinet for new work going forward - your existing projects and loose files stay exactly where they are, named exactly what they're named, so nothing Claude has already built gets broken. It connects the full system around them (memory, keys, and your Hermes phone agent). It also handles Claude Code's one fragile spot: the auto-memory pool is keyed to your workspace's path, so if you ever rename or move the folder, run `/onboard` again and it migrates your memory across. Nothing is lost. Full detail in [ARCHITECTURE.md](ARCHITECTURE.md) §7.

---

## What's in here

| Path | What it is |
|---|---|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | How the operating system actually works, layer by layer. |
| [`ONBOARDING.md`](ONBOARDING.md) | What the `/onboard` flow does, in plain English. |
| `.claude/skills/onboard/` | The guided setup. Interviews you, builds your OS. |
| `.claude/skills/how-it-works/` | Ask Claude to explain any part of the system back to you. |
| `.claude/skills/wrap-up/` | The save-the-session ritual. Run it every session. |
| `.claude/skills/morning-brief/` | The daily debrief. Reads your memory back to you each morning. |
| `.claude/skills/new-project/` | Scaffold a new project into the clean L2 pattern. |
| `.claude/skills/hermes-setup/` | Stand up your phone agent (macOS). |
| `templates/` | The CLAUDE.md and memory templates onboarding fills in for you. |
| `memory/vault/` | The empty long-term memory vault (Obsidian-compatible). |
| `.env.example` | Placeholder keys. Onboarding fills the real `.env` for you. |

---

## Privacy

Everything runs on **your** machine with **your** keys. This repo ships with zero personal data and zero real keys - only structure and placeholders. Your memory content (`memory/vault/`) is gitignored by default, so your notes never get committed by accident. You own all of it.

---

## Credits

The memory architecture follows Jack Roberts' three-tier CLAUDE.md pattern. The phone agent is built on the open-source Hermes Agent (Nous Research, MIT). Long-term brains use Google NotebookLM. This repo packages them into one guided, install-once system.

## License

MIT - see [LICENSE](LICENSE). Use it, fork it, build your own operating system on top of it.
