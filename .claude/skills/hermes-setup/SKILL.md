---
name: hermes-setup
description: Stand up the user's phone agent (Hermes) on their Mac so they can message their own AI from anywhere via Telegram, reading the same workspace and memory as their IDE Claude. Builds the agent, an always-on launchd watchdog, and a pmset rule, then optionally wires it to the same vault and NotebookLM brains. macOS only. Use when the user says "/hermes-setup", "set up Hermes", "build my phone agent", "I want to message my AI from my phone", or when /onboard reaches the optional Hermes step.
allowed-tools: Bash, Read, Write, Edit
---

# hermes-setup - the phone agent

You are building the user a personal AI agent that lives on their Mac and answers from anywhere via Telegram. It thinks with their Claude API key and reads the **same files and same memory** as their IDE Claude - that's what makes it the second door into one shared brain. Walk every step. Don't skip optional steps without asking.

## Hard constraints - read first
- **macOS only.** Uses `launchd` + `pmset`. If `uname -s` isn't `Darwin`, stop and tell the user it won't work on Linux/Windows.
- **User must be physically at their unlocked Mac** for setup. After that, they only use the phone.
- **Never echo a secret.** Keys/tokens go straight into `~/.hermes/.env` at permission 600. Never paste back, never commit.
- **One provider at a time.** Default Anthropic.

## Step 0 - Gather inputs
Run `uname -s` (must be Darwin). Then have the user collect, as a checklist - wait until they confirm all before writing config:
1. Telegram account on their phone.
2. Anthropic API key (console.anthropic.com → API keys, starts `sk-ant-`).
3. Their numeric Telegram user ID (message `@userinfobot`).
4. A Telegram bot token (message `@BotFather` → `/newbot` → name + username → token like `123456:ABC-DEF...`).
5. ~30 minutes; they'll paste a sudo password once.
6. Agent name + tone (e.g. "Hermes" sharp, "Atlas" calm, "Jeeves" formal) - goes in the SOUL.
7. *(Optional)* The absolute path of the workspace the agent should operate in - typically the same folder their IDE Claude uses.
8. *(Optional, for L3b brains)* A Google account with NotebookLM, signed into a supported browser for cookie auth.

