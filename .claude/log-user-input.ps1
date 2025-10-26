# User Input Logger for Claude Code
# Records user message inputs with timestamp

param()

# Set console encoding to UTF-8 for proper Chinese character handling
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "SilentlyContinue"
$logFile = Join-Path $PSScriptRoot "user-input.log"

# Create UTF-8 encoding without BOM to prevent garbled Chinese characters
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

try {
    # Read all stdin input
    $inputLines = @()
    while ($null -ne ($line = [Console]::ReadLine())) {
        $inputLines += $line
    }
    $inputData = $inputLines -join "`n"

    if (-not [string]::IsNullOrWhiteSpace($inputData)) {
        try {
            $json = $inputData | ConvertFrom-Json
            $userMessage = ""

            # Extract user message from various possible fields
            if ($json.message) {
                $userMessage = $json.message
            } elseif ($json.prompt) {
                $userMessage = $json.prompt
            } elseif ($json.text) {
                $userMessage = $json.text
            } elseif ($json.content) {
                $userMessage = $json.content
            } else {
                # Fallback to raw input
                $userMessage = $inputData
            }

            # Get timestamp
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

            # Build lightweight log entry
            # Format: ----- timestamp -----
            #         user message content
            #         (blank line)
            $logEntry = "----- $timestamp -----`n$userMessage`n`n"

            # Write to log with UTF8 encoding without BOM (ensures Chinese characters display correctly)
            [System.IO.File]::AppendAllText($logFile, $logEntry, $utf8NoBom)

        } catch {
            # If JSON parsing fails, log raw input
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "----- $timestamp -----`n$inputData`n`n"
            [System.IO.File]::AppendAllText($logFile, $logEntry, $utf8NoBom)
        }
    }

} catch {
    # Silently fail - don't block user input
    # Optionally log error for debugging
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $errorLog = "----- $timestamp [ERROR] -----`n$($_.Exception.Message)`n`n"
    [System.IO.File]::AppendAllText($logFile, $errorLog, $utf8NoBom)
}

# Always exit successfully
exit 0
