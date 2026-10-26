param([string]$AppId, [switch]$ConvertOnly)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskEditor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
$taskProject = Join-Path $taskRoot 'projects/catch-big-goose-unity'
$taskSettings = Join-Path $taskProject 'WeChatBuild.local.json'
$taskWechatCli = 'D:/开发/微信web开发者工具/cli.js'
if (Get-Process wechatdevtools -ErrorAction SilentlyContinue) {
    # The SDK writes templates before replacing AppID; close the exported project before it watches those files.
    $taskCloseStart = New-Object System.Diagnostics.ProcessStartInfo
    $taskCloseStart.FileName = 'D:/开发/微信web开发者工具/node.exe'
    $taskCloseStart.Arguments = '"' + $taskWechatCli + '" close --project "' + (Join-Path $taskRoot 'builds/catch-big-goose-wechat') + '" --lang zh'
    $taskCloseStart.UseShellExecute = $false
    $taskCloseStart.CreateNoWindow = $true
    $taskCloseStart.RedirectStandardOutput = $true
    $taskCloseStart.RedirectStandardError = $true
    $taskCloseProcess = [System.Diagnostics.Process]::Start($taskCloseStart)
    $taskCloseOut = $taskCloseProcess.StandardOutput.ReadToEndAsync()
    $taskCloseErr = $taskCloseProcess.StandardError.ReadToEndAsync()
    $taskCloseProcess.WaitForExit()
    $taskClose = $taskCloseOut.GetAwaiter().GetResult() + $taskCloseErr.GetAwaiter().GetResult()
    if ($taskCloseProcess.ExitCode -ne 0 -or $taskClose -match '\[error\]') {
        throw 'Close the catch-big-goose project in WeChat DevTools before building. The SDK emits temporary template files during conversion.'
    }
}
if (-not $ConvertOnly) {
    & 'C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' (Join-Path $PSScriptRoot 'subset_ui_font.py')
    if ($LASTEXITCODE -ne 0) { throw 'UI font preparation failed' }
}
if ($AppId) {
    if ($AppId -notmatch '^wx[0-9a-f]{16}$') { throw 'AppID must be your own registered mini-game AppID.' }
    $taskSettingsJson = @{appId=$AppId;development=$false} | ConvertTo-Json
    [System.IO.File]::WriteAllText($taskSettings, $taskSettingsJson, (New-Object System.Text.UTF8Encoding($false)))
}
$taskLog = Join-Path $taskRoot 'work/wechat-integration/unity-wechat-build.log'
$taskArguments = @('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','WebGL',
    '-executeMethod',$(if ($ConvertOnly) {'CatchGoose.Editor.GooseWeChatBuild.ConvertExisting'} else {'CatchGoose.Editor.GooseWeChatBuild.Build'}),'-quit','-logFile',$taskLog)
$taskQuoted = ($taskArguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
$taskBuild = Start-Process -FilePath $taskEditor -ArgumentList $taskQuoted -PassThru -WindowStyle Hidden
$taskBuild.WaitForExit()
if ($taskBuild.ExitCode -ne 0) { throw "WeChat build failed ($($taskBuild.ExitCode)). See $taskLog" }
Write-Output "WeChat build complete: $taskRoot/builds/catch-big-goose-wechat"
