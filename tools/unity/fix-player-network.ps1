param([string[]]$PlayerPath)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'player-network.ps1')
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $PlayerPath) {
    $taskBuilds = Join-Path $taskRoot 'projects/catch-big-goose-unity/Builds'
    # Only current build outputs, never frozen projects or reference evidence.
    $PlayerPath = @(Get-ChildItem -LiteralPath $taskBuilds -Directory | ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Filter '*.exe' -File | Where-Object {
            Test-Path -LiteralPath (Join-Path $_.DirectoryName ($_.BaseName + '_Data/boot.config'))
        } | ForEach-Object { $_.FullName }
    })
}
foreach ($taskPlayer in $PlayerPath) { Set-GooseLocalPlayerConnection -PlayerPath $taskPlayer }
