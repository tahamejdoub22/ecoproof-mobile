# Fix Android SDK Platforms Script
# This script installs proper Android SDK platforms and configures Flutter

param(
    [string]$SdkPath = "C:\Android\sdk"
)

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Android SDK Platforms Fix Script" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Check if SDK path exists
if (-not (Test-Path $SdkPath)) {
    Write-Host "[X] Android SDK not found at: $SdkPath" -ForegroundColor Red
    Write-Host "   Please install Android SDK first or specify the correct path." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Android SDK found at: $SdkPath" -ForegroundColor Green

# Find sdkmanager
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

if (-not $sdkmanager) {
    Write-Host "[X] sdkmanager not found!" -ForegroundColor Red
    Write-Host "   Please install Android SDK Command-line Tools first." -ForegroundColor Yellow
    Write-Host "   You can run: .\install-android-cmdline-tools.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found sdkmanager at: $sdkmanager" -ForegroundColor Green

# Set ANDROID_HOME and ANDROID_SDK_ROOT
$env:ANDROID_HOME = $SdkPath
$env:ANDROID_SDK_ROOT = $SdkPath
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkPath, "User")

Write-Host ""
Write-Host "[*] Installing required Android SDK platforms..." -ForegroundColor Cyan
Write-Host "   This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

# Install commonly required platforms (API 33, 34 are most common)
$platformsToInstall = @(
    "platforms;android-33",
    "platforms;android-34",
    "platform-tools",
    "build-tools;34.0.0"
)

foreach ($package in $platformsToInstall) {
    Write-Host "[*] Installing $package..." -ForegroundColor Cyan
    try {
        & $sdkmanager $package --sdk_root=$SdkPath 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Installed: $package" -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Installation may have issues for: $package" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Error installing $package : $_" -ForegroundColor Yellow
    }
}

# Accept licenses
Write-Host ""
Write-Host "[*] Accepting Android SDK licenses..." -ForegroundColor Cyan
try {
    & $sdkmanager --licenses --sdk_root=$SdkPath | ForEach-Object {
        if ($_ -match "y/n") {
            "y"
        }
    } | & $sdkmanager --licenses --sdk_root=$SdkPath 2>&1 | Out-Null
    Write-Host "[OK] Licenses accepted" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not auto-accept licenses. You may need to run manually:" -ForegroundColor Yellow
    Write-Host "   & $sdkmanager --licenses --sdk_root=$SdkPath" -ForegroundColor Gray
}

# Configure Flutter
Write-Host ""
Write-Host "[*] Configuring Flutter with Android SDK..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    try {
        & flutter config --android-sdk $SdkPath 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Flutter configured with Android SDK: $SdkPath" -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Flutter config returned exit code $LASTEXITCODE" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Warning: Could not configure Flutter: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Flutter not found in PATH" -ForegroundColor Yellow
}

# Verify platforms
Write-Host ""
Write-Host "[*] Verifying installed platforms..." -ForegroundColor Cyan
$platforms = Get-ChildItem "$SdkPath\platforms" -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^android-\d+$'
}

if ($platforms.Count -gt 0) {
    Write-Host "[OK] Found valid platforms:" -ForegroundColor Green
    foreach ($platform in $platforms) {
        Write-Host "   - $($platform.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] Warning: No valid platforms found!" -ForegroundColor Yellow
}

# Run flutter doctor
Write-Host ""
Write-Host "[*] Running flutter doctor to verify setup..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host ""
    flutter doctor
} else {
    Write-Host "[!] Flutter not found. Please run flutter doctor manually after restarting PowerShell." -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "[OK] Android SDK Platforms Fix Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Next steps:" -ForegroundColor Cyan
Write-Host "   1. Close and reopen PowerShell to load new environment variables" -ForegroundColor White
Write-Host "   2. Run: flutter doctor" -ForegroundColor White
Write-Host "   3. If issues persist, you may need to install additional platforms:" -ForegroundColor White
Write-Host "      & $sdkmanager platforms;android-XX --sdk_root=$SdkPath" -ForegroundColor Gray
Write-Host ""



