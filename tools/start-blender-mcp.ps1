param([switch]$Show)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$settingsPath = Join-Path $taskRoot 'tools/blender.local.json'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    throw "Missing tools/blender.local.json; configure blender executable and bootstrap script paths."
}
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $settings.blender)) { throw 'Blender executable not found.' }
$listener = Get-NetTCPConnection -State Listen -LocalPort 9876 -ErrorAction SilentlyContinue
if ($listener) { Write-Output 'Blender MCP port is already listening; no additional instance started.'; exit 0 }
$style = if ($Show) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $settings.blender -ArgumentList @('--python', ('"' + $settings.bootstrap + '"')) -WindowStyle $style -PassThru
Write-Output "Blender MCP started (PID $($process.Id)); localhost:9876."
