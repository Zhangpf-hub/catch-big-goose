param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskOutput = Join-Path $taskRoot 'work/competitor-algorithm-tests'
New-Item -ItemType Directory -Force -Path $taskOutput | Out-Null
$taskEditor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
if (-not $SkipBuild) {
    $taskArguments = @('-batchmode','-nographics','-quit','-projectPath',("`"$taskRoot/unity`""),
        '-executeMethod','CatchGoose.Editor.GooseAlgorithmBuild.Build','-logFile',("`"$taskOutput/unity-build.log`""))
    $taskBuild = Start-Process -FilePath $taskEditor -ArgumentList $taskArguments -PassThru -Wait -WindowStyle Hidden
    if ($taskBuild.ExitCode -ne 0) { throw "Algorithm QA build failed: $($taskBuild.ExitCode)" }
}
$taskPlayer = Join-Path $taskRoot 'unity/Builds/AlgorithmQA/CatchGooseAlgorithmQA.exe'
$taskReport = Join-Path $taskOutput 'algorithm-acceptance.json'
if (Test-Path -LiteralPath $taskReport) {
    Move-Item -LiteralPath $taskReport -Destination (Join-Path $taskOutput ('algorithm-previous-' + [guid]::NewGuid().ToString('N') + '.json'))
}
$taskArguments = @('-batchmode','-nographics','-gooseAlgorithmQa','-gooseAlgorithmOutput',("`"$taskOutput`""),'-logFile',("`"$taskOutput/algorithm-player.log`""))
$taskRun = Start-Process -FilePath $taskPlayer -ArgumentList $taskArguments -PassThru -Wait -WindowStyle Hidden
if (-not (Test-Path -LiteralPath $taskReport)) { throw "Algorithm QA produced no report; exit: $($taskRun.ExitCode)" }
$taskResult = Get-Content -LiteralPath $taskReport -Raw | ConvertFrom-Json
if ($taskRun.ExitCode -ne 0 -or -not $taskResult.passed) { throw "Algorithm QA failed with $($taskResult.errors.Count) errors; see $taskReport" }
Write-Output "Unity $($taskResult.unityVersion): $($taskResult.checks.Count) algorithm runtime checks passed"
