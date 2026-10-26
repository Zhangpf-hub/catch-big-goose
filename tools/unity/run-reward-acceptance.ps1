param([switch]$SkipBuild,[string]$ProjectDirectory='projects/catch-big-goose-unity',[string]$OutputDirectory='work/video-rewards-20261025/recheck')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskProject=[IO.Path]::GetFullPath((Join-Path $taskRoot $ProjectDirectory))
$taskOutput=[IO.Path]::GetFullPath((Join-Path $taskRoot $OutputDirectory))
New-Item -ItemType Directory -Path $taskOutput -Force | Out-Null
function Invoke-RewardProcess($file,$arguments){
    $quoted=($arguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $process=Start-Process -FilePath $file -ArgumentList $quoted -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru -Wait
    if($process.ExitCode -ne 0){throw "Video reward process failed ($($process.ExitCode)): $file"}
}
if(-not $SkipBuild){
    & python (Join-Path $PSScriptRoot 'subset_ui_font.py')
    if($LASTEXITCODE -ne 0){throw 'Font preparation failed'}
    $taskEditor=Join-Path (Split-Path $taskRoot -Parent) 'tools/unity/2022.3.62f3/Editor/Unity.exe'
    Invoke-RewardProcess $taskEditor @('-batchmode','-nographics','-quit','-projectPath',$taskProject,'-buildTarget','StandaloneWindows64','-executeMethod','CatchGoose.Editor.GooseRewardBuild.Qa','-logFile',(Join-Path $taskOutput 'build.log'))
}
$taskExe=Join-Path $taskProject 'Builds/VideoRewardsQA/catch-big-goose.exe'
Set-GooseLocalPlayerConnection -PlayerPath $taskExe
Invoke-RewardProcess $taskExe @('-gooseRewardQa','-gooseMobileProfile','-rewardOutput',$taskOutput,'-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))
& python (Join-Path $PSScriptRoot 'encode-reward-demos.py') $taskOutput
if($LASTEXITCODE -ne 0){throw 'Demo encoding failed'}
Write-Output "Video rewards passed: $taskOutput/acceptance.json"
