@echo off
REM Batch launcher for app restart after database restore
START "" powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~1" -ExePath "%~2" -WorkingDir "%~3"
