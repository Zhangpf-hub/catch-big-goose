param([string]$EditorData = 'D:/开发/tools/unity/2022.3.62f3/Editor/Data', [string]$OutputDirectory = 'work/competitor-algorithm-tests')
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskOutput = Join-Path $taskRoot $OutputDirectory
New-Item -ItemType Directory -Force -Path $taskOutput | Out-Null
$taskArgs = @('/nologo', '/nostdlib+', '/target:exe', "/out:$taskOutput/PolicyTests.dll",
    "/reference:$EditorData/NetStandard/ref/2.1.0/netstandard.dll", "/reference:$EditorData/Managed/UnityEngine/UnityEngine.CoreModule.dll",
    "/reference:$EditorData/Managed/UnityEngine/UnityEngine.JSONSerializeModule.dll",
    "$taskRoot/unity/Assets/Scripts/GooseGeneration.cs", "$taskRoot/unity/Assets/Scripts/GooseDepthPolicy.cs",
    "$taskRoot/unity/Assets/Scripts/GooseRules.cs", "$taskRoot/unity/Assets/Scripts/GooseLevelPolicy.cs", "$taskRoot/tests/competitor/PolicyTests.cs")
& "$EditorData/NetCoreRuntime/dotnet.exe" "$EditorData/DotNetSdkRoslyn/csc.dll" @taskArgs
if ($LASTEXITCODE -ne 0) { throw 'Policy test compilation failed' }
'{"runtimeOptions":{"tfm":"net6.0","framework":{"name":"Microsoft.NETCore.App","version":"6.0.21"}}}' | Set-Content -LiteralPath "$taskOutput/PolicyTests.runtimeconfig.json" -Encoding utf8
Copy-Item -LiteralPath "$EditorData/Managed/UnityEngine/UnityEngine.CoreModule.dll" -Destination $taskOutput -Force
& "$EditorData/NetCoreRuntime/dotnet.exe" "$taskOutput/PolicyTests.dll" $taskOutput
if ($LASTEXITCODE -ne 0) { throw 'Policy tests failed' }
