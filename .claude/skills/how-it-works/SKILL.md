---
name: how-it-works
description: Explain how the Claude Operating System works - the three-tier memory (L1 identity / L2 project / L3 long-term), the two surfaces (IDE Claude + Hermes phone agent), git as the sync layer, and the wrap-up ritual that feeds memory. Use when the user asks "how does this work", "explain the memory system", "what is L1/L2/L3", "how does Hermes connect", "where does X live", "what's the architecture", or wants the system explained back to them. Grounded in ARCHITECTURE.md - never invent behaviour.
allowed-tools: Read
---

# how-it-works - explain the operating system

The user wants to understand the system, or a piece of it. Your job is to explain it clearly and accurately, grounded in the repo's own docs. Never guess how it works - read the source of truth and answer from it.

## Source of truth

Read [ARCHITECTURE.md](../../ARCHITECTURE.md) first - it is canonical. For setup questions also read [ONBOARDING.md](../../ONBOARDING.md); for the save ritual read the `wrap-up` skill; for the phone agent read the `hermes-setup` skill. Answer from these files, not from memory of how other systems work.

## How to answer

- **Scope to what they asked.** If they ask "what's L2?", explain L2 and how it connects to L1 and L3 - don't recite the whole architecture unless they asked for the whole thing.
- **Plain English, concrete.** Name the actual files and paths (`~/.claude/CLAUDE.md`, `memory/vault/`, the project `memory/` folder). Use the one-screen mental model from ARCHITECTURE.md when a picture helps.
- **Always land the two load-bearing ideas** when relevant:
  1. The system is only as good as the `/wrap-up` ritual - memory that isn't written doesn't exist.
  2. One memory, two doors - IDE Claude and Hermes read the same files, so context follows the user between laptop and phone.
- **If asked "where does X belong?"** give the routing rule: identity → L1, what you're building → L2, what you already did → L3a vault, deep topic knowledge → L3b brain.
- **If they ask something the docs don't cover,** say so plainly rather than inventing an answer, and point them at the closest doc.

## The shape, in one breath (use when they want the whole thing fast)

Two surfaces you talk to (IDE Claude, Hermes on your phone) sit on top of one shared, file-based, three-tier memory: L1 is who you are (always loaded), L2 is what you're building now (loaded per project), L3 is what you already did and know (queried on demand). Git syncs it between surfaces. `/wrap-up` writes each session into it. That's the whole system.