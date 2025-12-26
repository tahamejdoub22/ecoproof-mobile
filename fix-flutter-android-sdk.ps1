# Fix Flutter Android SDK Detection Script
# This script fixes Flutter's Android SDK detection issues
# Usage: .\fix-flutter-android-sdk.ps1

param(
    [string]$SdkPath = "C:\Android\sdk"
)

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Flutter Android SDK Fix Script" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Check if SDK path exists
if (-not (Test-Path $SdkPath)) {
    Write-Host "[X] Android SDK not found at: $SdkPath" -ForegroundColor Red
    Write-Host "   Please install Android SDK first or specify the correct path." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Android SDK found at: $SdkPath" -ForegroundColor Green

# Check current platforms
Write-Host ""
Write-Host "[*] Checking installed platforms..." -ForegroundColor Cyan
$allPlatforms = Get-ChildItem "$SdkPath\platforms" -Directory -ErrorAction SilentlyContinue
$validPlatforms = $allPlatforms | Where-Object { $_.Name -match '^android-\d+$' }
$invalidPlatforms = $allPlatforms | Where-Object { $_.Name -notmatch '^android-\d+$' }

if ($validPlatforms.Count -gt 0) {
    Write-Host "[OK] Found valid platforms:" -ForegroundColor Green
    foreach ($platform in $validPlatforms) {
        Write-Host "   - $($platform.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] No valid platforms found!" -ForegroundColor Yellow
}

if ($invalidPlatforms.Count -gt 0) {
    Write-Host "[!] Found invalid platform folders (these won't be recognized by Flutter):" -ForegroundColor Yellow
    foreach ($platform in $invalidPlatforms) {
        Write-Host "   - $($platform.Name)" -ForegroundColor Gray
    }
}

# Set environment variables
Write-Host ""
Write-Host "[*] Setting environment variables..." -ForegroundColor Cyan
try {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkPath, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkPath, "User")
    $env:ANDROID_HOME = $SdkPath
    $env:ANDROID_SDK_ROOT = $SdkPath
    Write-Host "[OK] Environment variables set" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not set environment variables: $_" -ForegroundColor Yellow
}

# Update PATH
Write-Host ""
Write-Host "[*] Updating PATH environment variable..." -ForegroundColor Cyan
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathEntries = $currentUserPath -split ';' | Where-Object { $_ }

# Remove old SDK paths
$pathEntries = $pathEntries | Where-Object {
    $_ -and 
    $_ -notmatch 'Android[\\/]sdk' -and
    $_ -notmatch 'LOCALAPPDATA[\\/]Android[\\/]sdk'
}

# Add new SDK paths
$newPathEntries = @(
    $SdkPath,
    "$SdkPath\platform-tools",
    "$SdkPath\tools",
    "$SdkPath\tools\bin"
)

$updatedPath = ($pathEntries + $newPathEntries | Where-Object { $_ -and (Test-Path $_) }) -join ';'

try {
    [Environment]::SetEnvironmentVariable("Path", $updatedPath, "User")
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "[OK] PATH updated successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not update PATH: $_" -ForegroundColor Yellow
}

# Configure Flutter
Write-Host ""
Write-Host "[*] Configuring Flutter with Android SDK..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    try {
        $flutterConfigOutput = & flutter config --android-sdk $SdkPath 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Flutter configured with Android SDK: $SdkPath" -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Flutter config returned exit code $LASTEXITCODE" -ForegroundColor Yellow
            Write-Host "   Output: $flutterConfigOutput" -ForegroundColor Gray
        }
    } catch {
        Write-Host "[!] Warning: Could not configure Flutter: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Flutter not found in PATH" -ForegroundColor Yellow
    Write-Host "   Please run manually after restarting PowerShell:" -ForegroundColor Yellow
    Write-Host "   flutter config --android-sdk `"$SdkPath`"" -ForegroundColor Gray
}

# Check if we need to install valid platforms
if ($validPlatforms.Count -eq 0) {
    Write-Host ""
    Write-Host "[!] No valid Android platforms found!" -ForegroundColor Yellow
    Write-Host "[*] You need to install at least one valid Android platform." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Option 1: Use Android Studio" -ForegroundColor White
    Write-Host "   File > Settings > Appearance & Behavior > System Settings > Android SDK" -ForegroundColor Gray
    Write-Host "   Install SDK Platform (API 33 or 34 recommended)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Option 2: Use sdkmanager (requires Java)" -ForegroundColor White
    
    # Check for sdkmanager
    $sdkmanager = $null
    $cmdlineToolsPaths = @(
        "$SdkPath\cmdline-tools\latest\bin\sdkmanager.bat",
        "$SdkPath\cmdline-tools\bin\sdkmanager.bat"
    )
    
    foreach ($path in $cmdlineToolsPaths) {
        if (Test-Path $path) {
            $sdkmanager = $path
            break
        }
    }
    
    if ($sdkmanager) {
        Write-Host "   Found sdkmanager at: $sdkmanager" -ForegroundColor Gray
        Write-Host "   Run: & `"$sdkmanager`" platforms;android-34 --sdk_root=`"$SdkPath`"" -ForegroundColor Gray
    } else {
        Write-Host "   sdkmanager not found. Install Android SDK Command-line Tools first." -ForegroundColor Gray
        Write-Host "   Or run: .\install-android-cmdline-tools.ps1" -ForegroundColor Gray
    }
} else {
    # Check if android-33 is valid (it should be)
    $hasAndroid33 = $validPlatforms | Where-Object { $_.Name -eq "android-33" }
    if (-not $hasAndroid33) {
        Write-Host ""
        Write-Host "[!] Note: android-33 is not installed, but you have other valid platforms." -ForegroundColor Yellow
        Write-Host "   Flutter typically works with android-33 or android-34." -ForegroundColor Gray
    }
}

# Verify with flutter doctor
Write-Host ""
Write-Host "[*] Verifying setup with flutter doctor..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host ""
    flutter doctor
} else {
    Write-Host "[!] Flutter not found. Please run flutter doctor manually after restarting PowerShell." -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "[OK] Fix Script Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Summary:" -ForegroundColor Cyan
Write-Host "   - SDK Path: $SdkPath" -ForegroundColor White
Write-Host "   - ANDROID_HOME: $SdkPath" -ForegroundColor White
Write-Host "   - ANDROID_SDK_ROOT: $SdkPath" -ForegroundColor White
Write-Host "   - Valid platforms: $($validPlatforms.Count)" -ForegroundColor White
Write-Host ""
Write-Host "[*] Next steps:" -ForegroundColor Cyan
Write-Host "   1. Close and reopen PowerShell to load new environment variables" -ForegroundColor Yellow
Write-Host "   2. Run: flutter doctor" -ForegroundColor White
Write-Host "   3. If platforms are still missing, install them using:" -ForegroundColor White
Write-Host "      - Android Studio SDK Manager, OR" -ForegroundColor Gray
Write-Host "      - Run: .\fix-android-sdk-platforms.ps1" -ForegroundColor Gray
Write-Host ""

