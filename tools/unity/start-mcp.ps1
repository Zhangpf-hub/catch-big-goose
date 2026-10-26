param([int]$Port = 8088)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$runtime = 'D:/开发/tools/unity-mcp-venv/Scripts/python.exe'
if (-not (Test-Path -LiteralPath $runtime)) { throw 'Unity MCP runtime is missing.' }
$existing = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($existing) { Write-Output "Unity MCP already listening on 127.0.0.1:$Port"; exit 0 }
$logs = Join-Path $taskRoot 'work/unity-migration'
New-Item -ItemType Directory -Force -Path $logs | Out-Null
$env:UNITY_MCP_TELEMETRY_ENABLED = 'false'
$env:DISABLE_TELEMETRY = '1'
$env:UNITY_MCP_DISABLE_TELEMETRY = '1'
$process = Start-Process -FilePath $runtime -ArgumentList @('-m', 'main', '--transport', 'http', '--http-host', '127.0.0.1', '--http-port', "$Port") -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $logs 'mcp-server.stdout.log') -RedirectStandardError (Join-Path $logs 'mcp-server.stderr.log')
Write-Output "Unity MCP starting (PID $($process.Id)), endpoint http://127.0.0.1:$Port/mcp"
