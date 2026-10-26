param([string]$RunName='release-shake6')
$ErrorActionPreference='Stop'
if($RunName -notmatch '^[a-z0-9-]+$'){throw 'RunName must use lowercase kebab-case'}
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path $taskRoot 'work/mobile-surface-performance-20261026'
$taskPlayer=Join-Path $taskWork 'player/catch-big-goose.exe'
$taskPlayerRoot=Split-Path $taskPlayer -Parent
Set-GooseLocalPlayerConnection -PlayerPath $taskPlayer
$taskIdentity=@(Get-ChildItem -LiteralPath $taskPlayerRoot -File -Recurse | Sort-Object FullName | ForEach-Object {
    @{path=$_.FullName.Substring($taskPlayerRoot.Length).TrimStart([char]92,[char]47).Replace([char]92,[char]47);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
})
foreach($taskCase in @(
    @{name='interaction';flag='-gooseInteractionQa';output='-gooseInteractionOutput';report='interaction.json';minimum=61},
    @{name='selection';flag='-gooseSelectionQa';output='-selectionOutput';report='acceptance.json';minimum=122}
)) {
    $taskOutput=Join-Path $taskWork ($taskCase.name+'-'+$RunName)
    if(Test-Path -LiteralPath $taskOutput){throw "Preserve existing regression evidence: $taskOutput"}
    New-Item -ItemType Directory -Path $taskOutput | Out-Null
    $taskIdentity|ConvertTo-Json -Depth 4|Set-Content -LiteralPath (Join-Path $taskOutput 'player-files.json') -Encoding UTF8
    $taskArgs=@($taskCase.flag,'-gooseMobileProfile',$taskCase.output,$taskOutput,'-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))
    $taskQuoted=($taskArgs|ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskProcess=Start-Process -FilePath $taskPlayer -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru -Wait
    if($taskProcess.ExitCode -ne 0){throw "$($taskCase.name) failed ($($taskProcess.ExitCode)); see $taskOutput"}
    $taskReport=Get-Content -LiteralPath (Join-Path $taskOutput $taskCase.report) -Raw -Encoding UTF8|ConvertFrom-Json
    if(-not $taskReport.passed -or $taskReport.errors.Count -gt 0 -or $taskReport.checks.Count -lt $taskCase.minimum){throw "$($taskCase.name) regression incomplete or failed"}
    Write-Output "$($taskCase.name) regression passed: $($taskReport.checks.Count) checks"
}
