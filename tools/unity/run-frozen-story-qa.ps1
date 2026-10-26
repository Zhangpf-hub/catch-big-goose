$ErrorActionPreference='Stop'
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path $taskRoot 'work/two-stage-20261025'
$taskFrozen=Join-Path $taskWork 'frozen-project'
$taskExe=Join-Path $taskFrozen 'unity/Builds/StoryFinalQA/CatchGoose.exe'
$taskSnapshot=Join-Path $taskFrozen 'work/two-stage-20261025/StoryFinalQA-sources.json'
while(-not(Test-Path (Join-Path $taskWork 'frozen-qa-isolation-ready.txt'))){Start-Sleep -Seconds 2}
function Start-FrozenQa($folder,$width,$height,$flags){
    $target=Join-Path $taskWork $folder;New-Item -ItemType Directory -Force -Path $target | Out-Null
    $arguments=@('-screen-width',"$width",'-screen-height',"$height",'-screen-fullscreen','0','-gooseMobileProfile','-storyOutput',$target,'-logFile',($target+'.log'))+$flags
    $quoted=($arguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    Start-Process -FilePath $taskExe -ArgumentList $quoted -PassThru -WindowStyle Hidden
}
function Wait-FrozenQa($process){$process.WaitForExit();if($process.ExitCode -ne 0){throw "Frozen QA failed: $($process.Id) ($($process.ExitCode))"}}
New-Item -ItemType Directory -Force -Path (Join-Path $taskWork 'frozen-playtest-final') | Out-Null
Copy-Item -LiteralPath $taskSnapshot -Destination (Join-Path $taskWork 'frozen-playtest-final/sources.json')
Wait-FrozenQa (Start-FrozenQa 'frozen-playtest-final' 390 844 @('-storyQa'))
Write-Output 'Frozen ten-round real runtime passed.'
Wait-FrozenQa (Start-FrozenQa 'frozen-flow' 390 844 @('-storyFlowQa'))
Wait-FrozenQa (Start-FrozenQa 'frozen-modal-layout' 390 844 @('-storyModalQa'))
$tasks=@((Start-FrozenQa 'frozen-layout-short' 360 640 @('-storyQa','-storyShotsOnly')),(Start-FrozenQa 'frozen-layout-tall' 430 932 @('-storyQa','-storyShotsOnly')),(Start-FrozenQa 'frozen-layout-safe' 390 844 @('-storyQa','-storyShotsOnly','-storySafeArea')))
foreach($task in $tasks){Wait-FrozenQa $task}
Write-Output 'Frozen flow, four popup layouts and three complete phone layouts passed.'
