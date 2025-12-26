# Install Android SDK Platforms Script
# This script finds Java and installs required Android platforms

param(
    [string]$SdkPath = "C:\Android\sdk"
)

$env:PATH += ";C:\tools\flutter\bin"

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Installing Android SDK Platforms" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Find Java
$javaPath = $null
$javaExe = $null

# Check common Java locations
$javaLocations = @(
    "$env:JAVA_HOME\bin\java.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\java.exe",
    "C:\Program Files\Android\Android Studio\jre\bin\java.exe",
    "C:\Program Files\Java\*\bin\java.exe"
)

foreach ($location in $javaLocations) {
    $found = Get-ChildItem $location -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $javaExe = $found.FullName
        $javaPath = Split-Path (Split-Path $found.FullName)
        break
    }
}

# Also try to find in PATH
if (-not $javaExe) {
    try {
        $javaCheck = Get-Command java -ErrorAction SilentlyContinue
        if ($javaCheck) {
            $javaExe = $javaCheck.Source
            $javaPath = Split-Path (Split-Path $javaCheck.Source)
        }
    } catch {}
}

# Search for Java in common locations
if (-not $javaExe) {
    Write-Host "[*] Searching for Java installation..." -ForegroundColor Cyan
    $searchPaths = @(
        "C:\Program Files\Android\Android Studio",
        "C:\Program Files\Java",
        "$env:PROGRAMFILES\Java",
        "$env:PROGRAMFILES(X86)\Java"
    )
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $javaFound = Get-ChildItem $searchPath -Recurse -Filter "java.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($javaFound) {
                $javaExe = $javaFound.FullName
                $javaPath = Split-Path (Split-Path $javaFound.FullName)
                Write-Host "[OK] Found Java at: $javaExe" -ForegroundColor Green
                break
            }
        }
    }
}

if (-not $javaExe) {
    Write-Host "[X] Java not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "[*] Please install Java JDK or use Android Studio to install platforms:" -ForegroundColor Yellow
    Write-Host "   1. Open Android Studio" -ForegroundColor White
    Write-Host "   2. Go to: File > Settings > Appearance & Behavior > System Settings > Android SDK" -ForegroundColor White
    Write-Host "   3. Check 'Android 13.0 (API 33)' and 'Android 14.0 (API 34)'" -ForegroundColor White
    Write-Host "   4. Click Apply to install" -ForegroundColor White
    Write-Host ""
    Write-Host "   OR install Java JDK from: https://adoptium.net/" -ForegroundColor White
    exit 1
}

Write-Host "[OK] Using Java: $javaExe" -ForegroundColor Green

# Set JAVA_HOME
$env:JAVA_HOME = $javaPath
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
Write-Host "[OK] JAVA_HOME set to: $javaPath" -ForegroundColor Green

# Find sdkmanager
$sdkmanager = "$SdkPath\cmdline-tools\latest\bin\sdkmanager.bat"
if (-not (Test-Path $sdkmanager)) {
    $sdkmanager = "$SdkPath\cmdline-tools\bin\sdkmanager.bat"
}

if (-not (Test-Path $sdkmanager)) {
    Write-Host "[X] sdkmanager not found at: $sdkmanager" -ForegroundColor Red
    Write-Host "   Please install Android SDK Command-line Tools first." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found sdkmanager: $sdkmanager" -ForegroundColor Green

# Set Android environment variables
$env:ANDROID_HOME = $SdkPath
$env:ANDROID_SDK_ROOT = $SdkPath
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkPath, "User")

# Accept licenses first
Write-Host ""
Write-Host "[*] Accepting Android SDK licenses..." -ForegroundColor Cyan
$licenseInput = "y`n" * 10
try {
    $licenseInput | & $sdkmanager --licenses --sdk_root=$SdkPath 2>&1 | Out-Null
    Write-Host "[OK] Licenses accepted" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: License acceptance may need manual confirmation" -ForegroundColor Yellow
}

# Install platforms
Write-Host ""
Write-Host "[*] Installing Android SDK platforms..." -ForegroundColor Cyan
Write-Host "   This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

$platformsToInstall = @(
    "platforms;android-33",
    "platforms;android-34",
    "platform-tools",
    "build-tools;34.0.0"
)

foreach ($package in $platformsToInstall) {
    Write-Host "[*] Installing $package..." -ForegroundColor Cyan
    try {
        & $sdkmanager $package --sdk_root=$SdkPath 2>&1 | Tee-Object -Variable output
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Installed: $package" -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Installation returned exit code $LASTEXITCODE for: $package" -ForegroundColor Yellow
            if ($output -match "license") {
                Write-Host "   You may need to accept licenses manually" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "[!] Error installing $package : $_" -ForegroundColor Yellow
    }
}

# Verify installation
Write-Host ""
Write-Host "[*] Verifying installed platforms..." -ForegroundColor Cyan
$platforms = Get-ChildItem "$SdkPath\platforms" -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^android-\d+$'
}

if ($platforms.Count -gt 0) {
    Write-Host "[OK] Valid platforms found:" -ForegroundColor Green
    foreach ($platform in $platforms) {
        Write-Host "   - $($platform.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] Warning: No valid platforms found after installation!" -ForegroundColor Yellow
}

# Configure Flutter
Write-Host ""
Write-Host "[*] Configuring Flutter..." -ForegroundColor Cyan
flutter config --android-sdk $SdkPath

# Run flutter doctor
Write-Host ""
Write-Host "[*] Running flutter doctor..." -ForegroundColor Cyan
flutter doctor

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

