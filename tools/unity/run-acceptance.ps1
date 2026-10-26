param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $SkipBuild) { & (Join-Path $PSScriptRoot 'open-project.ps1') -Qa }
$player = Join-Path $taskRoot 'projects/catch-big-goose-unity/Builds/WindowsQA/CatchGooseQA.exe'
$output = Join-Path $taskRoot 'work/unity-migration/acceptance'
if (-not (Test-Path -LiteralPath $player)) { throw "QA player missing: $player" }
New-Item -ItemType Directory -Force -Path $output | Out-Null
$reportPath = Join-Path $output 'acceptance.json'
Set-GooseLocalPlayerConnection -PlayerPath $player
if (Test-Path -LiteralPath $reportPath) { Move-Item -LiteralPath $reportPath -Destination (Join-Path $output ('acceptance-previous-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.json')) }
$p = Start-Process -FilePath $player -ArgumentList @('-gooseQa', '-gooseQaOutput', ('"' + $output + '"'), '-logFile', ('"' + (Join-Path $output 'player.log') + '"')) -PassThru
if (-not $p.WaitForExit(300000)) { throw 'QA player exceeded five minutes; inspect the game and player.log.' }
if (-not (Test-Path -LiteralPath $reportPath)) { throw "QA did not create its report; player exit code: $($p.ExitCode)" }
$report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
if ($p.ExitCode -ne 0 -or -not $report.passed) { throw "QA failed with $($report.errors.Count) errors. See $reportPath" }
Write-Output "Unity $($report.unityVersion): $($report.checks.Count) runtime checks passed. Report: $reportPath"
