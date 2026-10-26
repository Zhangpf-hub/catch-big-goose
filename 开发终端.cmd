@echo off
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -NoExit -File "%~dp0tools\dev-shell.ps1"
