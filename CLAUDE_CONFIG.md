# Claude Code Configuration Sync

**Last Updated:** 2026-02-04
**Device Sync ID:** nathaniel-claude-config-v1

---

## Current Configuration

### StatusLine
- **File:** `~/.claude/statusline-command.ps1` (Windows) / `statusline-command.sh` (Mac/Linux)
- **Purpose:** Display model, progress bar, percentage, tokens, git branch, project name
- **Features:** Color-coded elements (256-color ANSI), abbreviated token numbers (90k format)
- **Color Scheme:**
  - Model name: Golden/Yellow
  - Progress bar: Bright Blue
  - Percentage: Orange
  - Tokens: Cyan
  - Git branch: Green
  - Project name: Pink/Magenta
  - Separator: Gray
- **Settings Configuration:**
  ```json
  "statusLine": {
    "type": "command",  // MUST be "command" (not "shell")
    "command": "powershell",  // or "bash" for Mac/Linux
    "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "%USERPROFILE%\\.claude\\statusline-command.ps1"]
    // NOTE: Replace %USERPROFILE% with your actual user profile path, or use the expanded path:
    // On Windows: C:\Users\<YourUsername>\.claude\statusline-command.ps1
    // On Mac/Linux: ~/.claude/statusline-command.sh
  }
  ```
  ⚠️ **IMPORTANT:** `type` must be `"command"` - using `"shell"` will cause a validation error
- **Installed:** 2026-02-03 via statusline-setup agent
- **Updated:** 2026-02-03 15:45 - Added colors, abbreviated tokens, smart project name detection
- **Fixed:** 2026-02-04 - Corrected `statusLine.type` from "shell" to "command" to fix validation error

### Skills Installed
| Skill Name | Tokens | Purpose | Date Added |
|------------|--------|---------|------------|
| superdesign | 162 | Frontend UI/UX design agent | 2026-02-03 |
| find-skills | 79 | Discover and install agent skills | 2026-02-03 |
| keybindings-help | - | Customize keyboard shortcuts | Default |

### Settings Modified
| File | Change | Date |
|------|--------|------|
| `~/.claude/settings.json` | Added statusLine configuration pointing to PowerShell script | 2026-02-03 |

### Keybindings
*No custom keybindings configured yet*

### Aliases/Shortcuts
*No custom aliases configured yet*

---

## Change Log

### 2026-02-04
- **BUG FIX:** Corrected `statusLine.type` from "shell" to "command"
  - The `type` field must be `"command"` - using `"shell"` causes a validation error
  - Updated documentation with explicit JSON configuration example
  - Added warning note about required value
- **DOCUMENTATION FIX:** Updated all file structure diagrams to match actual repository files
  - Fixed references to non-existent files (statusline-command.sh, keybindings.json, skills/ folder)
  - Added missing files to structure diagrams (README.md, INSTRUCTIONS.md, AUTO_SYNC_PROMPT.md, statusline-command.ps1)
  - Removed generic `[YOUR_USERNAME]` and `[REPO_PATH]` placeholders throughout documentation
  - Standardized file references across all documentation files

### 2026-02-03 15:45
- **STATUSLINE UPDATE:** Enhanced with colors and better formatting
  - Added 256-color ANSI color scheme for all elements
  - Token display now uses abbreviated format (90k instead of 90000)
  - Smart project name detection: project_dir → git repo root → current directory
  - Elements: Model name | Progress bar | Percentage | Tokens | Git branch | Project name

### 2026-02-03
- **INITIAL SETUP:** Created this sync system
- **STATUSLINE:** Installed via statusline-setup agent
  - Created `%USERPROFILE%\.claude\statusline-command.ps1` (Windows) / `~/.claude/statusline-command.sh` (Mac/Linux)
  - Updated `%USERPROFILE%\.claude\settings.json` with statusLine config
- **REPO:** Created `claude-code-sync` repository structure

---

## Device Setup Instructions

### To Apply This Config on a New Device:

**Copy and paste this entire prompt into Claude Code on your new device:**

```
Please set up my Claude Code environment by reading the sync configuration from my GitHub repo:

1. Go to: https://github.com/natexecuit/claude-code-sync/raw/main/CLAUDE_CONFIG.md
2. Parse the configuration and apply all settings, skills, and customizations
3. Create the statusline script appropriate for this OS (Windows/Mac/Linux)
4. Update settings.json with all configurations
5. Install any skills mentioned in the "Skills Installed" section
6. Confirm when setup is complete with a summary of what was applied
```

### To Update & Push Changes (After Making Changes):

**Run this prompt on your current device:**
```
Please log the current Claude Code configuration changes to my sync file and then help me commit and push to GitHub with the message "Update Claude Code config [date]".
```

---

## Ongoing Sync Instructions

### Automatic Change Detection Prompt

Save this as a reusable prompt/alias:

```
After any Claude Code setup change, ask me: "Would you like to log this change to your sync config for other devices?" If I say yes, automatically update CLAUDE_CONFIG.md with the new changes, increment the version, and offer to commit and push to GitHub.
```

### Quick Sync Commands

| Action | Prompt |
|--------|--------|
| **Pull latest config** | "Read my Claude config sync from GitHub and apply any changes to this device" |
| **Push my changes** | "Update my Claude config sync file with current settings and push to GitHub" |
| **Compare devices** | "Compare this device's Claude config with the sync file and show differences" |
| **Reset to sync** | "Reset this device's Claude config to match the sync file exactly" |

---

## File Structure

```
claude-code-sync/
├── CLAUDE_CONFIG.md           # This file - main configuration log
├── README.md                  # Project overview and quick start
├── INSTRUCTIONS.md            # Detailed sync instructions
├── AUTO_SYNC_PROMPT.md        # Auto-sync behavior prompts
└── scripts/
    ├── statusline-command.ps1 # Windows statusline script
    ├── statusline-command.sh  # Mac/Linux statusline script
    ├── apply-config.md        # New device setup prompts
    └── apply-config.sh        # Auto-apply script for Mac/Linux
```

---

## Notes

- This file should be committed to GitHub for cross-device sync
- Update the "Last Updated" timestamp whenever you make changes
- Include the device name when making device-specific changes
- Test on new device before relying on it for critical work

---

*Generated by Claude Code Config Sync System*
