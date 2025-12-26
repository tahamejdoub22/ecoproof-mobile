# Android SDK Path Fix Script for EcoProof Mobile
# This script fixes Android SDK path issues when the path contains spaces
# Usage: .\fix-android-sdk-path.ps1 [NewSdkPath]
# Example: .\fix-android-sdk-path.ps1 "C:\Android\sdk"

param(
    [string]$NewSdkPath = $null
)

# Current Android SDK path (with spaces)
$currentSdkPath = "$env:LOCALAPPDATA\Android\sdk"

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Android SDK Path Fix Script" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Check if Android SDK exists at current location
Write-Host "[*] Checking current Android SDK location..." -ForegroundColor Cyan
if (-not (Test-Path $currentSdkPath)) {
    Write-Host "[X] Android SDK not found at: $currentSdkPath" -ForegroundColor Red
    Write-Host "   Please check if Android Studio is installed and SDK is set up." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Android SDK found at: $currentSdkPath" -ForegroundColor Green

# Check if path contains spaces
if ($currentSdkPath -match '\s') {
    Write-Host "[!] Current path contains spaces (not supported by Android SDK)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Current path does not contain spaces" -ForegroundColor Green
    Write-Host "   No action needed!" -ForegroundColor Green
    exit 0
}

# Determine new SDK path
if (-not $NewSdkPath) {
    $defaultPath = "C:\Android\sdk"
    Write-Host ""
    Write-Host "[*] Please choose a new location for Android SDK (without spaces):" -ForegroundColor Cyan
    Write-Host "   Default: $defaultPath" -ForegroundColor Gray
    $userInput = Read-Host "   Press Enter to use default, or enter custom path"
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        $NewSdkPath = $defaultPath
    } else {
        $NewSdkPath = $userInput.Trim().TrimEnd('\')
    }
} else {
    $NewSdkPath = $NewSdkPath.Trim().TrimEnd('\')
}

# Validate new path doesn't contain spaces
if ($NewSdkPath -match '\s') {
    Write-Host "[X] Error: New path contains spaces: $NewSdkPath" -ForegroundColor Red
    Write-Host "   Android SDK requires a path without spaces!" -ForegroundColor Yellow
    exit 1
}

# Check if new location already exists
if (Test-Path $NewSdkPath) {
    Write-Host ""
    Write-Host "[!] Warning: Path already exists: $NewSdkPath" -ForegroundColor Yellow
    $overwrite = Read-Host "   Do you want to overwrite? (y/N)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "[X] Operation cancelled" -ForegroundColor Red
        exit 1
    }
    Write-Host "[*] Removing existing directory..." -ForegroundColor Cyan
    Remove-Item -Path $NewSdkPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Create parent directory if needed
$parentDir = Split-Path -Parent $NewSdkPath
if (-not (Test-Path $parentDir)) {
    Write-Host "[*] Creating parent directory: $parentDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

# Check for processes that might lock SDK files
Write-Host ""
Write-Host "[*] Checking for processes that might lock SDK files..." -ForegroundColor Cyan

$processesToStop = @()
$adbProcesses = Get-Process -Name "adb" -ErrorAction SilentlyContinue
$studioProcesses = Get-Process -Name "studio64", "studio" -ErrorAction SilentlyContinue

if ($adbProcesses) {
    Write-Host "[!] Found ADB processes running. These need to be stopped." -ForegroundColor Yellow
    $processesToStop += $adbProcesses
}

if ($studioProcesses) {
    Write-Host "[!] Found Android Studio processes running. These should be closed." -ForegroundColor Yellow
    $processesToStop += $studioProcesses
}

if ($processesToStop.Count -gt 0) {
    Write-Host ""
    Write-Host "[*] Attempting to stop processes..." -ForegroundColor Cyan
    foreach ($proc in $processesToStop) {
        try {
            Write-Host "   Stopping: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Gray
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Start-Sleep -Milliseconds 500
        } catch {
            Write-Host "   [!] Could not stop $($proc.ProcessName): $_" -ForegroundColor Yellow
        }
    }
    Write-Host "[*] Waiting 2 seconds for processes to fully terminate..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
} else {
    Write-Host "[OK] No conflicting processes found" -ForegroundColor Green
}

# Move Android SDK
Write-Host ""
Write-Host "[*] Moving Android SDK from:" -ForegroundColor Cyan
Write-Host "   From: $currentSdkPath" -ForegroundColor Gray
Write-Host "   To:   $NewSdkPath" -ForegroundColor Gray
Write-Host ""
Write-Host "   This may take several minutes depending on SDK size..." -ForegroundColor Yellow
Write-Host "   Please be patient and do not close this window!" -ForegroundColor Yellow
Write-Host ""

try {
    # Use robocopy for better performance and progress
    # Use & operator with properly quoted paths to handle spaces
    # Capture stderr to check for access denied errors
    $robocopyOutput = & robocopy "$currentSdkPath" "$NewSdkPath" /E /MOVE /NFL /NDL /NJH /NJS 2>&1
    $robocopyExitCode = $LASTEXITCODE
    
    # Check output for access denied errors
    $accessDeniedErrors = $robocopyOutput | Select-String -Pattern "Access is denied" -Quiet
    
    # Robocopy returns exit codes 0-7 for success, 8+ for errors
    if ($robocopyExitCode -le 7) {
        Write-Host "[OK] Android SDK moved successfully!" -ForegroundColor Green
    } else {
        Write-Host "[X] Error moving Android SDK. Exit code: $robocopyExitCode" -ForegroundColor Red
        
        # Check for access denied errors
        if ($accessDeniedErrors -or $robocopyExitCode -ge 8) {
            Write-Host "" -ForegroundColor Red
            Write-Host "[!] Access denied errors detected. This usually means:" -ForegroundColor Yellow
            Write-Host "   1. ADB or Android Studio processes are still running" -ForegroundColor White
            Write-Host "   2. Files are locked by another application" -ForegroundColor White
            Write-Host "   3. Insufficient permissions (try running as Administrator)" -ForegroundColor White
            Write-Host "" -ForegroundColor Yellow
            Write-Host "[*] Solutions:" -ForegroundColor Cyan
            Write-Host "   - Close Android Studio completely" -ForegroundColor White
            Write-Host "   - Close any running Flutter/Android apps" -ForegroundColor White
            Write-Host "   - Run this script as Administrator" -ForegroundColor White
            Write-Host "   - Or manually copy the SDK folder and update environment variables" -ForegroundColor White
            Write-Host ""
            
            # Check if files were partially moved
            if (Test-Path "$NewSdkPath\platform-tools") {
                Write-Host "[!] Some files were moved. You may need to manually copy remaining files." -ForegroundColor Yellow
            }
        }
        exit 1
    }
} catch {
    Write-Host "[X] Error moving Android SDK: $_" -ForegroundColor Red
    exit 1
}

# Verify move was successful
if (-not (Test-Path "$NewSdkPath\platform-tools")) {
    Write-Host "[!] Warning: SDK move may not have completed fully" -ForegroundColor Yellow
    Write-Host "   Please verify the SDK is at: $NewSdkPath" -ForegroundColor Yellow
}

# Update environment variables
Write-Host ""
Write-Host "[*] Updating environment variables..." -ForegroundColor Cyan

# Update ANDROID_HOME
try {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $NewSdkPath, "User")
    $env:ANDROID_HOME = $NewSdkPath
    Write-Host "[OK] ANDROID_HOME updated to: $NewSdkPath" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not update ANDROID_HOME: $_" -ForegroundColor Yellow
}

# Update ANDROID_SDK_ROOT
try {
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $NewSdkPath, "User")
    $env:ANDROID_SDK_ROOT = $NewSdkPath
    Write-Host "[OK] ANDROID_SDK_ROOT updated to: $NewSdkPath" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not update ANDROID_SDK_ROOT: $_" -ForegroundColor Yellow
}

# Update PATH
Write-Host ""
Write-Host "[*] Updating PATH environment variable..." -ForegroundColor Cyan
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Remove old SDK paths from PATH
$pathEntries = $currentUserPath -split ';' | Where-Object {
    $_ -and 
    $_ -ne $currentSdkPath -and 
    $_ -ne "$currentSdkPath\platform-tools" -and
    $_ -ne "$currentSdkPath\tools" -and
    $_ -ne "$currentSdkPath\tools\bin"
}

# Add new SDK paths to PATH
$newPathEntries = @(
    $NewSdkPath,
    "$NewSdkPath\platform-tools",
    "$NewSdkPath\tools",
    "$NewSdkPath\tools\bin"
)

$updatedPath = ($pathEntries + $newPathEntries | Where-Object { $_ -and (Test-Path $_) }) -join ';'

try {
    [Environment]::SetEnvironmentVariable("Path", $updatedPath, "User")
    Write-Host "[OK] PATH updated successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not update PATH: $_" -ForegroundColor Yellow
    Write-Host "   You may need to manually update PATH in System Properties" -ForegroundColor Yellow
}

# Refresh current session environment variables
Write-Host ""
Write-Host "[*] Refreshing environment variables in current session..." -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:ANDROID_HOME = [System.Environment]::GetEnvironmentVariable("ANDROID_HOME","User")
$env:ANDROID_SDK_ROOT = [System.Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT","User")
Write-Host "[OK] Environment variables refreshed for current session" -ForegroundColor Green

# Configure Flutter with the new Android SDK path
Write-Host ""
Write-Host "[*] Configuring Flutter with new Android SDK path..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    try {
        & flutter config --android-sdk $NewSdkPath 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Flutter configured with Android SDK: $NewSdkPath" -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Flutter config command returned exit code $LASTEXITCODE" -ForegroundColor Yellow
            Write-Host "   You may need to run manually: flutter config --android-sdk `"$NewSdkPath`"" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Warning: Could not configure Flutter: $_" -ForegroundColor Yellow
        Write-Host "   Please run manually: flutter config --android-sdk `"$NewSdkPath`"" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Flutter not found in PATH. Please run after restarting PowerShell:" -ForegroundColor Yellow
    Write-Host "   flutter config --android-sdk `"$NewSdkPath`"" -ForegroundColor Gray
}

# Clean up old directory if empty
if (Test-Path $currentSdkPath) {
    $remainingItems = Get-ChildItem -Path $currentSdkPath -ErrorAction SilentlyContinue
    if ($remainingItems.Count -eq 0) {
        Write-Host ""
        Write-Host "[*] Removing empty old directory..." -ForegroundColor Cyan
        Remove-Item -Path $currentSdkPath -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host ""
        Write-Host "[!] Warning: Old directory still contains items:" -ForegroundColor Yellow
        Write-Host "   $currentSdkPath" -ForegroundColor Gray
        Write-Host "   You may want to manually clean this up" -ForegroundColor Yellow
    }
}

# Verify with flutter doctor
Write-Host ""
Write-Host "[*] Verifying with Flutter..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "   Running flutter doctor to verify Android SDK..." -ForegroundColor Gray
    $flutterDoctor = flutter doctor 2>&1 | Select-String -Pattern "Android"
    if ($flutterDoctor) {
        Write-Host $flutterDoctor
    }
} else {
    Write-Host "[!] Flutter not found in PATH. Please run flutter doctor manually after restarting PowerShell." -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "[OK] Android SDK Path Fix Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Summary:" -ForegroundColor Cyan
Write-Host "   - Old SDK path: $currentSdkPath" -ForegroundColor White
Write-Host "   - New SDK path: $NewSdkPath" -ForegroundColor White
Write-Host "   - ANDROID_HOME: $NewSdkPath" -ForegroundColor White
Write-Host "   - ANDROID_SDK_ROOT: $NewSdkPath" -ForegroundColor White
Write-Host ""
Write-Host "[*] Next steps:" -ForegroundColor Cyan
Write-Host "   1. IMPORTANT: Close and reopen PowerShell to load new environment variables" -ForegroundColor Yellow
Write-Host "   2. In the new PowerShell session, run: flutter doctor" -ForegroundColor White
Write-Host "   3. Verify Android SDK is detected correctly" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "[*] If flutter doctor still doesn't work in a new PowerShell:" -ForegroundColor Cyan
Write-Host "   Option 1: Run the refresh script:" -ForegroundColor White
Write-Host "   .\refresh-env.ps1" -ForegroundColor Gray
Write-Host "" -ForegroundColor White
Write-Host "   Option 2: Manually refresh environment variables:" -ForegroundColor White
Write-Host "   `$env:ANDROID_HOME = [Environment]::GetEnvironmentVariable('ANDROID_HOME','User')" -ForegroundColor Gray
Write-Host "   `$env:ANDROID_SDK_ROOT = [Environment]::GetEnvironmentVariable('ANDROID_SDK_ROOT','User')" -ForegroundColor Gray
Write-Host "   `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')" -ForegroundColor Gray
Write-Host ""
Write-Host "[*] Note:" -ForegroundColor Cyan
Write-Host "   If you're using Android Studio, you may need to update the SDK location" -ForegroundColor White
Write-Host "   in Android Studio settings: File > Settings > Appearance & Behavior > System Settings > Android SDK" -ForegroundColor Gray
Write-Host ""

