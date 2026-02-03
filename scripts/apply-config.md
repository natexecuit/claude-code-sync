# Claude Code Config - Auto-Apply Instructions

**Save this prompt for use on new devices:**

---

## NEW DEVICE SETUP PROMPT

Copy everything below and paste into Claude Code on your new device:

```
I need to set up my Claude Code environment to match my other devices. Please:

1. Go to my GitHub repo and read: https://raw.githubusercontent.com/natexecuit/claude-code-sync/main/CLAUDE_CONFIG.md

2. Parse the configuration and apply ALL settings:
   - StatusLine: Create the appropriate script for this OS (detect Windows/Mac/Linux)
   - Skills: Install all skills listed in "Skills Installed" section
   - Settings: Update ~/.claude/settings.json with all configurations
   - Keybindings: Apply any custom keybindings

3. Create the local sync folder structure at: ~/claude-code-sync/ or appropriate path

4. After setup, show me a summary of what was applied

5. Set up automatic change detection: After this, whenever I make Claude Code setup changes, automatically ask if I want to sync to my other devices via the claude-code-sync config
```

---

## ONE-LINE VERSION (Quick Setup)

```
Set up my Claude Code by fetching and applying config from: https://raw.githubusercontent.com/natexecuit/claude-code-sync/main/CLAUDE_CONFIG.md
```

---

## UPDATE URL BEFORE USE

Replace `[YOUR_USERNAME]` with your actual GitHub username in the URLs above.

---

## AFTER SETUP

Test by running:
```
Show me my current Claude Code configuration status
```
