$ErrorActionPreference = 'Stop'

function Set-GooseLocalPlayerConnection {
    param([Parameter(Mandatory = $true)][string]$PlayerPath)
    $taskPlayer = (Resolve-Path -LiteralPath $PlayerPath -ErrorAction Stop).Path
    $taskBoot = Join-Path (Split-Path $taskPlayer -Parent) ([IO.Path]::GetFileNameWithoutExtension($taskPlayer) + '_Data/boot.config')
    if (-not (Test-Path -LiteralPath $taskBoot)) { throw "Player boot.config missing: $taskBoot" }
    # Release builds have no PlayerConnection settings and need no changes.
    $taskOriginal = [IO.File]::ReadAllText($taskBoot)
    if ($taskOriginal -notmatch '(?m)^player-connection-') { return }
    if ($env:GOOSE_REMOTE_PROFILER -eq '1') { return }
    $taskKeys = '^player-connection-(mode|multicast|listen-address|ip)='
    $taskLines = @([IO.File]::ReadAllLines($taskBoot) | Where-Object { $_ -notmatch $taskKeys })
    $taskLines += @('player-connection-mode=Listen', 'player-connection-multicast=0',
        'player-connection-listen-address=127.0.0.1', 'player-connection-ip=127.0.0.1')
    $taskUpdated = ($taskLines -join [Environment]::NewLine) + [Environment]::NewLine
    if ($taskUpdated -eq $taskOriginal) { return }
    # Preserve the first original next to the mutable build, without touching evidence archives.
    $taskBackup = $taskBoot + '.before-local-network'
    if (-not (Test-Path -LiteralPath $taskBackup)) { Copy-Item -LiteralPath $taskBoot -Destination $taskBackup }
    [IO.File]::WriteAllText($taskBoot, $taskUpdated, [Text.UTF8Encoding]::new($false))
    Write-Host "[GooseNetwork] Local profiler only: $taskPlayer"
}
