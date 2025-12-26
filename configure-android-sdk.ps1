# Quick Android SDK Configuration Script
# Run this in a PowerShell session where Flutter is available

$SdkPath = "C:\Android\sdk"

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Configuring Flutter with Android SDK" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Check if SDK exists
if (-not (Test-Path $SdkPath)) {
    Write-Host "[X] Android SDK not found at: $SdkPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Android SDK found at: $SdkPath" -ForegroundColor Green

# Set environment variables
$env:ANDROID_HOME = $SdkPath
$env:ANDROID_SDK_ROOT = $SdkPath
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkPath, "User")
Write-Host "[OK] Environment variables set" -ForegroundColor Green

# Configure Flutter
Write-Host ""
Write-Host "[*] Configuring Flutter..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter config --android-sdk $SdkPath
    Write-Host "[OK] Flutter configured!" -ForegroundColor Green
} else {
    Write-Host "[X] Flutter not found in PATH!" -ForegroundColor Red
    Write-Host "   Please run this script in a terminal where Flutter is available." -ForegroundColor Yellow
    Write-Host "   Or run manually: flutter config --android-sdk `"$SdkPath`"" -ForegroundColor Gray
    exit 1
}

# Check platforms
Write-Host ""
Write-Host "[*] Checking installed platforms..." -ForegroundColor Cyan
$platforms = Get-ChildItem "$SdkPath\platforms" -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^android-\d+$'
}

if ($platforms.Count -gt 0) {
    Write-Host "[OK] Valid platforms found:" -ForegroundColor Green
    foreach ($platform in $platforms) {
        Write-Host "   - $($platform.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] Warning: No valid Android platforms found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[*] To install platforms, you need:" -ForegroundColor Cyan
    Write-Host "   1. Install Java JDK (if not already installed)" -ForegroundColor White
    Write-Host "   2. Set JAVA_HOME environment variable" -ForegroundColor White
    Write-Host "   3. Run sdkmanager to install platforms:" -ForegroundColor White
    Write-Host "      & `"$SdkPath\cmdline-tools\latest\bin\sdkmanager.bat`" platforms;android-33 --sdk_root=`"$SdkPath`"" -ForegroundColor Gray
    Write-Host "      & `"$SdkPath\cmdline-tools\latest\bin\sdkmanager.bat`" platforms;android-34 --sdk_root=`"$SdkPath`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   OR use Android Studio:" -ForegroundColor White
    Write-Host "   File > Settings > Appearance & Behavior > System Settings > Android SDK" -ForegroundColor Gray
    Write-Host "   Then install SDK Platforms (API 33, 34, etc.)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[*] Running flutter doctor..." -ForegroundColor Cyan
flutter doctor

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

