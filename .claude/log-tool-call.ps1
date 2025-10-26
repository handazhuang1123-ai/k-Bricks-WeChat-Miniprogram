# Tool Call Logger for Claude Code
# Records every tool invocation with timestamp and parameters

param()

$ErrorActionPreference = "SilentlyContinue"
$logFile = Join-Path $PSScriptRoot "tool-calls.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try {
    # Read all stdin input
    $inputLines = @()
    while ($null -ne ($line = [Console]::ReadLine())) {
        $inputLines += $line
    }
    $inputData = $inputLines -join "`n"

    # Extract tool name and params
    $toolName = "UNKNOWN"
    $params = ""

    if (-not [string]::IsNullOrWhiteSpace($inputData)) {
        try {
            $json = $inputData | ConvertFrom-Json

            if ($json.tool_name) {
                $toolName = $json.tool_name
            }

            # Get tool input (parameters)
            $paramObj = $null
            if ($json.tool_input) {
                $paramObj = $json.tool_input
            } elseif ($json.parameters) {
                $paramObj = $json.parameters
            } elseif ($json.params) {
                $paramObj = $json.params
            } elseif ($json.input) {
                $paramObj = $json.input
            }

            if ($paramObj) {
                $paramsJson = $paramObj | ConvertTo-Json -Compress -Depth 3
                $maxLength = [Math]::Min(200, $paramsJson.Length)
                $params = $paramsJson.Substring(0, $maxLength)
                if ($paramsJson.Length -gt 200) {
                    $params += "..."
                }
            } else {
                # No params found
                $params = "[No params]"
            }
        } catch {
            # JSON parse error, try to extract basic info from raw input
            if ($inputData -match '"tool_name"\s*:\s*"([^"]+)"') {
                $toolName = $matches[1]
            }
            if ($inputData.Length -lt 300) {
                $params = "[Raw: $inputData]"
            } else {
                $params = "[Raw: " + $inputData.Substring(0, 150) + "...]"
            }
        }
    } else {
        # No input received
        $params = "[No stdin data]"
    }

    # Build log entry
    $logEntry = "$timestamp | Tool: $toolName | Params: $params"

    # Write to log
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue

} catch {
    # Silently fail - don't block tool execution
    # Optionally log error for debugging
    $errorLog = "$timestamp | ERROR | $($_.Exception.Message)"
    Add-Content -Path $logFile -Value $errorLog -Encoding UTF8 -ErrorAction SilentlyContinue
}

# Always exit successfully
exit 0
