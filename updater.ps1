param(
    [string]$ZipPath,
    [string]$TargetDir,
    [string]$ExeName
)

# Create log file for debugging
$LogFile = Join-Path $TargetDir "update_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

Write-Log "Core Manager Updater v1.1 Started"
Write-Log "Zip: $ZipPath"
Write-Log "Target: $TargetDir"
Write-Log "Exe: $ExeName"
Write-Log "Log: $LogFile"

# Validate parameters
Write-Log "Step 1: Validating parameters"
if (-not $ZipPath) {
    Write-Log "ERROR: ZipPath parameter is empty"
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not $TargetDir) {
    Write-Log "ERROR: TargetDir parameter is empty"
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not $ExeName) {
    Write-Log "ERROR: ExeName parameter is empty"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Log "Parameters validated successfully"
Write-Log "Step 2: Checking file existence"

if (-not (Test-Path $ZipPath)) {
    Write-Log "ERROR: ZIP file not found: $ZipPath"
    Write-Log "Current directory: $(Get-Location)"
    Write-Log "Directory contents:"
    Get-ChildItem -Path (Split-Path $ZipPath -Parent) -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Log "  $($_.Name) ($($_.Length) bytes)"
    }
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Log "ZIP file found: $ZipPath ($(Get-Item $ZipPath | Select-Object -ExpandProperty Length) bytes)"

if (-not (Test-Path $TargetDir)) {
    Write-Log "ERROR: Target directory not found: $TargetDir"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Log "✅ Step 1: Validation passed - ZIP and target directory exist"

# Wait for main app to exit
$ExePath = Join-Path $TargetDir $ExeName
Write-Log "✅ Step 2: Waiting for app to exit gracefully..."

$MaxWaitTime = 60
for ($i = 0; $i -lt $MaxWaitTime; $i++) {
    $ProcessName = [System.IO.Path]::GetFileNameWithoutExtension($ExeName)
    $Processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if ($Processes.Count -eq 0) { 
        Write-Log "✅ Step 2: App has exited successfully"
        break 
    }
    
    if ($i -eq 0) {
        # Try to close gracefully first
        Write-Log "Attempting graceful shutdown..."
        $Processes | ForEach-Object { $_.CloseMainWindow() }
    }
    
    if ($i -eq 30) {
        # Force kill after 30 seconds
        Write-Log "Force terminating processes..."
        $Processes | ForEach-Object { $_.Kill() }
    }
    
    if (($i + 1) % 10 -eq 0) {
        Write-Log "Waiting... ($($i+1)/$MaxWaitTime)"
    }
    Start-Sleep -Seconds 1
}

# Check if processes are still running
$RemainingProcesses = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($RemainingProcesses.Count -gt 0) {
    Write-Log "❌ ERROR: Could not terminate application processes"
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    Write-Log "✅ Step 3: Extracting update..."
    
    # Create temp directory
    $TempDir = Join-Path $env:TEMP ("core_manager_update_" + [System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    Write-Log "Created temp directory: $TempDir"
    
    # Extract zip
    Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
    Write-Log "ZIP extracted to temp directory"
    
    # CRITICAL FIX: Handle nested extraction (random 4-char folders)
    # Check what was extracted
    $ExtractedItems = Get-ChildItem -Path $TempDir
    Write-Log "Extracted items in temp directory: $($ExtractedItems.Count) items"
    
    # List all items for debugging
    foreach ($Item in $ExtractedItems) {
        if ($Item.PSIsContainer) {
            Write-Log "  Found folder: $($Item.Name)"
        } else {
            Write-Log "  Found file: $($Item.Name)"
        }
    }
    
    # Check if we have a nested structure (single folder with all content inside)
    if ($ExtractedItems.Count -eq 1 -and $ExtractedItems[0].PSIsContainer) {
        $NestedFolderName = $ExtractedItems[0].Name
        $NestedFolderPath = $ExtractedItems[0].FullName
        
        Write-Log "⚠️ NESTED EXTRACTION DETECTED!"
        Write-Log "All files are inside folder: '$NestedFolderName'"
        Write-Log "This is the Windows Expand-Archive bug on certain systems"
        
        # Check if nested folder contains the EXE (confirms it's the app folder)
        $ExeInNested = Get-ChildItem -Path $NestedFolderPath -Filter $ExeName -ErrorAction SilentlyContinue
        if ($ExeInNested) {
            Write-Log "✅ Confirmed: Found $ExeName inside nested folder"
            Write-Log "Adjusting source directory to: $NestedFolderPath"
            # Simply use the nested folder as our source!
            $TempDir = $NestedFolderPath
        } else {
            Write-Log "⚠️ Warning: $ExeName not found in nested folder, checking subdirectories..."
            # Maybe it's nested even deeper, try to find the exe
            $ExeSearch = Get-ChildItem -Path $NestedFolderPath -Filter $ExeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($ExeSearch) {
                $TempDir = $ExeSearch.Directory.FullName
                Write-Log "✅ Found $ExeName at: $TempDir"
            } else {
                Write-Log "❌ ERROR: Could not find $ExeName in extracted files"
                throw "Application executable not found in update package"
            }
        }
    } else {
        Write-Log "✅ Direct extraction (files at root level)"
    }
    
    Write-Log "Final source directory: $TempDir"
    Write-Log "✅ Step 3: ZIP extraction validated"
    
    # Count total files for progress
    $AllFiles = Get-ChildItem -Path $TempDir -Recurse -File
    $TotalFiles = $AllFiles.Count
    $FileCount = 0
    
    Write-Log "✅ Step 4: Installing $TotalFiles files..."
    
    # Normalize the temp directory path to avoid short path issues (ADMINI~1 vs Administrator)
    $TempDirNormalized = (Get-Item -LiteralPath $TempDir).FullName
    Write-Log "Source directory (normalized): $TempDirNormalized"
    
    # Copy files with better error handling
    Get-ChildItem -Path $TempDir -Recurse | ForEach-Object {
        # Get the full normalized path of the current item
        $ItemFullPath = $_.FullName
        
        # Calculate relative path by removing the normalized temp directory
        if ($ItemFullPath.StartsWith($TempDirNormalized)) {
            $RelativePath = $ItemFullPath.Substring($TempDirNormalized.Length).TrimStart("\")
        } else {
            # Fallback: try with original temp dir if normalized doesn't match
            $RelativePath = $ItemFullPath.Substring($TempDir.Length).TrimStart("\")
        }
        
        $DestPath = Join-Path $TargetDir $RelativePath
        
        try {
            if ($_.PSIsContainer) {
                # Create directory
                if (-not (Test-Path $DestPath)) {
                    New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
                    Write-Log "Created directory: $RelativePath"
                }
            } else {
                # Copy file
                $FileCount++
                $DestDir = Split-Path $DestPath -Parent
                
                # Ensure destination directory exists
                if (-not (Test-Path $DestDir)) {
                    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
                }
                
                # Handle locked files (retry mechanism)
                $Retries = 3
                for ($Retry = 1; $Retry -le $Retries; $Retry++) {
                    try {
                        Copy-Item -Path $_.FullName -Destination $DestPath -Force
                        if ($FileCount % 20 -eq 0 -or $_.Name -match "\.exe$|\.dll$") {
                            Write-Log "[$FileCount/$TotalFiles] Copied: $($_.Name)"
                        }
                        break
                    } catch {
                        if ($Retry -eq $Retries) {
                            Write-Log "❌ ERROR: Failed to copy $($_.Name) after $Retries attempts: $($_.Exception.Message)"
                            throw
                        } else {
                            Write-Log "Retry $Retry for $($_.Name)..."
                            Start-Sleep -Seconds 1
                        }
                    }
                }
            }
        } catch {
            Write-Log "❌ ERROR: Failed to process $RelativePath : $($_.Exception.Message)"
            throw
        }
    }
    
    Write-Log "✅ Step 4: File copying completed - $FileCount files processed"
    
    # Verify critical files were copied
    Write-Log "✅ Step 5: Verifying installation..."
    $VerificationFailed = $false
    
    if (-not (Test-Path $ExePath)) {
        Write-Log "❌ ERROR: Main executable not found after update: $ExePath"
        $VerificationFailed = $true
    } else {
        Write-Log "✅ Main executable verified: $ExeName"
    }
    
    $RequiredDlls = @("flutter_windows.dll")
    foreach ($Dll in $RequiredDlls) {
        $DllPath = Join-Path $TargetDir $Dll
        if (-not (Test-Path $DllPath)) {
            Write-Log "❌ ERROR: Required DLL not found: $Dll"
            $VerificationFailed = $true
        } else {
            Write-Log "✅ Required DLL verified: $Dll"
        }
    }
    
    if ($VerificationFailed) {
        Write-Log "❌ Step 5: Verification failed - Update aborted"
        throw "Installation verification failed"
    } else {
        Write-Log "✅ Step 5: Verification completed successfully"
    }
    
    # Cleanup
    Write-Log "✅ Step 6: Cleaning up temporary files..."
    
    # Remove temp directory and ZIP file
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Removed temp directory: $TempDir"
    }
    
    if (Test-Path $ZipPath) {
        Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue
        Write-Log "Removed ZIP file: $ZipPath"
    }
    
    # Remove all update-related temporary files
    $TempFiles = @(
        "update_temp.zip",
        "update_debug.txt"
    )
    foreach ($TempFile in $TempFiles) {
        $TempFilePath = Join-Path $TargetDir $TempFile
        if (Test-Path $TempFilePath) {
            Remove-Item -Path $TempFilePath -Force -ErrorAction SilentlyContinue
            Write-Log "Removed temporary file: $TempFile"
        }
    }
    
    # Remove old update log files (keep only the current one)
    $OldLogs = Get-ChildItem -Path $TargetDir -File -Filter "update_log_*.txt" | Where-Object { $_.FullName -ne $LogFile } | Sort-Object LastWriteTime -Descending | Select-Object -Skip 1
    foreach ($OldLog in $OldLogs) {
        Remove-Item -Path $OldLog.FullName -Force -ErrorAction SilentlyContinue
        Write-Log "Removed old log: $($OldLog.Name)"
    }
    
    Write-Log "✅ Step 6: Cleanup completed - Removed temporary files"
    
    Write-Log "✅ Step 7: Update completed successfully!"
    
    # Restart app
    Write-Log "✅ Step 8: Restarting application..."
    Start-Sleep -Seconds 2
    Start-Process -FilePath $ExePath -WorkingDirectory $TargetDir
    Write-Log "✅ Step 8: Application restarted successfully"
    
    Write-Log "🎉 UPDATE COMPLETED SUCCESSFULLY!"
    
    # Remove the current log file after successful update
    Start-Sleep -Seconds 1
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Log "❌ Update failed: $($_.Exception.Message)"
    Write-Log "You can manually restore from backup if needed."
    Write-Log "❌ UPDATE FAILED! Check this log file for details: $LogFile"
    
    # Show popup notification of failure
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("Update failed! Check log file: $LogFile", "Update Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    
    Read-Host "Press Enter to exit"
    exit 1
}