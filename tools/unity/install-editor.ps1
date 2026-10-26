$ErrorActionPreference = 'Stop'
$installer = 'D:/开发/tools/unity/installers/UnitySetup64-2022.3.62f3.exe'
if (-not (Test-Path -LiteralPath $installer)) { throw 'Official Unity installer is missing.' }
Write-Output 'Windows will request permission to install Unity. Please approve the system dialog yourself.'
$p = Start-Process -FilePath $installer -ArgumentList @('/S', '/D=D:\开发\tools\unity\2022.3.62f3') -PassThru -Wait
if ($p.ExitCode -ne 0) { throw "Unity installer returned $($p.ExitCode)" }
$editor = 'D:/开发/tools/unity/2022.3.62f3/Editor/Unity.exe'
if (-not (Test-Path -LiteralPath $editor)) { throw 'Installer finished but the Editor executable is missing.' }
Write-Output "Unity Editor installed: $editor"
