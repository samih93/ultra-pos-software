@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: build_release.bat [version]
    echo Example: build_release.bat 1.1.25
    pause
    exit /b 1
)

set VERSION=%1
echo ==========================================
echo Building Core Manager v%VERSION%
echo ==========================================

echo.
echo [1/4] Building Flutter app...
call flutter build windows --release
if !ERRORLEVEL! neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo.
echo [2/4] Copying required files to build...
copy updater.ps1 build\windows\x64\runner\Release\ >nul
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to copy updater.ps1!
    pause
    exit /b 1
)
copy launch_updater.bat build\windows\x64\runner\Release\ >nul
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to copy launch_updater.bat!
    pause
    exit /b 1
)
copy restart_app.ps1 build\windows\x64\runner\Release\ >nul
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to copy restart_app.ps1!
    pause
    exit /b 1
)
copy launch_restart.bat build\windows\x64\runner\Release\ >nul
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to copy launch_restart.bat!
    pause
    exit /b 1
)
if exist "windows\sqlite3.dll" (
    copy windows\sqlite3.dll build\windows\x64\runner\Release\ >nul
    if !ERRORLEVEL! neq 0 (
        echo WARNING: Failed to copy sqlite3.dll
    ) else (
        echo SQLite3.dll copied successfully.
    )
)
echo Updater, launcher, and restart scripts copied successfully.

echo.
echo [3/4] Creating release zip...
pushd build\windows\x64\runner\Release
powershell -Command "$items = Get-ChildItem -Path . | Where-Object { $_.Name -notlike 'backup_*' -and $_.Name -notlike '*.zip' -and $_.Name -ne 'update_temp.zip' -and $_.Name -notlike 'update_log*' -and $_.Name -ne 'update_debug.txt' }; Compress-Archive -Path $items -DestinationPath 'core-manager-v%VERSION%.zip' -Force"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to create ZIP!
    popd
    pause
    exit /b 1
)
echo ZIP created successfully (excluding backup folders and temp files).

echo.
echo [4/4] Generating release info...
if exist "core-manager-v%VERSION%.zip" (
    for %%I in ("core-manager-v%VERSION%.zip") do set FILESIZE=%%~zI
    echo File size: !FILESIZE! bytes
) else (
    echo Warning: ZIP file not found!
    set FILESIZE=0
)

echo.
echo ==========================================
echo 🎉 RELEASE READY!
echo ==========================================
echo Version: %VERSION%
echo File: core-manager-v%VERSION%.zip
echo Size: !FILESIZE! bytes
echo Location: !CD!
echo.
echo ==========================================
echo NEXT STEPS:
echo ==========================================
echo 1. Upload ZIP to Supabase Storage:
echo    - Go to Storage -^> releases -^> zips/
echo    - Upload: core-manager-v%VERSION%.zip
echo    - Copy the public URL
echo.
echo 2. Update database (run in Supabase SQL Editor):
echo    INSERT INTO app_versions (version, download_url, file_size, release_notes,is_latest)
echo    VALUES (
echo        '%VERSION%',
echo        'https://svlszknmrtjvnwbkrsfr.supabase.co/storage/v1/object/public/releases/zips/core-manager-v%VERSION%.zip',
echo        !FILESIZE!,
echo        'Release notes for version %VERSION%',
echo        true
echo    );
echo.
echo 3. Test the update on a different machine
echo ==========================================
popd
echo.
pause