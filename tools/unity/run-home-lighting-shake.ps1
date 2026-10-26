param([switch]$SkipModels,[switch]$SkipBuild,[switch]$BuildWeChat)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskPaths=Get-Content -LiteralPath (Join-Path $taskRoot 'workspace.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskProject=Join-Path $taskRoot $taskPaths.paths.unity
$taskWork=Join-Path $taskRoot 'work/home-lighting-shake-pipeline'
$taskPython='C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
New-Item -ItemType Directory -Force -Path $taskWork | Out-Null
function Invoke-HomeTask($taskFile,$taskArguments,$taskName){
    if([IO.Path]::GetExtension($taskFile) -eq '.exe' -and [IO.Path]::GetFileName($taskFile) -eq 'catch-big-goose.exe'){Set-GooseLocalPlayerConnection -PlayerPath $taskFile}
    $taskQuoted=($taskArguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskProcess=Start-Process $taskFile -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $taskWork ($taskName+'.out.log')) -RedirectStandardError (Join-Path $taskWork ($taskName+'.err.log'))
    if($taskProcess.ExitCode -ne 0){throw "$taskName failed; see $taskWork"}
}
Push-Location $taskRoot
try{
    if(-not $SkipModels){
        foreach($taskScript in @('build_home_table.py','build_round_surfaces.py')){Invoke-HomeTask 'D:/开发/tools/blender/blender-4.5.14-windows-x64/blender.exe' @('--background','--factory-startup','--python-exit-code','1','--python',(Join-Path $PSScriptRoot $taskScript)) $taskScript}
        foreach($taskScript in @('stage_home_table.py','stage_round_surfaces.py')){& $taskPython (Join-Path $PSScriptRoot $taskScript);if($LASTEXITCODE -ne 0){throw $taskScript}}
    }
    if(-not $SkipBuild){
        & $taskPython (Join-Path $PSScriptRoot 'subset_ui_font.py');if($LASTEXITCODE -ne 0){throw 'Font preparation failed'}
        Invoke-HomeTask $taskEditor @('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','StandaloneWindows64','-executeMethod','CatchGoose.Editor.GooseHomeShakeBuild.Deliver','-quit','-logFile',(Join-Path $taskWork 'build.log')) 'build'
    }
    $taskPlayer=Join-Path $taskProject 'Builds/home-lighting-shake-qa/catch-big-goose.exe'
    foreach($taskPart in @('home','shake')){
        Invoke-HomeTask $taskPlayer @('-gooseHomeShakeQa','-gooseHomeShakePart',$taskPart,'-gooseHomeShakeOutput',(Join-Path $taskWork $taskPart),'-gooseMobileProfile','-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskWork ($taskPart+'.log'))) $taskPart
    }
    if($BuildWeChat){& (Join-Path $PSScriptRoot 'build-wechat.ps1');& $taskPython (Join-Path $PSScriptRoot 'audit-wechat-package.py');if($LASTEXITCODE -ne 0){throw 'WeChat package audit failed'}}
    Write-Output "Home lighting and surface-shake pipeline passed: $taskWork"
}finally{Pop-Location}
