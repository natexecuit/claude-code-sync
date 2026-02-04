#!/bin/bash
# Claude Code Config Auto-Apply Script for macOS/Linux
# This script automatically applies the Claude Code configuration from a sync repo

set -euo pipefail

# ANSI Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USER="${GITHUB_USER:-natexecuit}"
REPO_NAME="${REPO_NAME:-claude-code-sync}"
CONFIG_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/CLAUDE_CONFIG.md"
SYNC_DIR="${HOME}/claude-code-sync"
CLAUDE_DIR="${HOME}/.claude"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux";;
        Darwin*)    OS="Mac";;
        *)          OS="Unknown";;
    esac
    log_info "Detected OS: $OS"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    local missing_deps=()

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl or wget")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again."
        exit 1
    fi

    log_success "All dependencies available"
}

# Download config file
download_config() {
    log_info "Downloading configuration from GitHub..."

    mkdir -p "$SYNC_DIR"
    mkdir -p "$CLAUDE_DIR"

    if command -v curl &> /dev/null; then
        curl -fsSL "$CONFIG_URL" -o "${SYNC_DIR}/CLAUDE_CONFIG.md"
    else
        wget -q "$CONFIG_URL" -O "${SYNC_DIR}/CLAUDE_CONFIG.md"
    fi

    log_success "Configuration downloaded to ${SYNC_DIR}/CLAUDE_CONFIG.md"
}

# Parse and display configuration
parse_config() {
    log_info "Parsing configuration..."
    echo ""
    cat "${SYNC_DIR}/CLAUDE_CONFIG.md"
    echo ""
}

# Install statusline script
install_statusline() {
    print_header "Installing Statusline Script"

    local statusline_script="${CLAUDE_DIR}/statusline-command.sh"
    local source_script="${SYNC_DIR}/scripts/statusline-command.sh"

    # Check if source script exists in sync dir
    if [ -f "$source_script" ]; then
        cp "$source_script" "$statusline_script"
        chmod +x "$statusline_script"
        log_success "Statusline script installed to ${statusline_script}"
    else
        log_warning "Statusline script not found in sync repo, creating from template..."
        create_statusline_script "$statusline_script"
    fi

    # Update settings.json with statusline config
    update_settings_statusline "$statusline_script"
}

