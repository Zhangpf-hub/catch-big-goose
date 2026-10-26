param([string]$EditorData = 'D:/开发/tools/unity/2022.3.62f3/Editor/Data')
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$taskOutput = Join-Path $taskRoot 'work/competitor-tests'
New-Item -ItemType Directory -Force -Path $taskOutput | Out-Null
$taskUi = Join-Path $EditorData 'Resources/PackageManager/ProjectTemplates/libcache/com.unity.template.3d-8.1.3/ScriptAssemblies/UnityEngine.UI.dll'
$taskArgs = @('/nologo', '/nostdlib+', '/target:library', '/define:UNITY_EDITOR,DEVELOPMENT_BUILD',
    "/out:$taskOutput/alignment-check.dll",
    "/reference:$EditorData/NetStandard/ref/2.1.0/netstandard.dll",
    "/reference:$EditorData/NetStandard/compat/2.1.0/shims/netfx/mscorlib.dll",
    "/reference:$EditorData/Managed/UnityEditor.dll", "/reference:$taskUi")
$taskArgs += Get-ChildItem -LiteralPath "$EditorData/Managed/UnityEngine" -Filter '*.dll' | ForEach-Object { '/reference:' + $_.FullName }
$taskArgs += Get-ChildItem -LiteralPath "$EditorData/Managed" -Filter 'UnityEditor.*.dll' | ForEach-Object { '/reference:' + $_.FullName }
$taskArgs += Get-ChildItem -LiteralPath "$taskRoot/unity/Assets/Scripts" -Filter '*.cs' | ForEach-Object { $_.FullName }
$taskArgs += "$taskRoot/unity/Assets/Editor/GooseAssetImporter.cs"
$taskNunit = Join-Path $taskOutput 'nunit.framework.dll'
if (Test-Path -LiteralPath $taskNunit) {
    $taskArgs += "/reference:$taskNunit"
    $taskArgs += Get-ChildItem -LiteralPath "$taskRoot/unity/Assets/Tests/Editor" -Filter '*.cs' | ForEach-Object { $_.FullName }
}
& "$EditorData/NetCoreRuntime/dotnet.exe" "$EditorData/DotNetSdkRoslyn/csc.dll" @taskArgs
if ($LASTEXITCODE -ne 0) { throw 'C# semantic compilation failed' }
Write-Output 'C# semantic compilation passed. This command does not run Unity; see the separate Unity test and algorithm acceptance reports.'
