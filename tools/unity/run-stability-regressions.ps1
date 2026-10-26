[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidatePattern('^[a-z0-9]+(?:-[a-z0-9]+)*$')][string]$BuildName,
    [Parameter(Mandatory=$true)][ValidatePattern('^[a-z0-9]+(?:-[a-z0-9]+)*$')][string]$RunName,
    [ValidateSet('matrix','fallback','interrupt','toss','clip','interaction','selection','single-rotation')][string]$Part='matrix',
    [ValidateRange(-1,4)][int]$Theme=-1,
    [ValidateRange(0,300)][int]$Stock=0,
    [ValidateRange(30,7200)][int]$TimeoutSeconds=1800,
    [switch]$DesktopProfile,
    [switch]$DescribeOnly
)
$ErrorActionPreference='Stop'
foreach($taskName in @($BuildName,$RunName)){
    if($taskName -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$'){throw 'BuildName and RunName must use lowercase kebab-case'}
}
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path $taskRoot 'work/stable-visibility-stage-two-20261026'
$taskBuild=Join-Path $taskWork $BuildName
$taskPlayerRoot=Join-Path $taskBuild 'player'
$taskPlayer=Join-Path $taskPlayerRoot 'catch-big-goose.exe'
if(-not (Test-Path -LiteralPath $taskPlayer -PathType Leaf)){throw "Fixed player missing: $taskPlayer"}
$taskPlayer=(Resolve-Path -LiteralPath $taskPlayer).Path
$taskPlayerRoot=Split-Path $taskPlayer -Parent
if($Part -in @('interaction','selection') -and ($PSBoundParameters.ContainsKey('Theme') -or $PSBoundParameters.ContainsKey('Stock'))){
    throw 'Interaction and selection use their own scenarios; Theme/Stock would be misleading.'
}
if($Part -in @('fallback','clip','toss') -and $Theme -lt 0){$Theme=0}
if($Part -eq 'single-rotation' -and $Theme -lt 0){$Theme=3}
$taskCase='regression-'+$Part
if($Theme -ge 0){$taskCase+='-theme-'+$Theme}
if($Stock -gt 0){$taskCase+='-stock-'+$Stock}
if($DesktopProfile){$taskCase+='-desktop'}
$taskOutput=Join-Path $taskBuild ($taskCase+'-'+$RunName)
if(Test-Path -LiteralPath $taskOutput){throw "Preserve existing evidence; choose a new RunName: $taskOutput"}

# A fixed build is input evidence: validate its network hook without rewriting it.
# Repair old mutable copies separately with fix-player-network.ps1 before capture.
$taskBoot=Join-Path $taskPlayerRoot 'catch-big-goose_Data/boot.config'
if(-not (Test-Path -LiteralPath $taskBoot -PathType Leaf)){throw "Player boot.config missing: $taskBoot"}
$taskBootText=[IO.File]::ReadAllText($taskBoot)
if($taskBootText -match '(?m)^player-connection-' -and $env:GOOSE_REMOTE_PROFILER -ne '1'){
    foreach($taskPair in @(
        @('mode','Listen'),@('multicast','0'),@('listen-address','127.0.0.1'),@('ip','127.0.0.1')
    )){
        $taskFound=[regex]::Matches($taskBootText,'(?m)^player-connection-'+$taskPair[0]+'=([^\r\n]*)')
        if($taskFound.Count -ne 1 -or $taskFound[0].Groups[1].Value -ne $taskPair[1]){
            throw 'Fixed player lacks local-only PlayerConnection. Preserve it; repair a mutable copy or choose a fresh policy-built player.'
        }
    }
}

$taskArguments=@('-screen-width','390','-screen-height','844','-screen-fullscreen','0','-logFile',(Join-Path $taskOutput 'player.log'))
if(-not $DesktopProfile){$taskArguments+='-gooseMobileProfile'}
$taskRequireCompleted=$true
$taskMinimumChecks=1
switch($Part){
    'interaction' {
        $taskArguments+=@('-gooseInteractionQa','-gooseInteractionOutput',$taskOutput)
        $taskReportName='interaction.json';$taskRequireCompleted=$false;$taskMinimumChecks=61
    }
    'selection' {
        $taskArguments+=@('-gooseSelectionQa','-selectionOutput',$taskOutput)
        $taskReportName='acceptance.json';$taskRequireCompleted=$false;$taskMinimumChecks=122
    }
    default {
        $taskArguments+=@('-gooseSurfaceQa','-gooseSurfaceOutput',$taskOutput,'-gooseSurfacePart',$Part)
        if($Theme -ge 0){$taskArguments+=@('-gooseSurfaceTheme',"$Theme",'-gooseSurfaceThemeCount','1')}
        if($Stock -gt 0){$taskArguments+=@('-gooseSurfaceStock',"$Stock")}
        $taskReportName='surface-acceptance.json'
    }
}
$taskContext=[ordered]@{
    build=$BuildName;run=$RunName;part=$Part;theme=$Theme;stock=$Stock
    mobileProfile=(-not $DesktopProfile);timeoutSeconds=$TimeoutSeconds
    player=$taskPlayer;output=$taskOutput;report=$taskReportName;arguments=$taskArguments
    scope='Fixed native player regression; synthetic input does not prove WeChat sensor or phone performance.'
}
if($DescribeOnly){$taskContext | ConvertTo-Json -Depth 6;return}

function Get-StabilityPlayerManifest {
    @(Get-ChildItem -LiteralPath $taskPlayerRoot -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
        [ordered]@{
            path=$_.FullName.Substring($taskPlayerRoot.Length).TrimStart([char]92,[char]47).Replace([char]92,[char]47)
            bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    })
}
function Test-StabilityManifestEqual($taskBefore,$taskAfter){
    if($taskBefore.Count -ne $taskAfter.Count){return $false}
    for($taskIndex=0;$taskIndex -lt $taskBefore.Count;$taskIndex++){
        foreach($taskKey in @('path','bytes','sha256')){
            if($taskBefore[$taskIndex][$taskKey] -cne $taskAfter[$taskIndex][$taskKey]){return $false}
        }
    }
    return $true
}

# Never overwrite an earlier run, even when its process failed or timed out.
New-Item -ItemType Directory -Path $taskOutput | Out-Null
$taskContext | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $taskOutput 'run-context.json') -Encoding UTF8
$taskBefore=@(Get-StabilityPlayerManifest)
$taskBefore | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskOutput 'player-files.json') -Encoding UTF8
$taskReceipt=[ordered]@{startedUtc=[DateTime]::UtcNow.ToString('o');completed=$false;passed=$false;exitCode=$null;timedOut=$false;playerUnchanged=$null;checks=0;failure=$null}
$taskProcess=$null
try {
    $taskQuoted=($taskArguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskProcess=Start-Process -FilePath $taskPlayer -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru
    $taskReceipt.processId=$taskProcess.Id
    $taskWatch=[Diagnostics.Stopwatch]::StartNew()
    while(-not $taskProcess.WaitForExit(1000)){
        if($taskWatch.Elapsed.TotalSeconds -gt $TimeoutSeconds){
            $taskReceipt.timedOut=$true
            Stop-Process -Id $taskProcess.Id -ErrorAction SilentlyContinue
            $taskProcess.WaitForExit()
            throw "Regression timed out; only this runner's player PID $($taskProcess.Id) was stopped."
        }
    }
    $taskProcess.Refresh();$taskReceipt.exitCode=$taskProcess.ExitCode
    if($taskProcess.ExitCode -ne 0){throw "Player failed with exit code $($taskProcess.ExitCode)"}
    $taskReportPath=Join-Path $taskOutput $taskReportName
    if(-not (Test-Path -LiteralPath $taskReportPath)){throw "Expected report missing: $taskReportName"}
    $taskReport=Get-Content -LiteralPath $taskReportPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if(-not $taskReport.passed -or @($taskReport.errors).Count -gt 0 -or @($taskReport.checks).Count -lt $taskMinimumChecks){
        throw "Incomplete or failed report: $taskReportName"
    }
    if($taskRequireCompleted -and -not $taskReport.completed){throw 'Surface report did not complete'}
    $taskReceipt.checks=@($taskReport.checks).Count
    $taskReceipt.completed=$true;$taskReceipt.passed=$true
}
catch {
    $taskReceipt.failure=$_.Exception.Message
    throw
}
finally {
    $taskAfter=@(Get-StabilityPlayerManifest)
    $taskAfter | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskOutput 'player-files-after.json') -Encoding UTF8
    $taskReceipt.playerUnchanged=Test-StabilityManifestEqual $taskBefore $taskAfter
    if(-not $taskReceipt.playerUnchanged){$taskReceipt.passed=$false;$taskReceipt.failure='Fixed player files changed during regression'}
    $taskReceipt.finishedUtc=[DateTime]::UtcNow.ToString('o')
    $taskReceipt | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskOutput 'run-result.json') -Encoding UTF8
    if($taskProcess){$taskProcess.Dispose()}
}
if(-not $taskReceipt.playerUnchanged){throw "Fixed player changed; evidence retained: $taskOutput"}
Write-Output ("Regression passed ($($taskReceipt.checks) checks): $taskOutput")
