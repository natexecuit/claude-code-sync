# Claude Code Auto-Sync Behavior

## Add This to Your System Prompt or Project Instructions

Copy the following block and include it in your Claude Code project instructions or save as a reusable prompt:

---

```
=== CLAUDE CODE SYNC BEHAVIOR ===

Whenever I make changes to Claude Code configuration, you must:

1. DETECT CHANGES in:
   - ~/.claude/settings.json
   - ~/.claude/keybindings.json (if exists)
   - ~/.claude/statusline-command.* (if exists)
   - Any skill installations via /skills command
   - Any custom aliases or shortcuts

2. AFTER ANY CONFIG CHANGE, ASK ME:
   "I detected changes to your Claude Code configuration. Would you like to sync this to your other devices?"

3. IF I SAY YES:
   a. Read the current sync file at: /s/Claude/repos/claude-projects/claude-code-sync/CLAUDE_CONFIG.md
   b. Update it with the new changes
   c. Update the "Last Updated" timestamp
   d. Add an entry to the "Change Log" section
   e. Show me a summary of what will be synced
   f. Ask: "Commit and push to GitHub?"

4. IF I SAY NO:
   Note it for next time and continue

5. SYNC FILE LOCATION (adjust per device):
   - Windows: S:\Claude\repos\claude-projects\claude-code-sync\CLAUDE_CONFIG.md
   - Mac: ~/Claude/repos/claude-projects/claude-code-sync/CLAUDE_CONFIG.md
   - Linux: ~/Claude/repos/claude-projects/claude-code-sync/CLAUDE_CONFIG.md

=== END CLAUDE CODE SYNC BEHAVIOR ===
```

---

## Quick Prompts for Manual Sync

### Push Changes to GitHub
```
Update my Claude Code config sync file with all current changes and push to GitHub
```

### Pull Changes from GitHub
```
Pull the latest Claude Code config from GitHub and apply any new changes to this device
```

### Force Full Sync
```
Force sync: read my GitHub Claude config, compare with this device, show differences, and apply all changes
```

---

## Tips for Best Results

1. **Always say yes** to sync prompts when you've made intentional changes
2. **Commit frequently** - better to have small, incremental syncs
3. **Test on one device first** before applying to critical devices
4. **Keep GitHub repo private** if you have sensitive customizations

---

*This file is part of the Claude Code Sync System*
