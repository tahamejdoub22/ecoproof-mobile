# Flutter Diagnostic Script
# Helps diagnose slow flutter doctor and PATH issues

Write-Host "🔍 Flutter Diagnostic Tool" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is in PATH
Write-Host "1. Checking Flutter in PATH..." -ForegroundColor Yellow
$flutterInPath = $false
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    if ($flutterVersion -match "Flutter") {
        Write-Host "   ✅ Flutter is accessible via PATH" -ForegroundColor Green
        Write-Host "   $flutterVersion" -ForegroundColor Gray
        $flutterInPath = $true
    }
} catch {
    Write-Host "   ❌ Flutter not found in PATH" -ForegroundColor Red
}

# Find Flutter installation
Write-Host ""
Write-Host "2. Searching for Flutter installation..." -ForegroundColor Yellow
$flutterPath = $null
$searchPaths = @(
    "C:\src\flutter\bin",
    "$env:LOCALAPPDATA\Android\flutter\bin",
    "$env:USERPROFILE\flutter\bin",
    "C:\flutter\bin"
)

foreach ($path in $searchPaths) {
    if (Test-Path "$path\flutter.bat") {
        $flutterPath = $path
        Write-Host "   ✅ Found at: $flutterPath" -ForegroundColor Green
        break
    }
}

if (-not $flutterPath) {
    Write-Host "   ❌ Flutter installation not found" -ForegroundColor Red
    Write-Host "   Run fix-flutter-path.ps1 to locate and configure Flutter" -ForegroundColor Yellow
    exit 1
}

# Check network connectivity
Write-Host ""
Write-Host "3. Checking network connectivity..." -ForegroundColor Yellow
try {
    $ping = Test-Connection -ComputerName "storage.googleapis.com" -Count 1 -Quiet
    if ($ping) {
        Write-Host "   ✅ Network connectivity OK" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Network connectivity issues detected" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not test network connectivity" -ForegroundColor Yellow
}

# Check environment variables
Write-Host ""
Write-Host "4. Checking Flutter environment variables..." -ForegroundColor Yellow
$flutterStorage = [Environment]::GetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "User")
$pubHosted = [Environment]::GetEnvironmentVariable("PUB_HOSTED_URL", "User")

if ($flutterStorage) {
    Write-Host "   ✅ FLUTTER_STORAGE_BASE_URL: $flutterStorage" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  FLUTTER_STORAGE_BASE_URL not set" -ForegroundColor Yellow
}

if ($pubHosted) {
    Write-Host "   ✅ PUB_HOSTED_URL: $pubHosted" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  PUB_HOSTED_URL not set" -ForegroundColor Yellow
}

# Check Git
Write-Host ""
Write-Host "5. Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "   ✅ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Git not found" -ForegroundColor Red
    Write-Host "   Flutter requires Git. Install from: https://git-scm.com/download/win" -ForegroundColor Yellow
}

# Check Android SDK (if applicable)
Write-Host ""
Write-Host "6. Checking Android SDK..." -ForegroundColor Yellow
$androidHome = [Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")
if ($androidHome -and (Test-Path $androidHome)) {
    Write-Host "   ✅ ANDROID_HOME: $androidHome" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  ANDROID_HOME not set (optional for Android development)" -ForegroundColor Yellow
}

# Test flutter doctor with timeout
Write-Host ""
Write-Host "7. Testing flutter doctor (60 second timeout)..." -ForegroundColor Yellow
Write-Host "   This will help identify if flutter doctor hangs..." -ForegroundColor Gray

if (-not $flutterInPath) {
    $env:PATH += ";$flutterPath"
}

try {
    $job = Start-Job -ScriptBlock {
        param($path)
        if ($path) {
            $env:PATH += ";$path"
        }
        flutter doctor 2>&1
    } -ArgumentList $flutterPath
    
    $result = Wait-Job $job -Timeout 60
    if ($result) {
        $output = Receive-Job $job
        Remove-Job $job
        Write-Host "   ✅ flutter doctor completed!" -ForegroundColor Green
        Write-Host ""
        Write-Host $output
    } else {
        Stop-Job $job
        Remove-Job $job
        Write-Host "   ❌ flutter doctor timed out after 60 seconds" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Possible causes:" -ForegroundColor Yellow
        Write-Host "   - Network connectivity issues" -ForegroundColor Gray
        Write-Host "   - Firewall blocking Flutter" -ForegroundColor Gray
        Write-Host "   - Antivirus scanning Flutter files" -ForegroundColor Gray
        Write-Host "   - Slow internet connection" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   Solutions:" -ForegroundColor Yellow
        Write-Host "   1. Add Flutter folder to antivirus exclusions" -ForegroundColor White
        Write-Host "   2. Check firewall settings" -ForegroundColor White
        Write-Host "   3. Try: flutter doctor -v (verbose mode)" -ForegroundColor White
        Write-Host "   4. Try: flutter doctor --android-licenses (if needed)" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Error running flutter doctor: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host ("=" * 50) -ForegroundColor Cyan
Write-Host "Diagnostic complete!" -ForegroundColor Green
Write-Host ""

