param([switch]$SkipBuild, [string]$OutputDirectory = 'work/ui-mobile-20261024/final', [switch]$MobileProfile)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$uiRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $SkipBuild) {
    & 'C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' (Join-Path $PSScriptRoot 'subset_ui_font.py')
    if ($LASTEXITCODE -ne 0) { throw 'UI font subset failed' }
    & (Join-Path $PSScriptRoot 'open-project.ps1') -Qa
}
$uiPlayer = Join-Path $uiRoot 'projects/catch-big-goose-unity/Builds/WindowsQA/CatchGooseQA.exe'
$uiOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { $OutputDirectory } else { Join-Path $uiRoot $OutputDirectory }
New-Item -ItemType Directory -Force $uiOutput | Out-Null
$uiReportPath = Join-Path $uiOutput 'ui-acceptance.json'
Set-GooseLocalPlayerConnection -PlayerPath $uiPlayer
if (Test-Path -LiteralPath $uiReportPath) {
    Move-Item -LiteralPath $uiReportPath -Destination (Join-Path $uiOutput ('ui-acceptance-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.json'))
}
$uiArguments = @('-gooseUiQa','-gooseUiOutput',('"'+$uiOutput+'"'),'-logFile',('"'+(Join-Path $uiOutput 'player.log')+'"'),'-screen-fullscreen','0')
if ($MobileProfile) { $uiArguments += '-gooseMobileProfile' }
$uiProcess = Start-Process -FilePath $uiPlayer -ArgumentList $uiArguments -WindowStyle Hidden -PassThru
if (-not $uiProcess.WaitForExit(240000)) { throw 'UI QA exceeded four minutes; inspect player.log.' }
if (-not (Test-Path -LiteralPath $uiReportPath)) { throw 'UI QA report missing' }
$uiReport = Get-Content -LiteralPath $uiReportPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($uiProcess.ExitCode -ne 0 -or -not $uiReport.passed) { throw "UI QA failed: $($uiReport.errors.Count) errors. See $uiReportPath" }
Write-Output "UI QA passed: $($uiReport.checks.Count) checks. $uiReportPath"