# Create statusline script inline (fallback)
create_statusline_script() {
    local target_file="$1"

    cat > "$target_file" << 'STATUSLINE_EOF'
#!/bin/bash
# Claude Code Status Line Script for macOS/Linux
# Equivalent to statusline-command.ps1 for Windows

set -euo pipefail

# ANSI Color codes (256-color mode)
COLOR_MODEL_NAME="\033[38;5;220m"      # Golden/Yellow
COLOR_PROGRESS_BAR="\033[38;5;39m"     # Bright Blue
COLOR_PERCENTAGE="\033[38;5;214m"      # Orange
COLOR_TOKENS="\033[38;5;153m"          # Cyan
COLOR_GIT_BRANCH="\033[38;5;78m"       # Green
COLOR_PROJECT_NAME="\033[38;5;213m"    # Pink/Magenta
COLOR_SEPARATOR="\033[38;5;245m"       # Gray
COLOR_RESET="\033[0m"

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

INPUT=$(cat)
STATUS_PARTS=()

MODEL_DISPLAY_NAME=$(echo "$INPUT" | grep -o '"display_name":[^,}]*' | head -1 | sed 's/"display_name":"\([^"]*\)"/\1/')
if [ -n "$MODEL_DISPLAY_NAME" ]; then
    STATUS_PARTS+=("${COLOR_MODEL_NAME}${MODEL_DISPLAY_NAME}${COLOR_RESET}")
fi

CONTEXT_WINDOW=$(echo "$INPUT" | grep -o '"context_window":{[^}]*}' | head -1)
if [ -n "$CONTEXT_WINDOW" ]; then
    USED=$(echo "$CONTEXT_WINDOW" | grep -o '"used_percentage":[0-9.]*' | sed 's/.*://')
    TOTAL_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"context_window_size":[0-9]*' | sed 's/.*://')
    INPUT_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"total_input_tokens":[0-9]*' | sed 's/.*://')
    OUTPUT_TOKENS=$(echo "$CONTEXT_WINDOW" | grep -o '"total_output_tokens":[0-9]*' | sed 's/.*://')

    if [ -n "$USED" ] && [ "$USED" != "" ]; then
        FILLED=$(awk "BEGIN {printf \"%d\", $USED / 10}")
        [ "$FILLED" -gt 10 ] && FILLED=10
        EMPTY=$((10 - FILLED))
        PROGRESS_BAR="${COLOR_PROGRESS_BAR}["
        for ((i=0; i<FILLED; i++)); do PROGRESS_BAR+="█"; done
        for ((i=0; i<EMPTY; i++)); do PROGRESS_BAR+="░"; done
        PROGRESS_BAR+=']'"${COLOR_RESET}"
        STATUS_PARTS+=("$PROGRESS_BAR")
        STATUS_PARTS+=("${COLOR_PERCENTAGE}${USED}%${COLOR_RESET}")
        TOTAL_USED=$((INPUT_TOKENS + OUTPUT_TOKENS))
        FORMATTED_USED=$(format_number_abbreviated "$TOTAL_USED")
        FORMATTED_TOTAL=$(format_number_abbreviated "$TOTAL_TOKENS")
        STATUS_PARTS+=("${COLOR_TOKENS}${FORMATTED_USED}/${FORMATTED_TOTAL}${COLOR_RESET}")
    fi
fi

CURRENT_DIR=$(echo "$INPUT" | grep -o '"current_dir":[^,}]*' | head -1 | sed 's/"current_dir":"\([^"]*\)"/\1/' | sed 's/\\//g')
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    GIT_BRANCH=$(cd "$CURRENT_DIR" 2>/dev/null && git --no-optional-locks branch --show-current 2>/dev/null || true)
    [ -n "$GIT_BRANCH" ] && STATUS_PARTS+=("${COLOR_GIT_BRANCH}${GIT_BRANCH}${COLOR_RESET}")
fi

PROJECT_NAME=""
PROJECT_DIR=$(echo "$INPUT" | grep -o '"project_dir":[^,}]*' | head -1 | sed 's/"project_dir":"\([^"]*\)"/\1/' | sed 's/\\//g')
[ -n "$PROJECT_DIR" ] && PROJECT_NAME=$(basename "$PROJECT_DIR")
if [ -z "$PROJECT_NAME" ] && [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    GIT_ROOT=$(cd "$CURRENT_DIR" 2>/dev/null && git --no-optional-locks rev-parse --show-toplevel 2>/dev/null || true)
    [ -n "$GIT_ROOT" ] && PROJECT_NAME=$(basename "$GIT_ROOT")
fi
[ -z "$PROJECT_NAME" ] && [ -n "$CURRENT_DIR" ] && PROJECT_NAME=$(basename "$CURRENT_DIR")
[ -n "$PROJECT_NAME" ] && STATUS_PARTS+=("${COLOR_PROJECT_NAME}[${PROJECT_NAME}]${COLOR_RESET}")

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
echo -e "$STATUS_LINE"
STATUSLINE_EOF

    chmod +x "$target_file"
    log_success "Statusline script created at ${target_file}"
}

# Update settings.json with statusline config
update_settings_statusline() {
    local script_path="$1"
    local settings_file="${CLAUDE_DIR}/settings.json"

    # Create settings.json if it doesn't exist
    if [ ! -f "$settings_file" ]; then
        echo "{}" > "$settings_file"
    fi

    log_info "Updating settings.json with statusline configuration..."

    # Note: Actual JSON modification should be done by Claude Code agent
    # This script prepares the environment and displays instructions
    echo ""
    log_info "Please add the following to your settings.json:"
    echo ""
    echo -e "${GRAY}{${NC}"
    echo -e "${GRAY}  \"statusLine\": {${NC}"
    echo -e "${GRAY}    \"type\": \"command\",${NC}"
    echo -e "${GRAY}    \"command\": \"bash\",${NC}"
    echo -e "${GRAY}    \"args\": [\"${script_path}\"]${NC}"
    echo -e "${GRAY}  }${NC}"
    echo -e "${GRAY}}${NC}"
    echo ""
}

# Install skills mentioned in config
install_skills() {
    print_header "Installing Skills"

    # Extract skill names from config
    local skills=$(grep -oP '(?<=\| )[a-z-]+(?= \|| [0-9]+ \|)' "${SYNC_DIR}/CLAUDE_CONFIG.md" 2>/dev/null || true)

    if [ -z "$skills" ]; then
        log_warning "No skills found in configuration"
        return
    fi

    log_info "Skills to install: $skills"
    log_info "Please ask Claude Code to install these skills:"
    echo ""
    for skill in $skills; do
        echo "  - /skill install $skill"
    done
    echo ""
}

# Setup complete summary
show_summary() {
    print_header "Setup Complete"

    log_success "Claude Code configuration has been downloaded and prepared."
    echo ""
    log_info "Next steps:"
    echo "  1. Review the configuration at: ${SYNC_DIR}/CLAUDE_CONFIG.md"
    echo "  2. Ask Claude Code to apply the settings:"
    echo -e "     ${GRAY}\"Apply the configuration from ${SYNC_DIR}/CLAUDE_CONFIG.md\"${NC}"
    echo "  3. Install any skills mentioned in the config"
    echo ""
    log_info "Sync directory: ${SYNC_DIR}"
    log_info "Claude directory: ${CLAUDE_DIR}"
    echo ""
}

# Main execution
main() {
    print_header "Claude Code Config Auto-Apply"

    detect_os
    check_dependencies
    download_config
    parse_config

    # Install components
    install_statusline
    install_skills

    show_summary
}

# Run main function
main "$@"
