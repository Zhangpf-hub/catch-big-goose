$ErrorActionPreference = 'Stop'
$projectDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'reference-projects/catch-big-goose-cocos'
$packageFile = Join-Path $projectDir 'package.json'
$sceneFile = Join-Path $projectDir 'assets\scene\main.scene'
if (!(Test-Path -LiteralPath $packageFile) -or !(Test-Path -LiteralPath $sceneFile)) {
    throw "The game project is incomplete: $projectDir"
}
$version = (Get-Content -LiteralPath $packageFile -Raw | ConvertFrom-Json).creator.version
$editorHome = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'CocosEditors'
$candidates = @(
    $env:COCOS_CREATOR,
    [Environment]::GetEnvironmentVariable('COCOS_CREATOR', 'User'),
    (Join-Path $editorHome "$version\CocosCreator.exe"),
    (Join-Path $env:ProgramData "cocos\editors\Creator\$version\CocosCreator.exe")
)
$creatorExe = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
if (!$creatorExe) { throw "Set COCOS_CREATOR to the Cocos Creator $version executable." }
Write-Host "Opening game project: $projectDir"
Start-Process -FilePath $creatorExe -ArgumentList '--project', ('"' + $projectDir + '"') -WorkingDirectory $projectDir -WindowStyle Normal
