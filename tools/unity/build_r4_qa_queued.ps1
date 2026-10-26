param([string]$Label='qa18',[string]$Destination='Builds/R4QA18/CatchGooseR4QA.exe')
$ErrorActionPreference='Stop'
$r4TaskRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$r4Project=Join-Path $r4TaskRoot 'projects/catch-big-goose-unity'
$r4Editor=Join-Path (Split-Path $r4TaskRoot -Parent) 'tools/unity/2022.3.62f3/Editor/Unity.exe'
$r4Log=Join-Path $r4TaskRoot ('work/r4-interaction-20261025/build-'+$Label+'.log')
# The project is shared with other local tasks. Wait for their editor rather
# than closing it or deleting Unity's lock file.
while(Get-CimInstance Win32_Process | Where-Object {$_.Name -eq 'Unity.exe' -and $_.CommandLine -like ('*'+$r4Project+'*')}){Start-Sleep -Seconds 3}
$r4Args=@('-batchmode','-nographics','-projectPath',$r4Project,'-buildTarget','Win64','-executeMethod','CatchGoose.Editor.GooseR4Build.BuildQa','-gooseQaOutput',$Destination,'-quit','-logFile',$r4Log)
$r4Quoted=($r4Args|ForEach-Object{'"'+$_+'"'}) -join ' '
$r4Build=Start-Process $r4Editor -ArgumentList $r4Quoted -WindowStyle Hidden -PassThru
Write-Output ('Unity PID '+$r4Build.Id+'; log '+$r4Log)
$r4Build.WaitForExit()
Write-Output ('Launcher exit '+$r4Build.ExitCode+'; inspect the log and any replacement editor before deciding build status.')
