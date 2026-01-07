param(
    [string]$ExePath,
    [string]$WorkingDir
)

# Simple restart script - waits for app to exit then restarts it
$ProcessName = [System.IO.Path]::GetFileNameWithoutExtension($ExePath)

Write-Host "Waiting for $ProcessName to exit..."

# Wait for app to exit (max 30 seconds)
$MaxWaitTime = 30
for ($i = 0; $i -lt $MaxWaitTime; $i++) {
    $Processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if ($Processes.Count -eq 0) { 
        Write-Host "App has exited"
        break 
    }
    
    Start-Sleep -Seconds 1
}

# Wait a bit more to ensure clean exit
Start-Sleep -Seconds 2

# Restart the app in a new detached process
Write-Host "Restarting application..."
$Process = Start-Process -FilePath $ExePath -WorkingDirectory $WorkingDir -PassThru

if ($Process) {
    Write-Host "Application restarted successfully with PID: $($Process.Id)"
} else {
    Write-Host "Failed to restart application"
}

# Exit PowerShell immediately to close the window
exit