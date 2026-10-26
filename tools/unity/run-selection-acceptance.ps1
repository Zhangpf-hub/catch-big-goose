param([switch]$SkipBuild,[switch]$SkipTests)
$ErrorActionPreference = 'Stop'
$selectionRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$selectionOutput = Join-Path $selectionRoot 'work/selection-highlight-20261025'
$selectionWorkspace = Join-Path $selectionOutput 'build-workspace'
$selectionProject = Join-Path $selectionWorkspace 'projects/catch-big-goose-unity'
$selectionEditor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
$selectionPlayer = Join-Path $selectionOutput 'player/catch-big-goose.exe'

function Invoke-SelectionProcess($File, $Arguments) {
    $quoted = ($Arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $process = Start-Process -FilePath $File -ArgumentList $quoted -PassThru -WindowStyle Hidden
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) { throw "Selection process failed ($($process.ExitCode)): $File" }
}

New-Item -ItemType Directory -Force -Path $selectionOutput | Out-Null
if (-not $SkipBuild) {
    $running = Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'Unity.exe' -and $_.CommandLine -like ('*' + $selectionProject + '*') }
    if ($running) { throw "Selection snapshot is already open in Unity: $selectionProject" }
    New-Item -ItemType Directory -Force -Path $selectionProject | Out-Null
    Copy-Item -LiteralPath (Join-Path $selectionRoot 'workspace.json') -Destination $selectionWorkspace -Force
    foreach ($folder in @('Assets','Packages','ProjectSettings')) {
        & robocopy (Join-Path $selectionRoot "projects/catch-big-goose-unity/$folder") (Join-Path $selectionProject $folder) /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -gt 7) { throw "Selection snapshot copy failed: $folder" }
    }
    # This copies GoosePlayerNetworkPolicy as part of Assets/Editor. Do not remove
    # it from an isolated QA project or enable remote profiling for routine tests.
    if (-not $SkipTests) {
        Invoke-SelectionProcess $selectionEditor @('-batchmode','-nographics','-projectPath',$selectionProject,'-buildTarget','StandaloneWindows64',
            '-runTests','-testPlatform','editmode','-testResults',(Join-Path $selectionOutput 'editmode-current.xml'),'-logFile',(Join-Path $selectionOutput 'editmode-current.log'))
    }
    Invoke-SelectionProcess $selectionEditor @('-batchmode','-nographics','-quit','-projectPath',$selectionProject,'-buildTarget','StandaloneWindows64',
        '-executeMethod','CatchGoose.Editor.GooseSelectionBuild.Qa','-selectionPlayer',$selectionPlayer,'-logFile',(Join-Path $selectionOutput 'qa-build-current.log'))
}
& (Join-Path $PSScriptRoot 'fix-player-network.ps1') -PlayerPath $selectionPlayer
$selectionNative = Join-Path $selectionOutput 'native-current'
New-Item -ItemType Directory -Force -Path $selectionNative | Out-Null
Invoke-SelectionProcess $selectionPlayer @('-gooseSelectionQa','-gooseMobileProfile','-selectionOutput',$selectionNative,
    '-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $selectionNative 'player.log'))
$selectionReport = Get-Content -Raw -LiteralPath (Join-Path $selectionNative 'acceptance.json') | ConvertFrom-Json
if (-not $selectionReport.passed) { throw 'Selection acceptance reported failures' }
$selectionInteraction = Join-Path $selectionOutput 'interaction-current'
New-Item -ItemType Directory -Force -Path $selectionInteraction | Out-Null
Invoke-SelectionProcess $selectionPlayer @('-gooseInteractionQa','-gooseMobileProfile','-gooseInteractionOutput',$selectionInteraction,
    '-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $selectionInteraction 'player.log'))
$selectionInteractionReport = Get-Content -Raw -LiteralPath (Join-Path $selectionInteraction 'interaction.json') | ConvertFrom-Json
if (-not $selectionInteractionReport.passed) { throw 'Interaction regression reported failures' }
Write-Output "Selection acceptance passed: $selectionNative/acceptance.json"
