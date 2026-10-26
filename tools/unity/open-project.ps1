param([switch]$Build, [switch]$Qa, [switch]$Tests, [switch]$Prepare)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$editor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
if (-not (Test-Path -LiteralPath $editor)) { throw "Unity Editor missing: $editor" }
$project = Join-Path $taskRoot 'projects/catch-big-goose-unity'
$logs = Join-Path $taskRoot 'work/unity-migration'
New-Item -ItemType Directory -Force -Path $logs | Out-Null
if ($Build -or $Qa -or $Tests -or $Prepare) {
    $phase = if ($Tests) { 'tests' } elseif ($Prepare) { 'prepare' } elseif ($Qa) { 'qa-build' } else { 'build' }
    $arguments = @('-batchmode', '-nographics', '-projectPath', $project, '-logFile', (Join-Path $logs ("unity-$phase.log")))
    if ($Tests) { $arguments += @('-runTests', '-testPlatform', 'editmode', '-testResults', (Join-Path $logs 'editmode-results.xml')) }
    else { $arguments += @('-quit', '-executeMethod', $(if ($Prepare) { 'CatchGoose.Editor.GooseProjectSetup.Prepare' } elseif ($Qa) { 'CatchGoose.Editor.GooseProjectSetup.BuildQa' } else { 'CatchGoose.Editor.GooseProjectSetup.BuildWindows' })) }
    # Unity is a GUI executable: explicitly wait and read its own exit code.
    $quotedArguments = ($arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $process = Start-Process -FilePath $editor -ArgumentList $quotedArguments -PassThru -Wait -WindowStyle Hidden
    if ($process.ExitCode -ne 0) { throw "Unity command failed: $($process.ExitCode). See $logs/unity-$phase.log" }
} else {
    & (Join-Path $PSScriptRoot 'start-mcp.ps1')
    Start-Process -FilePath $editor -ArgumentList @('-projectPath', "`"$project`"", '-executeMethod', 'CatchGoose.Editor.GooseProjectSetup.OpenProject', '-logFile', "`"$(Join-Path $logs 'unity-editor.log')`"")
}
