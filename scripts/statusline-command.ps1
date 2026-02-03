# Claude Code Status Line Script for Windows PowerShell
# This script displays comprehensive session information

# Read the JSON input from stdin
$input = [Console]::In.ReadToEnd()

# Parse JSON
$json = $input | ConvertFrom-Json

# Initialize status line parts
$statusParts = @()

# Add Model Information
$modelInfo = "$($json.model.display_name)"
$statusParts += $modelInfo

# Add Current Working Directory (truncated if too long)
$currentDir = $json.workspace.current_dir
if ($currentDir.Length -gt 30) {
    $currentDir = "..." + $currentDir.Substring($currentDir.Length - 27)
}
$statusParts += $currentDir

# Add Output Style if available
if ($json.output_style -and $json.output_style.name -ne "default") {
    $statusParts += "[$($json.output_style.name)]"
}

# Add Agent Information if available
if ($json.agent -and $json.agent.name) {
    $statusParts += "Agent: $($json.agent.name)"
}

# Add Vim Mode if available
if ($json.vim -and $json.vim.mode) {
    $statusParts += "VIM: $($json.vim.mode)"
}

# Add Context Window Information
if ($json.context_window) {
    $remaining = $json.context_window.remaining_percentage
    $used = $json.context_window.used_percentage

    if ($null -ne $remaining) {
        $statusParts += "Context: $remaining% remaining"
    } elseif ($null -ne $used) {
        $statusParts += "Context: $used% used"
    }
}

# Join all parts with separator
$statusLine = $statusParts -join " | "

# Output the status line
Write-Output $statusLine
