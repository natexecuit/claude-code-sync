# Claude Code Sync Instructions

## Quick Reference

| What You Want to Do | Prompt to Use |
|---------------------|---------------|
| **Setup new device** | See `scripts/apply-config.md` |
| **Log new changes** | "Log this Claude Code change to my sync config" |
| **Push to GitHub** | "Update and push my Claude config sync to GitHub" |
| **Pull from GitHub** | "Pull latest Claude config from GitHub and apply changes" |
| **Compare devices** | "Compare this Claude config with my sync file" |

---

## Project-Level Auto-Sync Instructions

Add this to your project prompt or Claude Code system prompt:

```
CLAUDE CODE SYNC BEHAVIOR:
Whenever I make changes to Claude Code configuration (settings, keybindings, skills, statusline, etc.), automatically:
1. Ask: "Sync this change to your other devices?"
2. If yes, update CLAUDE_CONFIG.md in the sync repo
3. Show what changed and offer to commit & push to GitHub
```

---

## Initial GitHub Setup

### First Time Only:

```bash
# Windows - adjust the path to your repo location:
cd S:\Claude\repos\claude-projects\claude-code-sync
git init
git add CLAUDE_CONFIG.md INSTRUCTIONS.md README.md AUTO_SYNC_PROMPT.md scripts/
git commit -m "Initial Claude Code config sync"
gh repo create claude-code-sync --public --source=. --push
```

Note: On Windows, run `git add` in Git Bash or use forward slashes in paths.

---

## Daily Workflow

### After Making Claude Code Changes:

```
Please sync my Claude Code configuration changes to GitHub.
```

### On New Device:

```
Please set up my Claude Code environment from my sync config at https://github.com/natexecuit/claude-code-sync
```

---

## Files in This Repo

```
claude-code-sync/
├── CLAUDE_CONFIG.md       # Main configuration log
├── INSTRUCTIONS.md        # This file - detailed sync instructions
├── README.md              # Public overview
├── AUTO_SYNC_PROMPT.md    # Auto-sync behavior prompts
└── scripts/
    ├── statusline-command.ps1  # Windows statusline script
    ├── statusline-command.sh   # Mac/Linux statusline script
    ├── apply-config.md         # New device setup prompts
    └── apply-config.sh         # Auto-apply script for Mac/Linux
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2026-02-03 | Initial sync system created |
