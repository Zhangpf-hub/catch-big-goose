$ErrorActionPreference='Stop'
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path $taskRoot 'work/two-stage-20261025'
$taskFrozen=Join-Path $taskWork 'frozen-project/unity'
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
function Invoke-FrozenProcess($file,$arguments){
    $quoted=($arguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $process=Start-Process -FilePath $file -ArgumentList $quoted -PassThru -WindowStyle Hidden
    $process.WaitForExit();if($process.ExitCode -ne 0){throw "Frozen process failed ($($process.ExitCode)): $file"}
}
# A separately launched initial import/validation build owns this isolated project.
while(Get-CimInstance Win32_Process -Filter "Name='Unity.exe'" | Where-Object {$_.CommandLine.Contains($taskFrozen.Replace('\','/')) -or $_.CommandLine.Contains($taskFrozen)}){Start-Sleep -Seconds 2}
if(-not(Test-Path (Join-Path $taskFrozen 'Builds/StoryFinalQA/CatchGoose.exe'))){throw 'Frozen validation build missing'}
Invoke-FrozenProcess $taskEditor @('-batchmode','-nographics','-quit','-buildTarget','StandaloneWindows64','-projectPath',$taskFrozen,'-executeMethod','CatchGoose.Editor.GooseStoryBuild.Release','-logFile',(Join-Path $taskWork 'frozen-release-build.log'))
Invoke-FrozenProcess $taskEditor @('-batchmode','-nographics','-quit','-buildTarget','WebGL','-projectPath',$taskFrozen,'-executeMethod','CatchGoose.Editor.GooseWeChatBuild.Build','-logFile',(Join-Path $taskWork 'frozen-wechat-build.log'))
Write-Output 'Frozen native release and WeChat export complete.'
