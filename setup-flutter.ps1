# Flutter Setup Script for EcoProof Mobile
# This script helps you set up Flutter for this project

Write-Host "🔍 Checking for Flutter installation..." -ForegroundColor Cyan

# Common Flutter installation paths
$flutterPaths = @(
    "C:\src\flutter\bin",
    "$env:LOCALAPPDATA\Android\flutter\bin",
    "$env:USERPROFILE\flutter\bin",
    "C:\flutter\bin"
)

$flutterFound = $false
$flutterPath = ""

foreach ($path in $flutterPaths) {
    if (Test-Path "$path\flutter.bat") {
        $flutterFound = $true
        $flutterPath = $path
        Write-Host "✅ Flutter found at: $path" -ForegroundColor Green
        break
    }
}

if (-not $flutterFound) {
    Write-Host "❌ Flutter not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "2. Extract to: C:\src\flutter (recommended)" -ForegroundColor Yellow
    Write-Host "3. Add C:\src\flutter\bin to your PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or enter your Flutter installation path:" -ForegroundColor Cyan
    $customPath = Read-Host "Flutter bin path (e.g., C:\src\flutter\bin)"
    
    if ($customPath -and (Test-Path "$customPath\flutter.bat")) {
        $flutterPath = $customPath
        $flutterFound = $true
        Write-Host "✅ Flutter found at: $customPath" -ForegroundColor Green
    } else {
        Write-Host "❌ Flutter not found at: $customPath" -ForegroundColor Red
        exit 1
    }
}

# Add Flutter to PATH for this session
Write-Host ""
Write-Host "📝 Adding Flutter to PATH for this session..." -ForegroundColor Cyan
$env:PATH += ";$flutterPath"
Write-Host "✅ Flutter added to PATH" -ForegroundColor Green

# Verify Flutter works
Write-Host ""
Write-Host "🔍 Verifying Flutter installation..." -ForegroundColor Cyan
try {
    $flutterVersion = & "$flutterPath\flutter.bat" --version 2>&1
    Write-Host "✅ Flutter is working!" -ForegroundColor Green
    Write-Host $flutterVersion
} catch {
    Write-Host "❌ Error running Flutter: $_" -ForegroundColor Red
    exit 1
}

# Run flutter doctor
Write-Host ""
Write-Host "🏥 Running Flutter Doctor..." -ForegroundColor Cyan
& "$flutterPath\flutter.bat" doctor

# Install dependencies
Write-Host ""
Write-Host "📦 Installing project dependencies..." -ForegroundColor Cyan
& "$flutterPath\flutter.bat" pub get

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Note: Flutter is only in PATH for this PowerShell session." -ForegroundColor Yellow
Write-Host "   To make it permanent, add '$flutterPath' to your System PATH." -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "   - Run: flutter devices (to see available devices)" -ForegroundColor White
Write-Host "   - Run: flutter run (to run the app)" -ForegroundColor White

