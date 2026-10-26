param([string]$Matrix='matrix-release-shake6')
$ErrorActionPreference='Stop'
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskWork=Join-Path $taskRoot 'work/mobile-surface-performance-20261026'
$taskProject=Join-Path $taskRoot 'projects/catch-big-goose-unity'
$taskSource=Join-Path $taskWork 'build-workspace/builds/catch-big-goose-wechat'
$taskDestination=Join-Path $taskRoot 'builds/catch-big-goose-wechat'
$taskPython='C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $taskPython (Join-Path $PSScriptRoot 'collect-surface-delivery.py') --matrix $Matrix --require-wechat
if($LASTEXITCODE -ne 0){throw 'Complete native matrix/export verification is required before publication'}
$taskVerification=Get-Content -LiteralPath (Join-Path $taskWork 'delivery-verification.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $taskVerification.currentRuntimeMatchesTestedSnapshot){throw 'The live source has changed since QA; inspect currentRuntimeDifferences and validate the merged source first'}
$taskRunning=Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq 'Unity.exe' -and $_.CommandLine.Replace([char]92,[char]47).ToLowerInvariant().Contains($taskProject.Replace([char]92,[char]47).ToLowerInvariant())
}
if($taskRunning){throw 'Another Unity build owns the active source project; tested snapshot is ready for publication when that build ends'}
# Close only the named generated project before replacing files watched by DevTools.
if(Get-Process wechatdevtools -ErrorAction SilentlyContinue) {
    & 'D:/开发/微信web开发者工具/node.exe' 'D:/开发/微信web开发者工具/cli.js' close --project $taskDestination --lang zh
    if($LASTEXITCODE -ne 0){throw 'DevTools did not release the named export'}
}
$taskStamp=[DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')
$taskStage=Join-Path $taskWork ('staged-wechat-'+$taskStamp)
$taskBackup=Join-Path $taskWork ('previous-wechat-'+$taskStamp)
$taskSeparator=[IO.Path]::DirectorySeparatorChar
$taskWorkspacePrefix=[IO.Path]::GetFullPath($taskRoot).TrimEnd($taskSeparator)+$taskSeparator
# Every recursive directory move below is restricted to this workspace.
foreach($taskPath in @($taskSource,$taskDestination,$taskStage,$taskBackup)) {
    if(-not [IO.Path]::GetFullPath($taskPath).StartsWith($taskWorkspacePrefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Publication path escaped the workspace'}
}
if(Test-Path -LiteralPath $taskStage){throw 'Publication stage already exists; preserve it and choose a fresh run'}
Copy-Item -LiteralPath $taskSource -Destination $taskStage -Recurse
$taskFiles=Get-ChildItem -LiteralPath $taskSource -File -Recurse
foreach($taskFile in $taskFiles) {
    $taskRelative=$taskFile.FullName.Substring($taskSource.Length).TrimStart([char]92,[char]47)
    $taskCopied=Join-Path $taskStage $taskRelative
    if((Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $taskCopied -Algorithm SHA256).Hash){throw 'Staged export differs from the tested snapshot'}
}
$taskHadPrevious=Test-Path -LiteralPath $taskDestination
if($taskHadPrevious){Move-Item -LiteralPath $taskDestination -Destination $taskBackup}
try { Move-Item -LiteralPath $taskStage -Destination $taskDestination }
catch { if($taskHadPrevious -and -not (Test-Path -LiteralPath $taskDestination)){Move-Item -LiteralPath $taskBackup -Destination $taskDestination}; throw }
& $taskPython (Join-Path $PSScriptRoot 'collect-surface-delivery.py') --matrix $Matrix --require-published
if($LASTEXITCODE -ne 0){throw 'Post-publication verification failed'}
$taskPublished=Get-Content -LiteralPath (Join-Path $taskWork 'delivery-verification.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(-not $taskPublished.liveWechatMatchesTestedExport){throw 'Named live export differs from the tested snapshot'}
Write-Output "Published verified surface export: $taskDestination; previous package preserved at $taskBackup"