## Step 1 - Install the agent
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh -o /tmp/hermes-install.sh
bash /tmp/hermes-install.sh
```
Creates `~/.hermes/` and a venv at `~/.hermes/hermes-agent/venv/`. Verify `ls ~/.hermes/hermes-agent/venv/bin/hermes`. If the binary isn't there, read the installer output back and stop.

## Step 2 - Secrets file `~/.hermes/.env`
```bash
ANTHROPIC_API_KEY=<from 0.2>
HERMES_LLM_PROVIDER=anthropic
HERMES_LLM_MODEL=claude-haiku-4-5
TELEGRAM_BOT_TOKEN=<from 0.4>
TELEGRAM_ALLOWED_USERS=<numeric ID from 0.3>
HERMES_WORKSPACE=<path from 0.7, if given>
```
`chmod 600 ~/.hermes/.env`, confirm `ls -la` shows `-rw-------`. The `TELEGRAM_ALLOWED_USERS` line is the security wall - anyone else who finds the bot is ignored. Say this to the user.

## Step 3 - The SOUL (`~/.hermes/SOUL.md`) - mirror the user's L1 identity
The SOUL is Hermes' identity. Pull it from the user's `~/.claude/CLAUDE.md` so the phone agent talks like their IDE Claude. Keep it under ~80 lines (long SOULs are slow). Cover: who the agent is + who it serves, one line on what the user does, the tone, and - if a workspace was given - the workspace path, git remote, and conventions (never auto-commit; commit + push together once approved; never touch `.env` or gitignored files; surface merge conflicts, don't auto-resolve). Read it back for approval before saving.

## Step 4 - First-run test (foreground)
```bash
~/.hermes/hermes-agent/venv/bin/hermes gateway
```
Look for `Telegram connected (polling mode)` and `Gateway running`. Have them message the bot "hi" from the phone and watch for an `inbound message` log + a reply within seconds. If nothing, see Troubleshooting. Don't proceed until one round-trip works. Then Ctrl+C.

## Step 5 - Always-on watchdog (`launchd`)
Get the username (`whoami`) and CPU arch (`uname -m`: `arm64` = Apple Silicon `/opt/homebrew/bin`, `x86_64` = Intel `/usr/local/bin`). Write `~/Library/LaunchAgents/com.<USERNAME>.hermes-gateway.plist` with `ProgramArguments` = the venv hermes binary + `gateway`, `RunAtLoad` true, `KeepAlive` true, `ThrottleInterval` 30, correct `PATH`, and stdout/stderr to `~/.hermes/logs/`. Load it:
```bash
launchctl load -w ~/Library/LaunchAgents/com.<USERNAME>.hermes-gateway.plist
launchctl list | grep hermes      # must show a real PID, not "-"
```
If PID is `-`, read `~/.hermes/logs/launchd-stderr.log` (usually a wrong PATH). From now on, if the agent dies, launchd revives it within 30s.

## Step 6 - Stay awake on wall power only
```bash
sudo pmset -c sleep 0 disksleep 0
```
`-c` = AC power only. System never sleeps plugged in; battery rules untouched (sleeps normally unplugged, stays cool). Verify `pmset -g custom`. **Caveat to tell them:** lid closed while plugged in still suspends unless an external display is attached. So keep the lid open, attach a display, or use a tool like Amphetamine.

## Step 7 - (Optional) Connect to the same memory as IDE Claude
This is the whole point - one memory, two doors.
- **Same workspace:** if a `HERMES_WORKSPACE` was set, Hermes reads the same files the IDE Claude does. No extra wiring.
- **Same git repo:** Hermes uses the already-authorised `~/.ssh/` key to push/pull the same repo. The vault syncs both ways through git - so a `/wrap-up` on the laptop is readable on the phone, and vice versa.
- **Mirror the wrap-up skill:** copy this OS's `wrap-up` skill into `~/.hermes/skills/wrap-up/SKILL.md` so the phone can wrap a session too. Keep both copies in sync.
- **Same brains (optional):** if they use NotebookLM, give Hermes a `notebooklm` skill at `~/.hermes/skills/research/notebooklm/SKILL.md` referencing the same brain IDs the IDE side uses.

## Step 8 - Final verification
Have them confirm each: (1) phone message → reply in seconds; (2) lid closed 60s on power (with display) → still reachable; (3) unplug, walk away 10 min, replug → responds within ~30s of waking. If Step 7 done: (4) save a note from the phone, open the workspace in the IDE, confirm the file is there.

## Troubleshooting
- **No reply to first message:** check `.env` token + allowed-users number. Foreground the gateway and watch. `rejected (not in allowed_users)` = wrong user ID; no `inbound message` line at all = wrong token.
- **launchd PID is `-`:** `cat ~/.hermes/logs/launchd-stderr.log`. Usually wrong PATH for the arch (Step 5).
- **Replies take 10s+:** wrong model. Haiku is the right default; Sonnet/Opus are slower.
- **"Operation already in progress" on load:** already loaded. `launchctl unload <plist>` then load again.
- **macOS warns about a new background item after reboot:** normal. Allow under System Settings → General → Login Items & Extensions.

## Revert path
```bash
launchctl unload ~/Library/LaunchAgents/com.<USERNAME>.hermes-gateway.plist
rm ~/Library/LaunchAgents/com.<USERNAME>.hermes-gateway.plist
sudo pmset -c sleep 1 disksleep 10
rm -rf ~/.hermes
```

## Security model - say this verbatim
Everything sits on the user's Mac. Keys in `~/.hermes/.env` at mode 600. The `allowed_users` lock means messages from any account but theirs are ignored. Real threats: phone unlocked by someone else, Telegram account hijack, physical access to the unlocked Mac - mitigate with phone lock, Telegram 2FA, screen lock. Third parties in the loop: Telegram (transport), Anthropic (the LLM), and Google (only if NotebookLM is used). No inbound port exists - the agent only polls outbound to Telegram. Not "100% airtight", but no random hacker on the internet can reach it.

## Done
When all verification passes, tell them: they now have a personal AI on their Mac reachable from anywhere via Telegram, kept alive by a watchdog, reading the same memory as their IDE Claude. Ongoing cost is just the LLM usage - typically fractions of a cent per message with Haiku.

## Constraints
- macOS only. Never echo or commit a secret. No em dashes.
- The agent's identity (SOUL) mirrors the user's L1 `~/.claude/CLAUDE.md` - keep them consistent.