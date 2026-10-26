param([switch]$SkipBuild, [string]$OutputDirectory = 'work/competitor-algorithm-tests')
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskOutput = Join-Path $taskRoot $OutputDirectory
New-Item -ItemType Directory -Force -Path $taskOutput | Out-Null
$taskEditor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
if (-not $SkipBuild) {
    $taskSourceHashes = @{}
    $taskSnapshot = Join-Path $taskOutput 'tested-runtime-sources'
    New-Item -ItemType Directory -Force -Path $taskSnapshot | Out-Null
    foreach ($taskSource in (Get-ChildItem -LiteralPath (Join-Path $taskRoot 'unity/Assets/Scripts') -Filter '*.cs')) {
        $taskSourceHashes[$taskSource.Name] = (Get-FileHash -LiteralPath $taskSource.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        Copy-Item -LiteralPath $taskSource.FullName -Destination (Join-Path $taskSnapshot $taskSource.Name) -Force
    }
    Copy-Item -LiteralPath (Join-Path $taskRoot 'unity/Assets/Resources/Data/pile-algorithms.json') -Destination $taskSnapshot -Force
    Copy-Item -LiteralPath (Join-Path $taskRoot 'unity/Assets/Resources/Data/level-tuning.json') -Destination $taskSnapshot -Force
    Copy-Item -LiteralPath (Join-Path $taskRoot 'unity/Assets/Resources/Data/core-rounds.json') -Destination $taskSnapshot -Force
    $taskArguments = @('-batchmode','-nographics','-quit','-projectPath',("`"$taskRoot/unity`""),
        '-executeMethod','CatchGoose.Editor.GooseAlgorithmBuild.Build','-logFile',("`"$taskOutput/unity-build.log`""))
    $taskBuild = Start-Process -FilePath $taskEditor -ArgumentList $taskArguments -PassThru -Wait -WindowStyle Hidden
    if ($taskBuild.ExitCode -ne 0) { throw "Algorithm QA build failed: $($taskBuild.ExitCode)" }
    foreach ($taskSourceName in $taskSourceHashes.Keys) {
        $taskCurrentHash = (Get-FileHash -LiteralPath (Join-Path $taskRoot "unity/Assets/Scripts/$taskSourceName") -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($taskCurrentHash -ne $taskSourceHashes[$taskSourceName]) { throw "Source changed during algorithm build: $taskSourceName; rebuild after concurrent edits finish" }
    }
    $taskSourceHashes | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskOutput 'tested-source-hashes.json') -Encoding utf8
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
