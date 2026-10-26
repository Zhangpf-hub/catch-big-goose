param(
    [ValidateSet('transition','visibility','reveal')][string]$Part='transition',
    [ValidateSet('natural','frozen')][string]$Mode='natural',
    [ValidateSet('sensor','manual')][string]$InputMode='sensor',
    [ValidateRange(0,4)][int]$Theme=0,
    [ValidateRange(0,3)][double]$Delay=0,
    [ValidateRange(20,60)][int]$Duration=30,
    [string]$BuildName='baseline', [string]$RunName='baseline',
    [switch]$SkipBuild, [switch]$SkipTests, [switch]$DesktopProfile, [switch]$DiagnoseContributors
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
foreach($taskName in @($BuildName,$RunName)){if($taskName -notmatch '^[a-z0-9-]+$'){throw 'Build and run names must be lowercase kebab-case'}}
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskPaths=Get-Content -LiteralPath (Join-Path $taskRoot 'workspace.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskSource=Join-Path $taskRoot $taskPaths.paths.unity
$taskWork=Join-Path $taskRoot 'work/stable-visibility-stage-two-20261026'
$taskWorkspace=Join-Path $taskWork 'build-workspace'
$taskProject=Join-Path $taskWorkspace $taskPaths.paths.unity
$taskBuild=Join-Path $taskWork $BuildName
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
function Get-StabilityInputs($taskDirectory){
    $taskMap=@{}
    foreach($taskFolder in @('Assets','Packages','ProjectSettings')){
        $taskFolderPath=Join-Path $taskDirectory $taskFolder
        Get-ChildItem -LiteralPath $taskFolderPath -File -Recurse -Force | ForEach-Object {
            $taskRelative=$_.FullName.Substring($taskDirectory.Length).TrimStart([char]92,[char]47).Replace([char]92,[char]47)
            $taskMap[$taskRelative]=@{bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
        }
    }
    return $taskMap
}
function Invoke-StabilityProcess($taskExecutable,$taskArguments,$taskLabel){
    $taskQuoted=($taskArguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskProcess=Start-Process -FilePath $taskExecutable -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -WindowStyle Hidden -Wait -PassThru
    if($taskProcess.ExitCode -ne 0){throw ($taskLabel+' failed ('+$taskProcess.ExitCode+'); evidence retained in '+$taskWork)}
}
if(-not $SkipBuild){
    if(Test-Path -LiteralPath (Join-Path $taskBuild 'player/catch-big-goose.exe')){throw 'Preserve this build; choose a new BuildName'}
    New-Item -ItemType Directory -Path $taskBuild -Force | Out-Null
    New-Item -ItemType Directory -Path $taskProject -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $taskRoot 'workspace.json') -Destination $taskWorkspace -Force
    foreach($taskFolder in @('Assets','Packages','ProjectSettings')){
        & robocopy (Join-Path $taskSource $taskFolder) (Join-Path $taskProject $taskFolder) /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if($LASTEXITCODE -gt 7){throw ('Snapshot copy failed: '+$taskFolder)}
    }
    if(-not (Test-Path -LiteralPath (Join-Path $taskProject 'Assets/Editor/GoosePlayerNetworkPolicy.cs'))){throw 'Local-only network build hook missing'}
    $taskOriginal=Get-StabilityInputs $taskSource
    $taskCopied=Get-StabilityInputs $taskProject
    if($taskOriginal.Count -ne $taskCopied.Count){throw 'Full input count differs'}
    foreach($taskKey in $taskOriginal.Keys){
        if($taskOriginal[$taskKey].sha256 -ne $taskCopied[$taskKey].sha256 -or $taskOriginal[$taskKey].bytes -ne $taskCopied[$taskKey].bytes){throw ('Snapshot differs: '+$taskKey)}
    }
    $taskOriginal | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskBuild 'source-inputs.json') -Encoding UTF8
    Write-Output ('Copied and verified '+$taskOriginal.Count+' source input files')
    if(-not $SkipTests){
        Invoke-StabilityProcess $taskEditor @('-batchmode','-projectPath',$taskProject,'-runTests','-testPlatform','editmode',
            '-testResults',(Join-Path $taskBuild 'editmode.xml'),'-logFile',(Join-Path $taskBuild 'editmode.log')) 'Editor tests'
    }
    Invoke-StabilityProcess $taskEditor @('-batchmode','-nographics','-projectPath',$taskProject,'-buildTarget','StandaloneWindows64',
        '-executeMethod','CatchGoose.Editor.GooseSurfaceBuild.Qa','-surfacePlayer',(Join-Path $taskBuild 'player/catch-big-goose.exe'),
        '-quit','-logFile',(Join-Path $taskBuild 'qa-build.log')) 'Native QA build'
    (Get-StabilityInputs $taskProject) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskBuild 'native-build-inputs.json') -Encoding UTF8
}
$taskPlayer=Join-Path $taskBuild 'player/catch-big-goose.exe'
Set-GooseLocalPlayerConnection -PlayerPath $taskPlayer
$taskDelay=([string]::Format([Globalization.CultureInfo]::InvariantCulture,'{0:0.###}',$Delay))
$taskCase=if($Part -eq 'visibility'){'visibility-'+$Mode+'-theme-'+$Theme}elseif($Part -eq 'reveal'){'reveal-theme-'+$Theme}else{'transition-'+$InputMode+'-theme-'+$Theme+'-delay-'+$taskDelay.Replace('.','p')}
if($DesktopProfile){$taskCase+='-desktop'}
$taskOutput=Join-Path $taskBuild ($taskCase+'-'+$RunName)
if(Test-Path -LiteralPath $taskOutput){throw 'Preserve existing run evidence; choose another RunName'}
New-Item -ItemType Directory -Path $taskOutput | Out-Null
if($Part -eq 'reveal' -and $DiagnoseContributors){
    foreach($taskPhase in @('initial','after-pick-1','after-pick-2','after-pick-3','after-toss')){
        New-Item -ItemType Directory -Path (Join-Path $taskOutput ($taskPhase+'-contributors')) | Out-Null
    }
}
$taskPlayerRoot=Split-Path $taskPlayer -Parent
$taskManifest=@(Get-ChildItem -LiteralPath $taskPlayerRoot -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    @{path=$_.FullName.Substring($taskPlayerRoot.Length).TrimStart([char]92,[char]47).Replace([char]92,[char]47);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
})
$taskManifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskOutput 'player-files.json') -Encoding UTF8
@{part=$Part;theme=$Theme;mode=$Mode;input=$InputMode;delay=$Delay;mobileProfile=(-not $DesktopProfile);build=$BuildName} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskOutput 'run-context.json') -Encoding UTF8
$taskFlag=if($Part -eq 'visibility'){'-gooseVisibilityQa'}else{'-gooseStageTwoQa'}
$taskArguments=@($taskFlag,'-gooseStabilityOutput',$taskOutput,'-gooseStabilityTheme',"$Theme",'-gooseStabilityMode',$Mode,
    '-gooseStabilityDuration',"$Duration",'-gooseStabilityDelay',$taskDelay,'-gooseStabilityInput',$InputMode,'-gooseShakeDiagnostics',
    '-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))
if($Part -eq 'reveal'){$taskArguments=@('-gooseRevealQa','-gooseRevealOutput',$taskOutput,'-gooseRevealTheme',"$Theme",'-gooseShakeDiagnostics','-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))}
if(-not $DesktopProfile){$taskArguments+='-gooseMobileProfile'}
if($DiagnoseContributors){$taskArguments+='-gooseVisibilityContributors'}
Invoke-StabilityProcess $taskPlayer $taskArguments 'Stability acceptance'
$taskReportFile=if($Part -eq 'visibility'){'visibility-stability.json'}elseif($Part -eq 'reveal'){'reveal-stability.json'}else{'stage-two-stability.json'}
$taskReport=Get-Content -LiteralPath (Join-Path $taskOutput $taskReportFile) -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $taskReport.completed -or -not $taskReport.passed -or $taskReport.errors.Count){throw 'Acceptance did not complete successfully; raw evidence retained'}
Write-Output ('Stability acceptance passed: '+$taskOutput)
