@echo off
powershell.exe -NoLogo -NoProfile -File "%~dp0tools\unity\open-project.ps1"
if errorlevel 1 pause
