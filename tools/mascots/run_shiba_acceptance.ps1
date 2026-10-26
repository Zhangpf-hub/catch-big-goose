param([switch]$Build)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot '../unity/player-network.ps1')
$shibaRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if($Build){
    $shibaLog=Join-Path $shibaRoot 'work/shiba-unity-build.log'
    $shibaProcess=Start-Process -FilePath 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe' -ArgumentList @('-batchmode','-nographics','-quit','-projectPath',('"'+(Join-Path $shibaRoot 'projects/catch-big-goose-unity')+'"'),'-executeMethod','CatchGoose.Editor.ShibaModelSetup.BuildReview','-logFile',('"'+$shibaLog+'"')) -WindowStyle Hidden -PassThru
    $shibaProcess.WaitForExit();if($shibaProcess.ExitCode -ne 0){throw "Build failed; see $shibaLog"}
}
$shibaOutput=Join-Path $shibaRoot ('source-assets/models/candidates/shiba-20261025-v1/qa/run-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
Set-GooseLocalPlayerConnection -PlayerPath (Join-Path $shibaRoot 'projects/catch-big-goose-unity/Builds/ShibaReview/ShibaReview.exe')
New-Item -ItemType Directory -Path $shibaOutput | Out-Null
$shibaProcess=Start-Process -FilePath (Join-Path $shibaRoot 'projects/catch-big-goose-unity/Builds/ShibaReview/ShibaReview.exe') -ArgumentList @('-shibaQa','-gooseMobileProfile','-shibaOutput',('"'+$shibaOutput+'"'),'-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',('"'+(Join-Path $shibaOutput 'player.log')+'"')) -WindowStyle Hidden -PassThru
if(-not $shibaProcess.WaitForExit(150000)){throw "Acceptance timed out; see $shibaOutput"}
$shibaReport=Get-Content -LiteralPath (Join-Path $shibaOutput 'acceptance.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $shibaReport.passed -or $shibaProcess.ExitCode -ne 0){throw "Acceptance failed; see $shibaOutput"}
Write-Output "Shiba acceptance passed: $($shibaReport.checks.Count) checks. $shibaOutput"
