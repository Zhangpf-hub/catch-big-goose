param([switch]$Build)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot '../unity/player-network.ps1')
$giraffeRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if($Build){
    $giraffeLog=Join-Path $giraffeRoot 'work/giraffe-unity-build.log'
    $giraffeProcess=Start-Process -FilePath 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe' -ArgumentList @('-batchmode','-nographics','-quit','-projectPath',('"'+(Join-Path $giraffeRoot 'projects/catch-big-goose-unity')+'"'),'-executeMethod','CatchGoose.Editor.GiraffeModelSetup.BuildReview','-logFile',('"'+$giraffeLog+'"')) -WindowStyle Hidden -PassThru
    $giraffeProcess.WaitForExit();if($giraffeProcess.ExitCode -ne 0){throw "Build failed; see $giraffeLog"}
}
$giraffeOutput=Join-Path $giraffeRoot ('source-assets/models/candidates/giraffe-b-20261024-v1/qa/run-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
Set-GooseLocalPlayerConnection -PlayerPath (Join-Path $giraffeRoot 'projects/catch-big-goose-unity/Builds/GiraffeReview/GiraffeReview.exe')
New-Item -ItemType Directory -Path $giraffeOutput | Out-Null
$giraffeProcess=Start-Process -FilePath (Join-Path $giraffeRoot 'projects/catch-big-goose-unity/Builds/GiraffeReview/GiraffeReview.exe') -ArgumentList @('-giraffeQa','-gooseMobileProfile','-giraffeOutput',('"'+$giraffeOutput+'"'),'-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',('"'+(Join-Path $giraffeOutput 'player.log')+'"')) -WindowStyle Hidden -PassThru
if(-not $giraffeProcess.WaitForExit(150000)){throw "Acceptance timed out; see $giraffeOutput"}
$giraffeReport=Get-Content -LiteralPath (Join-Path $giraffeOutput 'acceptance.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $giraffeReport.passed -or $giraffeProcess.ExitCode -ne 0){throw "Acceptance failed; see $giraffeOutput"}
Write-Output "Giraffe acceptance passed: $($giraffeReport.checks.Count) checks. $giraffeOutput"
