$ErrorActionPreference = 'Stop'

# Existing desktop apps may still hold the PATH from before environment setup.
# Refresh this terminal from the saved Windows environment without restarting apps.
$savedPaths = @(
    [Environment]::GetEnvironmentVariable('Path', 'User'),
    [Environment]::GetEnvironmentVariable('Path', 'Machine'),
    $env:Path
)
$env:Path = ($savedPaths -join ';')
foreach ($name in @('COCOS_CREATOR', 'PYTHON', 'BASH_PATH')) {
    $value = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($value) { Set-Item -Path "Env:$name" -Value $value }
}

Set-Location (Split-Path $PSScriptRoot -Parent)
Write-Host 'Catch the Goose development terminal' -ForegroundColor Cyan
node --version
npm.cmd --version
python --version
Write-Host "Creator: $env:COCOS_CREATOR"
Write-Host 'Commands: npm.cmd run check / npm.cmd run build / npm.cmd run dev'
Write-Host 'Open editor: & $env:COCOS_CREATOR --project "$PWD\cocos"'
