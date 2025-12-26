# Refresh Environment Variables Script
# Use this script in a new PowerShell session to reload environment variables
# after running fix-android-sdk-path.ps1

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Refreshing Environment Variables" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Write-Host "[OK] PATH refreshed" -ForegroundColor Green

# Refresh ANDROID_HOME
$androidHome = [System.Environment]::GetEnvironmentVariable("ANDROID_HOME","User")
if ($androidHome) {
    $env:ANDROID_HOME = $androidHome
    Write-Host "[OK] ANDROID_HOME = $androidHome" -ForegroundColor Green
} else {
    Write-Host "[!] ANDROID_HOME not set" -ForegroundColor Yellow
}

# Refresh ANDROID_SDK_ROOT
$androidSdkRoot = [System.Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT","User")
if ($androidSdkRoot) {
    $env:ANDROID_SDK_ROOT = $androidSdkRoot
    Write-Host "[OK] ANDROID_SDK_ROOT = $androidSdkRoot" -ForegroundColor Green
} else {
    Write-Host "[!] ANDROID_SDK_ROOT not set" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[*] Testing Flutter..." -ForegroundColor Cyan
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Flutter is available" -ForegroundColor Green
    Write-Host ""
    Write-Host "[*] Running flutter doctor..." -ForegroundColor Cyan
    flutter doctor
} else {
    Write-Host "[!] Flutter not found in PATH" -ForegroundColor Yellow
    Write-Host "   Make sure Flutter is installed and added to PATH" -ForegroundColor Yellow
}

Write-Host ""



