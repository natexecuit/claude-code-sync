# Claude Code Configuration Sync

Synchronize Claude Code configuration across multiple devices.

## What This Does

- Tracks all Claude Code settings, skills, keybindings, and customizations
- Enables one-click setup on new devices
- Keeps configurations in sync via GitHub

## Quick Start on New Device

Paste this into Claude Code:

```
Set up my Claude Code by fetching and applying config from: https://raw.githubusercontent.com/natexecuit/claude-code-sync/main/CLAUDE_CONFIG.md
```

## Current Configuration

See [CLAUDE_CONFIG.md](CLAUDE_CONFIG.md) for full details of tracked settings.

## Structure

```
.
├── CLAUDE_CONFIG.md       # Live configuration log
├── INSTRUCTIONS.md        # Detailed sync instructions
├── README.md             # This file
└── scripts/
    └── apply-config.md   # Device setup prompts
```

## Usage

| Action | Prompt |
|--------|--------|
| Sync changes | "Update and push my Claude config sync" |
| Pull updates | "Pull latest Claude config from GitHub" |
| Compare configs | "Compare my Claude config with sync file" |

## Privacy Note

This repo contains configuration files only. No sensitive data, API keys, or personal content is stored.

---

*Automatically maintained by Claude Code*
