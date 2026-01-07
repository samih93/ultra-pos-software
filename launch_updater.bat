@echo off
REM Launch PowerShell updater script as a detached process
echo Launching updater...
start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File "%~1" -ZipPath "%~2" -TargetDir "%~3" -ExeName "%~4"
exit
