param([switch]$SkipModels,[switch]$BuildWeChat)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskPython='C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$taskEditor='D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
$taskWork=Join-Path $taskRoot 'work/reference-look-pipeline'
New-Item -ItemType Directory -Force -Path $taskWork | Out-Null
function Invoke-Hidden($taskFile,$taskArguments,$taskLogName) {
    if ([IO.Path]::GetFileName($taskFile) -eq 'CatchGoose.exe') { Set-GooseLocalPlayerConnection -PlayerPath $taskFile }
    $taskQuoted=($taskArguments | ForEach-Object {'"'+$_+'"'}) -join ' '
    $taskRun=Start-Process -FilePath $taskFile -ArgumentList $taskQuoted -WorkingDirectory $taskRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $taskWork ($taskLogName+'.out.log')) -RedirectStandardError (Join-Path $taskWork ($taskLogName+'.err.log'))
    if($taskRun.ExitCode -ne 0){throw "$taskLogName failed ($($taskRun.ExitCode)); see $taskWork"}
}
Push-Location $taskRoot
try {
    if(-not $SkipModels){
        & $taskPython tools/unity/prepare_reference_materials.py
        if($LASTEXITCODE -ne 0){throw 'Reference source preparation failed'}
        Invoke-Hidden 'D:/开发/tools/blender/blender-4.5.14-windows-x64/blender.exe' @('--background','--factory-startup','--python-exit-code','1','--python',(Join-Path $taskRoot 'tools/unity/build_reference_materials.py')) 'models'
    }
    & 'D:/开发/微信web开发者工具/node.exe' tools/unity/validate_reference_look.mjs
    if($LASTEXITCODE -ne 0){throw 'Candidate validation failed'}
    & $taskPython tools/unity/retire_reference_legacy_ui.py
    if($LASTEXITCODE -ne 0){throw 'Legacy UI archive failed'}
    & $taskPython tools/unity/stage_reference_look.py
    if($LASTEXITCODE -ne 0){throw 'Reference staging failed'}
    & $taskPython tools/unity/subset_ui_font.py
    $taskBase=@('-batchmode','-nographics','-projectPath',(Join-Path $taskRoot 'projects/catch-big-goose-unity'),'-buildTarget','StandaloneWindows64')
    Invoke-Hidden $taskEditor ($taskBase+@('-executeMethod','CatchGoose.Editor.GooseDeviceBuild.ReferenceLookPreview','-quit','-logFile',(Join-Path $taskWork 'preview-build.log'))) 'preview-build'
    Invoke-Hidden (Join-Path $taskRoot 'projects/catch-big-goose-unity/Builds/ReferenceLookPreview/CatchGoose.exe') @('-gooseLookQa','-gooseMobileProfile','-gooseLookOutput',(Join-Path $taskWork 'preview'),'-screen-width','563','-screen-height','1000','-screen-fullscreen','0','-logFile',(Join-Path $taskWork 'preview.log')) 'preview'
    & $taskPython tools/unity/stage_reference_icons.py --preview (Join-Path $taskWork 'preview')
    if($LASTEXITCODE -ne 0){throw 'Preview icon staging failed'}
    Invoke-Hidden $taskEditor ($taskBase+@('-executeMethod','CatchGoose.Editor.GooseReferenceImportAudit.Run','-quit','-logFile',(Join-Path $taskWork 'import-audit.log'))) 'import-audit'
    Invoke-Hidden $taskEditor ($taskBase+@('-executeMethod','CatchGoose.Editor.GooseDeviceBuild.ReferenceLook','-quit','-logFile',(Join-Path $taskWork 'final-native-build.log'))) 'final-native-build'
    if($BuildWeChat){& (Join-Path $PSScriptRoot 'build-wechat.ps1');if($LASTEXITCODE -ne 0){throw 'WeChat build failed'}}
    Write-Output "Reference pipeline passed. Four views, icons and same-pile shader comparison: $taskWork/preview"
} finally {Pop-Location}
