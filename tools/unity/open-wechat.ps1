$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskProject = Join-Path $taskRoot 'builds/catch-big-goose-wechat'
if (-not (Test-Path -LiteralPath (Join-Path $taskProject 'game.js'))) {
    throw 'WeChat package has not been built. Install WebGL support, then run tools/unity/build-wechat.ps1.'
}
$taskStart = New-Object System.Diagnostics.ProcessStartInfo
$taskStart.FileName = 'D:/开发/微信web开发者工具/node.exe'
$taskStart.Arguments = '"D:/开发/微信web开发者工具/cli.js" open --project "' + $taskProject + '" --lang zh'
$taskStart.UseShellExecute = $false
$taskStart.CreateNoWindow = $true
$taskStart.RedirectStandardOutput = $true
$taskStart.RedirectStandardError = $true
$taskCli = [System.Diagnostics.Process]::Start($taskStart)
$taskStdout = $taskCli.StandardOutput.ReadToEndAsync()
$taskStderr = $taskCli.StandardError.ReadToEndAsync()
$taskCli.WaitForExit()
$taskCliText = $taskStdout.GetAwaiter().GetResult() + $taskStderr.GetAwaiter().GetResult()
[System.IO.File]::WriteAllText((Join-Path $taskRoot 'work/wechat-integration/devtools-open.log'), $taskCliText, [System.Text.UTF8Encoding]::new($false))
Write-Output $taskCliText
if ($taskCli.ExitCode -ne 0 -or $taskCliText -match '\[error\]') { throw 'WeChat IDE did not confirm opening the project. Inspect its login/trust prompt and devtools-open.log.' }
