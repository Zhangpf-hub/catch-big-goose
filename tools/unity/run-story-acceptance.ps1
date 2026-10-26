param([switch]$SkipBuild,[switch]$ShotsOnly,[string]$OutputDirectory='work/two-stage-20261025/recheck')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
function Invoke-StoryProcess($file,$arguments){
    if ([IO.Path]::GetFileName($file) -ne 'Unity.exe') { Set-GooseLocalPlayerConnection -PlayerPath $file }
    $quoted=($arguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $process=Start-Process -FilePath $file -ArgumentList $quoted -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru
    $process.WaitForExit();if($process.ExitCode -ne 0){throw "Story acceptance process failed: $file ($($process.ExitCode))"}
}
$taskOutput=Join-Path $taskRoot $OutputDirectory
New-Item -ItemType Directory -Force -Path $taskOutput | Out-Null
if(-not $SkipBuild){
    & 'C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' (Join-Path $PSScriptRoot 'subset_ui_font.py')
    if($LASTEXITCODE -ne 0){throw 'Font subset failed'}
    Invoke-StoryProcess $taskEditor @('-batchmode','-nographics','-quit','-projectPath',(Join-Path $taskRoot 'projects/catch-big-goose-unity'),'-buildTarget','StandaloneWindows64','-executeMethod','CatchGoose.Editor.GooseStoryBuild.Preview','-logFile',(Join-Path $taskOutput 'build.log'))
}
$taskArguments=@('-storyQa','-gooseMobileProfile','-storyOutput',$taskOutput,'-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))
if($ShotsOnly){$taskArguments+='-storyShotsOnly'}
Invoke-StoryProcess (Join-Path $taskRoot 'projects/catch-big-goose-unity/Builds/StoryPreview/CatchGoose.exe') $taskArguments
Write-Output "Two-stage acceptance passed: $taskOutput/story-acceptance.json"
