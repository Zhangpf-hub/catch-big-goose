param([switch]$SkipBuild,[switch]$SkipTests,[ValidateSet('matrix','smoke','fixture','interrupt','clip')][string]$Part='matrix',[int]$Theme=-1,[int]$Stock=0,[string]$RunName='',[switch]$Release,[switch]$BuildWeChat)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskPaths=Get-Content -LiteralPath (Join-Path $taskRoot 'workspace.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskProject=Join-Path $taskRoot $taskPaths.paths.unity
$taskWork=Join-Path $taskRoot 'work/mobile-surface-performance-20261026'
$taskWorkspace=Join-Path $taskWork 'build-workspace'
$taskSourceProject=$taskProject
$taskProject=Join-Path $taskWorkspace $taskPaths.paths.unity
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
New-Item -ItemType Directory -Force -Path $taskWork | Out-Null
if(-not $SkipBuild) {
    New-Item -ItemType Directory -Force -Path $taskProject | Out-Null
    Copy-Item -LiteralPath (Join-Path $taskRoot 'workspace.json') -Destination $taskWorkspace -Force
    foreach($taskFolder in @('Assets','Packages','ProjectSettings')) {
        & robocopy (Join-Path $taskSourceProject $taskFolder) (Join-Path $taskProject $taskFolder) /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if($LASTEXITCODE -gt 7){throw "Surface snapshot copy failed: $taskFolder"}
    }
    if(-not (Test-Path -LiteralPath (Join-Path $taskProject 'Assets/Editor/GoosePlayerNetworkPolicy.cs'))){throw 'Local-only network build hook missing'}
}
function Invoke-SurfaceTask($taskExecutable,$taskArguments,$taskLabel) {
    $taskQuoted=($taskArguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskProcess=Start-Process -FilePath $taskExecutable -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -PassThru -Wait -WindowStyle Hidden
    if($taskProcess.ExitCode -ne 0){throw "$taskLabel failed ($($taskProcess.ExitCode)); see $taskWork"}
}
if(-not $SkipTests) {
    Invoke-SurfaceTask $taskEditor @('-batchmode','-nographics','-projectPath',$taskProject,'-runTests','-testPlatform','editmode',
        '-testResults',(Join-Path $taskWork 'editmode.xml'),'-logFile',(Join-Path $taskWork 'editmode.log')) 'Edit tests'
}
if(-not $SkipBuild) {
    Invoke-SurfaceTask $taskEditor @('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','StandaloneWindows64',
        '-executeMethod','CatchGoose.Editor.GooseSurfaceBuild.Qa','-surfacePlayer',(Join-Path $taskWork 'player/catch-big-goose.exe'),'-quit','-logFile',(Join-Path $taskWork 'qa-build.log')) 'QA build'
}
$taskPlayer=Join-Path $taskWork 'player/catch-big-goose.exe'
Set-GooseLocalPlayerConnection -PlayerPath $taskPlayer
$taskName=$Part+$(if($Theme -ge 0){'-'+$Theme}else{''})
if($Stock -gt 0){$taskName+='-stock-'+$Stock}
if($RunName){if($RunName -notmatch '^[a-z0-9-]+$'){throw 'RunName must use lowercase kebab-case'};$taskName+='-'+$RunName}
$taskOutput=Join-Path $taskWork $taskName
$taskArgs=@('-gooseSurfaceQa','-gooseSurfaceOutput',$taskOutput,'-gooseSurfacePart',$Part,'-gooseMobileProfile',
    '-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskWork ($taskName+'.log')))
if($Theme -ge 0){$taskArgs+=@('-gooseSurfaceTheme',"$Theme",'-gooseSurfaceThemeCount','1')}
if($Stock -gt 0){$taskArgs+=@('-gooseSurfaceStock',"$Stock")}
Invoke-SurfaceTask $taskPlayer $taskArgs 'Native surface acceptance'
if($Release) {
    Invoke-SurfaceTask $taskEditor @('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','StandaloneWindows64',
        '-executeMethod','CatchGoose.Editor.GooseSurfaceBuild.Release','-surfacePlayer',(Join-Path $taskWork 'release/catch-big-goose.exe'),'-quit','-logFile',(Join-Path $taskWork 'release-build.log')) 'Windows release'
}
if($BuildWeChat){& (Join-Path $PSScriptRoot 'build-surface-wechat.ps1');if($LASTEXITCODE -ne 0){throw 'WeChat build failed'}}
Write-Output "Surface performance acceptance complete: $taskOutput"
