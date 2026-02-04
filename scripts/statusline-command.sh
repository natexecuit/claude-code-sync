#!/bin/bash
# Claude Code Status Line Script for macOS/Linux
# This script displays comprehensive session information with colors
# Equivalent to statusline-command.ps1 for Windows

set -euo pipefail

# ANSI Color codes (256-color mode)
# Using escape sequences compatible with macOS and Linux
COLOR_MODEL_NAME="\033[38;5;220m"      # Golden/Yellow
COLOR_PROGRESS_BAR="\033[38;5;39m"     # Bright Blue
COLOR_PERCENTAGE="\033[38;5;214m"      # Orange
COLOR_TOKENS="\033[38;5;153m"          # Cyan
COLOR_GIT_BRANCH="\033[38;5;78m"       # Green
COLOR_PROJECT_NAME="\033[38;5;213m"    # Pink/Magenta
COLOR_SEPARATOR="\033[38;5;245m"       # Gray
COLOR_RESET="\033[0m"

# Function to format numbers with abbreviations (e.g., 90k, 1.5M, 2.3B)
format_number_abbreviated() {
    local number=$1

    if awk "BEGIN {exit !($number >= 1000000000)}"; then
        awk "BEGIN {printf \"%.1fB\", $number / 1000000000}"
    elif awk "BEGIN {exit !($number >= 1000000)}"; then
        awk "BEGIN {printf \"%.1fM\", $number / 1000000}"
    elif awk "BEGIN {exit !($number >= 1000)}"; then
        awk "BEGIN {printf \"%.0fk\", $number / 1000}"
    else
        echo "$number"
    fi
}

# Read the JSON input from stdin
INPUT=$(cat)

# Parse JSON using basic string manipulation (avoiding jq dependency)
# This approach works on macOS and Linux without additional dependencies

# Initialize status line parts
STATUS_PARTS=()

# Extract model display name
MODEL_DISPLAY_NAME=$(echo "$INPUT" | grep -o '"display_name":[^,}]*' | head -1 | sed 's/"display_name":"\([^"]*\)"/\1/')
if [ -n "$MODEL_DISPLAY_NAME" ]; then
    STATUS_PARTS+=("${COLOR_MODEL_NAME}${MODEL_DISPLAY_NAME}${COLOR_RESET}")
fi

# Extract context window information
CONTEXT_WINDOW=$(echo "$INPUT" | grep -o '"context_window":{[^}]*}' | head -1)

if [ -n "$CONTEXT_WINDOW" ]; then
    # Extract remaining percentage
    REMAINING=$(echo "$CONTEXT_WINDOW" | grep -o '"remaining_percentage":[0-9.]*' | sed 's/.*://')
    # Extract used percentage
    USED=$(echo "$CONTEXT_WINDOW" | grep -o '"used_percentage":[0-9.]*' | sed 's/.*://')
    # Extract context window size
    TOTAL_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"context_window_size":[0-9]*' | sed 's/.*://')
    # Extract input tokens
    INPUT_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"total_input_tokens":[0-9]*' | sed 's/.*://')
    # Extract output tokens
    OUTPUT_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"total_output_tokens":[0-9]*' | sed 's/.*://')

    if [ -n "$USED" ] && [ "$USED" != "" ]; then
        # Create progress bar (10 segments) - Bright Blue
        FILLED=$(awk "BEGIN {printf \"%d\", $USED / 10}")
        if [ "$FILLED" -gt 10 ]; then
            FILLED=10
        fi
        EMPTY=$((10 - FILLED))

        # Use Unicode block characters for progress bar
        PROGRESS_BAR="${COLOR_PROGRESS_BAR}["
        for ((i=0; i<FILLED; i++)); do
            PROGRESS_BAR+="█"
        done
        for ((i=0; i<EMPTY; i++)); do
            PROGRESS_BAR+="░"
        done
        PROGRESS_BAR+=']'"${COLOR_RESET}"
        STATUS_PARTS+=("$PROGRESS_BAR")

        # Add percentage used - Orange
        STATUS_PARTS+=("${COLOR_PERCENTAGE}${USED}%${COLOR_RESET}")

        # Add tokens (used/total) with abbreviations - Cyan
        TOTAL_USED=$((INPUT_TOKENS + OUTPUT_TOKENS))
        FORMATTED_USED=$(format_number_abbreviated "$TOTAL_USED")
        FORMATTED_TOTAL=$(format_number_abbreviated "$TOTAL_TOKENS")
        STATUS_PARTS+=("${COLOR_TOKENS}${FORMATTED_USED}/${FORMATTED_TOTAL}${COLOR_RESET}")
    fi
fi

# Extract current directory from workspace
CURRENT_DIR=$(echo "$INPUT" | grep -o '"current_dir":[^,}]*' | head -1 | sed 's/"current_dir":"\([^"]*\)"/\1/' | sed 's/\\//g')

# Add Git Branch (if in a git repository) - Green
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    GIT_BRANCH=$(cd "$CURRENT_DIR" 2>/dev/null && git --no-optional-locks branch --show-current 2>/dev/null || true)
    if [ -n "$GIT_BRANCH" ]; then
        STATUS_PARTS+=("${COLOR_GIT_BRANCH}${GIT_BRANCH}${COLOR_RESET}")
    fi
fi

# Determine project name with fallback logic
PROJECT_NAME=""

# First try to use project_dir if available
PROJECT_DIR=$(echo "$INPUT" | grep -o '"project_dir":[^,}]*' | head -1 | sed 's/"project_dir":"\([^"]*\)"/\1/' | sed 's/\\//g')
if [ -n "$PROJECT_DIR" ]; then
    PROJECT_NAME=$(basename "$PROJECT_DIR")
fi

# Otherwise, try to get git repo name
if [ -z "$PROJECT_NAME" ] && [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    GIT_ROOT=$(cd "$CURRENT_DIR" 2>/dev/null && git --no-optional-locks rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$GIT_ROOT" ]; then
        PROJECT_NAME=$(basename "$GIT_ROOT")
    fi
fi

# Last resort: use current directory name
if [ -z "$PROJECT_NAME" ] && [ -n "$CURRENT_DIR" ]; then
    PROJECT_NAME=$(basename "$CURRENT_DIR")
fi

# Always show project name if we have one
if [ -n "$PROJECT_NAME" ]; then
    STATUS_PARTS+=("${COLOR_PROJECT_NAME}[${PROJECT_NAME}]${COLOR_RESET}")
fi

# Join all parts with separator
SEPARATOR="${COLOR_SEPARATOR} | ${COLOR_RESET}"
STATUS_LINE=""
FIRST=true
for part in "${STATUS_PARTS[@]}"; do
    if [ "$FIRST" = true ]; then
        STATUS_LINE="$part"
        FIRST=false
    else
        STATUS_LINE="${STATUS_LINE}${SEPARATOR}${part}"
    fi
done

# Output the status line
echo -e "$STATUS_LINE"
