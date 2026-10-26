param([switch]$ConvertOnly,[ValidatePattern('^[a-z0-9-]+$')][string]$WorkName='mobile-surface-performance-20261026',[ValidatePattern('^[a-z0-9-]+$')][string]$WorkspaceName='build-workspace')
$ErrorActionPreference='Stop'
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path (Join-Path $taskRoot 'work') $WorkName
$taskWorkspace=Join-Path $taskWork $WorkspaceName
$taskProject=Join-Path $taskWorkspace 'projects/catch-big-goose-unity'
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
if(-not (Test-Path -LiteralPath (Join-Path $taskProject 'Assets/Editor/GoosePlayerNetworkPolicy.cs'))){throw 'Build the isolated surface QA snapshot first'}
# Export only the tested snapshot. Live source changes in other chats are not
# copied into the middle of a validated build.
Copy-Item -LiteralPath (Join-Path $taskRoot 'projects/catch-big-goose-unity/WeChatBuild.local.json') -Destination $taskProject -Force
$taskMedia=Join-Path $taskWorkspace 'work/wechat-integration/media'
New-Item -ItemType Directory -Force -Path $taskMedia | Out-Null
Get-ChildItem -LiteralPath (Join-Path $taskRoot 'work/wechat-integration/media') -File | Copy-Item -Destination $taskMedia -Force
$taskTools=Join-Path $taskWorkspace 'tools/unity'
New-Item -ItemType Directory -Force -Path $taskTools | Out-Null
Copy-Item -LiteralPath (Join-Path $taskRoot 'tools/unity/compact-wechat-export.mjs') -Destination $taskTools -Force
# Node resolves esbuild by walking parents, reaching the real workspace's node_modules.
$taskLog=Join-Path $taskWork 'wechat-build.log'
$taskArgs=@('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','WebGL','-executeMethod',
    $(if($ConvertOnly){'CatchGoose.Editor.GooseWeChatBuild.ConvertExisting'}else{'CatchGoose.Editor.GooseWeChatBuild.Build'}),'-quit','-logFile',$taskLog)
$taskQuoted=($taskArgs | ForEach-Object {'"'+$_+'"'}) -join ' '
$taskProcess=Start-Process -FilePath $taskEditor -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -PassThru -Wait -WindowStyle Hidden
if($taskProcess.ExitCode -ne 0){throw "Isolated WeChat build failed: $($taskProcess.ExitCode); see $taskLog"}
Write-Output "Tested snapshot exported to $taskWorkspace/builds/catch-big-goose-wechat; publication is a separate hash-checked step."
