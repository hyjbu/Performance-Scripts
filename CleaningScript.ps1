# Windows Cleanup Automation Script
# Run this script as Administrator

Write-Host "Starting cleanup process..." -ForegroundColor Cyan

# Task 1: Delete all files in Temp directory
Write-Host "`n[1/3] Cleaning Temp directory..." -ForegroundColor Yellow

$tempPath = "C:\Users\Admin\AppData\Local\Temp"

try {
    # Get all items in temp directory
    $items = Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    
    $totalItems = $items.Count
    $deletedCount = 0
    $skippedCount = 0
    
    foreach ($item in $items) {
        try {
            # Attempt to delete the item
            Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction Stop
            $deletedCount++
        }
        catch {
            # Skip files that are in use or access denied
            $skippedCount++
        }
    }
    
    Write-Host "  Deleted: $deletedCount items" -ForegroundColor Green
    Write-Host "  Skipped: $skippedCount items (in use or access denied)" -ForegroundColor Gray
}
catch {
    Write-Host "  Error accessing Temp directory: $_" -ForegroundColor Red
}

# Task 2: Run Disk Cleanup with specific options
Write-Host "`n[2/3] Running Disk Cleanup..." -ForegroundColor Yellow

try {
    # Set Disk Cleanup flags for Temporary files and Recycle Bin
    # StateFlags0001 is a custom cleanup profile
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    
    # Temporary Files
    Set-ItemProperty -Path "$registryPath\Temporary Files" -Name "StateFlags0001" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    
    # Recycle Bin
    Set-ItemProperty -Path "$registryPath\Recycle Bin" -Name "StateFlags0001" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    
    # Run Disk Cleanup silently with the custom profile
    Write-Host "  Executing Disk Cleanup utility..." -ForegroundColor Gray
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -NoNewWindow
    
    Write-Host "  Disk Cleanup completed" -ForegroundColor Green
}
catch {
    Write-Host "  Error running Disk Cleanup: $_" -ForegroundColor Red
}

# Task 3: Success message
Write-Host "`n[3/3] Cleanup completed!" -ForegroundColor Yellow
Write-Host "`nScript run success" -ForegroundColor Green

Write-Host "`nPress any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")