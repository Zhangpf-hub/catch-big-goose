param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$sizeRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$sizeOutput = Join-Path $sizeRoot 'work/model-size-20261026'
$sizeWorkspace = Join-Path $sizeOutput 'build-workspace'
$sizeProject = Join-Path $sizeWorkspace 'projects/catch-big-goose-unity'
$sizePlayer = Join-Path $sizeOutput 'player/catch-big-goose.exe'
$sizeEditor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
function Invoke-SizeProcess($File, $Arguments) {
    $quoted = ($Arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $process = Start-Process -FilePath $File -ArgumentList $quoted -PassThru -WindowStyle Hidden
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) { throw "Model size process failed ($($process.ExitCode)): $File" }
}
New-Item -ItemType Directory -Force -Path $sizeProject | Out-Null
if (-not $SkipBuild) {
    Copy-Item -LiteralPath (Join-Path $sizeRoot 'workspace.json') -Destination $sizeWorkspace -Force
    foreach ($folder in @('Assets','Packages','ProjectSettings')) {
        & robocopy (Join-Path $sizeRoot "projects/catch-big-goose-unity/$folder") (Join-Path $sizeProject $folder) /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -gt 7) { throw "Size snapshot copy failed: $folder" }
    }
    # Assets/Editor includes GoosePlayerNetworkPolicy. QA never enables LAN profiling.
    Invoke-SizeProcess $sizeEditor @('-batchmode','-nographics','-projectPath',$sizeProject,'-buildTarget','StandaloneWindows64',
        '-runTests','-testPlatform','editmode','-testResults',(Join-Path $sizeOutput 'editmode.xml'),'-logFile',(Join-Path $sizeOutput 'editmode.log'))
    Invoke-SizeProcess $sizeEditor @('-batchmode','-nographics','-quit','-projectPath',$sizeProject,'-buildTarget','StandaloneWindows64',
        '-executeMethod','CatchGoose.Editor.GooseSelectionBuild.Qa','-selectionPlayer',$sizePlayer,'-logFile',(Join-Path $sizeOutput 'qa-build.log'))
}
& (Join-Path $PSScriptRoot 'fix-player-network.ps1') -PlayerPath $sizePlayer
foreach ($resolution in @(@(390,844),@(563,1000))) {
    $native = Join-Path $sizeOutput ("native-" + $resolution[0])
    New-Item -ItemType Directory -Force -Path $native | Out-Null
    Invoke-SizeProcess $sizePlayer @('-gooseModelSizeQa','-gooseMobileProfile','-gooseSizeOutput',$native,
        '-screen-width',[string]$resolution[0],'-screen-height',[string]$resolution[1],'-screen-fullscreen','0','-logFile',(Join-Path $native 'player.log'))
    if (-not (Get-Content -Raw -LiteralPath (Join-Path $native 'acceptance.json') | ConvertFrom-Json).passed) { throw "Size acceptance failed: $native" }
}
Write-Output "Model size acceptance passed: $sizeOutput"
