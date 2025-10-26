# User Input Logger for Claude Code
# 记录用户的所有对话输入，用于后续分析和优化对话方式

param()

$ErrorActionPreference = "SilentlyContinue"

# 设置控制台编码为 UTF-8，确保中文正确处理
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$logFile = Join-Path $PSScriptRoot "user-inputs.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try {
    # 读取所有 stdin 输入
    $inputLines = @()
    while ($null -ne ($line = [Console]::ReadLine())) {
        $inputLines += $line
    }
    $inputData = $inputLines -join "`n"

    # 提取用户输入内容
    $userMessage = ""

    if (-not [string]::IsNullOrWhiteSpace($inputData)) {
        try {
            $json = $inputData | ConvertFrom-Json

            # 尝试提取用户消息
            if ($json.prompt) {
                $userMessage = $json.prompt
            } elseif ($json.message) {
                $userMessage = $json.message
            } elseif ($json.text) {
                $userMessage = $json.text
            } elseif ($json.content) {
                $userMessage = $json.content
            } else {
                # 如果没有找到明确字段，使用整个 JSON
                $userMessage = $inputData
            }
        } catch {
            # JSON 解析失败，使用原始输入
            $userMessage = $inputData
        }
    } else {
        $userMessage = "[空消息]"
    }

    # 构建日志条目（格式：箭头 + 时间戳 + 用户输入）
    $logEntry = "`n→ $timestamp`n$userMessage"

    # 使用 UTF8 编码写入日志文件（无 BOM，避免乱码）
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::AppendAllText($logFile, $logEntry, $utf8NoBom)

} catch {
    # 静默失败 - 不要阻塞对话
    try {
        $errorLog = "`n[$timestamp] [错误] $($_.Exception.Message)"
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::AppendAllText($logFile, $errorLog, $utf8NoBom)
    } catch {
        # 完全静默
    }
}

# 总是成功退出
exit 0
