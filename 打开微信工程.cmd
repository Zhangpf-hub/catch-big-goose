@echo off
powershell.exe -NoLogo -NoProfile -File "%~dp0tools\unity\open-wechat.ps1"
if errorlevel 1 pause
