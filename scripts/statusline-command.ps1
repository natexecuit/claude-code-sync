# Claude Code Status Line Script for Windows PowerShell
# This script displays comprehensive session information with colors

# ANSI Color codes
$ESC = [char]27

# Define colors
$colors = @{
    ModelName       = "$ESC[38;5;220m"      # Golden/Yellow
    ProgressBar     = "$ESC[38;5;39m"       # Bright Blue
    Percentage      = "$ESC[38;5;214m"      # Orange
    Tokens          = "$ESC[38;5;153m"      # Cyan
    GitBranch       = "$ESC[38;5;78m"       # Green
    ProjectName     = "$ESC[38;5;213m"      # Pink/Magenta
    Separator       = "$ESC[38;5;245m"      # Gray
    Reset           = "$ESC[0m"
}

# Function to format numbers with abbreviations (e.g., 90k, 1.5M, 2.3B)
function Format-NumberAbbreviated {
    param([long]$number)

    if ($number -ge 1_000_000_000) {
        return "{0:N1}B" -f ($number / 1_000_000_000)
    } elseif ($number -ge 1_000_000) {
        return "{0:N1}M" -f ($number / 1_000_000)
    } elseif ($number -ge 1_000) {
        return "{0:N0}k" -f ($number / 1_000)
    } else {
        return $number.ToString()
    }
}

# Read the JSON input from stdin
$input = [Console]::In.ReadToEnd()

# Parse JSON
$json = $input | ConvertFrom-Json

# Initialize status line parts
$statusParts = @()

# 1. Add Model Information (Golden/Yellow)
$modelInfo = "$($colors.ModelName)$($json.model.display_name)$($colors.Reset)"
$statusParts += $modelInfo

# 2-4. Add Context Window Information (Progress bar, percentage, tokens)
if ($json.context_window) {
    $remaining = $json.context_window.remaining_percentage
    $used = $json.context_window.used_percentage
    $totalTokens = $json.context_window.context_window_size
    $inputTokens = $json.context_window.total_input_tokens
    $outputTokens = $json.context_window.total_output_tokens
    $totalUsed = $inputTokens + $outputTokens

    if ($null -ne $used) {
        # Create progress bar (10 segments) - Bright Blue
        $filled = [math]::Floor($used / 10)
        $empty = 10 - $filled
        $progressBar = "$($colors.ProgressBar)[$("█" * $filled)$("░" * $empty)]$($colors.Reset)"
        $statusParts += $progressBar

        # Add percentage used - Orange
        $statusParts += "$($colors.Percentage)$used%$($colors.Reset)"

        # Add tokens (used/total) with abbreviations - Cyan
        $formattedUsed = Format-NumberAbbreviated $totalUsed
        $formattedTotal = Format-NumberAbbreviated $totalTokens
        $statusParts += "$($colors.Tokens)$formattedUsed/$formattedTotal$($colors.Reset)"
    }
}

# 5. Add Git Branch (if in a git repository) - Green
try {
    $currentDir = $json.workspace.current_dir
    if ($currentDir) {
        $gitBranch = git -C $currentDir --no-optional-locks branch --show-current 2>$null
        if ($gitBranch) {
            $statusParts += "$($colors.GitBranch)$gitBranch$($colors.Reset)"
        }
    }
} catch {
    # Silently skip if git is not available or not in a git repo
}

# 6. Add Project Name - Pink/Magenta
# Determine project name with fallback logic
$projectName = $null
$currentDir = $json.workspace.current_dir

# First try to use project_dir if available
if ($json.workspace.project_dir) {
    $projectName = Split-Path -Leaf $json.workspace.project_dir
}
# Otherwise, try to get git repo name
elseif ($currentDir) {
    try {
        $gitRoot = git -C $currentDir --no-optional-locks rev-parse --show-toplevel 2>$null
        if ($gitRoot) {
            $projectName = Split-Path -Leaf $gitRoot
        }
    } catch {
        # Silently skip if git is not available
    }
}

# Last resort: use current directory name
if (-not $projectName -and $currentDir) {
    $projectName = Split-Path -Leaf $currentDir
}

# Always show project name if we have one
if ($projectName) {
    $statusParts += "$($colors.ProjectName)[$projectName]$($colors.Reset)"
}

# Join all parts with separator
$separator = "$($colors.Separator) | $($colors.Reset)"
$statusLine = $statusParts -join $separator

# Output the status line
Write-Output $statusLine
