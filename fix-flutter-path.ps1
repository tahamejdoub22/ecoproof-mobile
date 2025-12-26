# Flutter Path Fix Script for EcoProof Mobile
# This script fixes Flutter PATH issues for PowerShell and addresses slow flutter doctor
# Usage: .\fix-flutter-path.ps1 [FlutterBinPath]
# Example: .\fix-flutter-path.ps1 "C:\src\flutter\bin"

param(
    [string]$FlutterPath = $null
)

# Debug: Show if parameter was provided
if ($FlutterPath) {
    Write-Host "[*] Parameter provided: $FlutterPath" -ForegroundColor Cyan
} else {
    Write-Host "[*] Searching for Flutter installation..." -ForegroundColor Cyan
}

# Extended search paths including Git Bash common locations
$searchPaths = @(
    "C:\tools\flutter\bin",
    "C:\src\flutter\bin",
    "$env:LOCALAPPDATA\Android\flutter\bin",
    "$env:USERPROFILE\flutter\bin",
    "C:\flutter\bin",
    "C:\Program Files\flutter\bin",
    "C:\Program Files (x86)\flutter\bin",
    "$env:USERPROFILE\AppData\Local\flutter\bin",
    "$env:USERPROFILE\Documents\flutter\bin",
    # Git Bash might use these paths
    "/c/src/flutter/bin",
    "/c/flutter/bin",
    "/c/tools/flutter/bin",
    "/usr/local/flutter/bin"
)

$flutterPath = $null
$flutterFound = $false

# Check if path was provided as parameter (prioritize this)
if ($FlutterPath) {
    $testPath = $FlutterPath.Trim().TrimEnd('\')
    if ((Test-Path "$testPath\flutter.bat") -or (Test-Path "$testPath\flutter.exe")) {
        $flutterPath = $testPath
        $flutterFound = $true
        Write-Host "[OK] Using provided Flutter path: $flutterPath" -ForegroundColor Green
    } else {
        Write-Host "[X] Flutter not found at provided path: $testPath" -ForegroundColor Red
        Write-Host "   Please verify the path is correct and contains flutter.bat or flutter.exe" -ForegroundColor Yellow
        exit 1
    }
}

# Search for flutter.bat or flutter.exe (only if no parameter provided)
if (-not $flutterFound) {
    foreach ($path in $searchPaths) {
    # Convert Unix-style paths to Windows paths if needed
    $windowsPath = $path -replace '^/c/', 'C:\' -replace '^/usr/local/', 'C:\usr\local\' -replace '/', '\'
    
    if (Test-Path "$windowsPath\flutter.bat") {
        $flutterPath = $windowsPath
        $flutterFound = $true
        Write-Host "[OK] Flutter found at: $flutterPath" -ForegroundColor Green
        break
    }
    if (Test-Path "$windowsPath\flutter.exe") {
        $flutterPath = $windowsPath
        $flutterFound = $true
        Write-Host "[OK] Flutter found at: $flutterPath" -ForegroundColor Green
        break
    }
    }
}

# If not found, try to find via Git Bash PATH (only if no parameter provided)
if (-not $flutterFound) {
    Write-Host "[*] Checking Git Bash PATH..." -ForegroundColor Cyan
    try {
        # Try to get PATH from Git Bash
        $gitBashPath = & bash -c 'echo $PATH' 2>$null
        if ($gitBashPath) {
            $paths = $gitBashPath -split ':'
            foreach ($p in $paths) {
                $winPath = $p -replace '^/c/', 'C:\' -replace '^/usr/', 'C:\usr\' -replace '/', '\'
                if ((Test-Path "$winPath\flutter.bat") -or (Test-Path "$winPath\flutter.exe")) {
                    $flutterPath = $winPath
                    $flutterFound = $true
                    Write-Host "[OK] Flutter found via Git Bash at: $flutterPath" -ForegroundColor Green
                    break
                }
            }
        }
    } catch {
        Write-Host "[!] Could not check Git Bash PATH" -ForegroundColor Yellow
    }
}

# If still not found, ask user (only if running interactively)
if (-not $flutterFound) {
    Write-Host "[X] Flutter not found in common locations" -ForegroundColor Red
    Write-Host ""
    if ([Environment]::UserInteractive) {
        Write-Host "Please enter your Flutter installation path:" -ForegroundColor Yellow
        Write-Host "Example: C:\src\flutter\bin or C:\flutter\bin" -ForegroundColor Gray
        $customPath = Read-Host "Flutter bin path"
        
        if ($customPath) {
            $customPath = $customPath.Trim().TrimEnd('\')
            if ((Test-Path "$customPath\flutter.bat") -or (Test-Path "$customPath\flutter.exe")) {
                $flutterPath = $customPath
                $flutterFound = $true
                Write-Host "[OK] Flutter found at: $flutterPath" -ForegroundColor Green
            } else {
                Write-Host "[X] Flutter not found at: $customPath" -ForegroundColor Red
                Write-Host ""
                Write-Host "Usage: .\fix-flutter-path.ps1 [FlutterBinPath]" -ForegroundColor Yellow
                Write-Host "Example: .\fix-flutter-path.ps1 `"C:\src\flutter\bin`"" -ForegroundColor Gray
                exit 1
            }
        } else {
            Write-Host "[X] No path provided. Exiting." -ForegroundColor Red
            Write-Host ""
            Write-Host "Usage: .\fix-flutter-path.ps1 [FlutterBinPath]" -ForegroundColor Yellow
            Write-Host "Example: .\fix-flutter-path.ps1 `"C:\src\flutter\bin`"" -ForegroundColor Gray
            exit 1
        }
    } else {
        Write-Host "[X] Flutter not found and running non-interactively." -ForegroundColor Red
        Write-Host ""
        Write-Host "Usage: .\fix-flutter-path.ps1 [FlutterBinPath]" -ForegroundColor Yellow
        Write-Host "Example: .\fix-flutter-path.ps1 `"C:\src\flutter\bin`"" -ForegroundColor Gray
        exit 1
    }
}

# Verify Flutter works
Write-Host ""
Write-Host "[*] Verifying Flutter installation..." -ForegroundColor Cyan
if ($flutterPath -and (Test-Path "$flutterPath\flutter.bat")) {
    try {
        $flutterVersion = & "$flutterPath\flutter.bat" --version 2>&1 | Select-Object -First 3
        Write-Host "[OK] Flutter is working!" -ForegroundColor Green
        Write-Host $flutterVersion
    } catch {
        Write-Host "[!] Warning: Could not verify Flutter version" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Warning: Could not verify Flutter version - path not found" -ForegroundColor Yellow
}

# Add to PATH for current session
Write-Host ""
Write-Host "[*] Adding Flutter to PATH for this PowerShell session..." -ForegroundColor Cyan
if ($env:PATH -notlike "*$flutterPath*") {
    $env:PATH += ";$flutterPath"
    Write-Host "[OK] Flutter added to PATH for this session" -ForegroundColor Green
} else {
    Write-Host "[OK] Flutter already in PATH for this session" -ForegroundColor Green
}

# Add to User PATH permanently
Write-Host ""
Write-Host "[*] Adding Flutter to User PATH permanently..." -ForegroundColor Cyan

$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentUserPath -notlike "*$flutterPath*") {
    try {
        [Environment]::SetEnvironmentVariable("Path", "$currentUserPath;$flutterPath", "User")
        Write-Host "[OK] Flutter added to User PATH permanently!" -ForegroundColor Green
        Write-Host "   Note: You may need to restart PowerShell for changes to take effect" -ForegroundColor Yellow
    } catch {
        Write-Host "[X] Error adding to PATH: $_" -ForegroundColor Red
        Write-Host "   You may need to run this script as Administrator" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Flutter already in User PATH" -ForegroundColor Green
}

# Fix slow flutter doctor issue
Write-Host ""
Write-Host "[*] Optimizing Flutter for faster performance..." -ForegroundColor Cyan

# Set Flutter environment variables to improve performance
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"

# Add to user environment variables
try {
    [Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", $env:FLUTTER_STORAGE_BASE_URL, "User")
    [Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", $env:PUB_HOSTED_URL, "User")
    Write-Host "[OK] Flutter environment variables configured" -ForegroundColor Green
} catch {
        Write-Host "[!] Could not set environment variables (non-critical)" -ForegroundColor Yellow
}

# Disable analytics to speed up commands (optional)
Write-Host ""
Write-Host "[*] Disabling Flutter analytics for faster commands..." -ForegroundColor Cyan
if ($flutterPath -and (Test-Path "$flutterPath\flutter.bat")) {
    try {
        & "$flutterPath\flutter.bat" config --no-analytics 2>&1 | Out-Null
        Write-Host "[OK] Flutter analytics disabled" -ForegroundColor Green
    } catch {
        Write-Host "[!] Could not disable analytics" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Could not disable analytics - path not found" -ForegroundColor Yellow
}

# Test flutter doctor with timeout
Write-Host ""
Write-Host "[*] Testing flutter doctor (this may take a moment)..." -ForegroundColor Cyan
Write-Host "   If this hangs, press Ctrl+C and check your network/firewall settings" -ForegroundColor Gray

if ($flutterPath -and (Test-Path "$flutterPath\flutter.bat")) {
    try {
        # Run flutter doctor with a timeout
        $job = Start-Job -ScriptBlock {
            param($flutterPath)
            if ($flutterPath -and (Test-Path "$flutterPath\flutter.bat")) {
                & "$flutterPath\flutter.bat" doctor 2>&1
            } else {
                Write-Error "Flutter path is invalid: $flutterPath"
            }
        } -ArgumentList $flutterPath
    
    # Wait up to 60 seconds
    $result = Wait-Job $job -Timeout 60
    if ($result) {
        $output = Receive-Job $job
        Remove-Job $job
        Write-Host $output
        Write-Host ""
        Write-Host "[OK] flutter doctor completed successfully!" -ForegroundColor Green
    } else {
        Stop-Job $job
        Remove-Job $job
        Write-Host ""
        Write-Host "[!] flutter doctor timed out after 60 seconds" -ForegroundColor Yellow
        Write-Host "   This might be due to:" -ForegroundColor Yellow
        Write-Host "   - Network connectivity issues" -ForegroundColor Gray
        Write-Host "   - Firewall blocking Flutter" -ForegroundColor Gray
        Write-Host "   - Antivirus scanning Flutter files" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   Try running: flutter doctor -v (verbose mode)" -ForegroundColor Cyan
    }
    } catch {
        Write-Host "[!] Could not run flutter doctor: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Could not run flutter doctor - Flutter path not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "[OK] Setup Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Summary:" -ForegroundColor Cyan
Write-Host "   - Flutter path: $flutterPath" -ForegroundColor White
Write-Host "   - Added to User PATH: Yes" -ForegroundColor White
Write-Host "   - Environment variables: Configured" -ForegroundColor White
Write-Host ""
Write-Host "[*] Next steps:" -ForegroundColor Cyan
Write-Host "   1. Close and reopen PowerShell to use Flutter" -ForegroundColor White
Write-Host "   2. Test: flutter --version" -ForegroundColor White
Write-Host "   3. If flutter doctor is still slow, check:" -ForegroundColor White
Write-Host "      - Network connection" -ForegroundColor Gray
Write-Host "      - Firewall settings" -ForegroundColor Gray
Write-Host "      - Antivirus exclusions for Flutter folder" -ForegroundColor Gray
Write-Host ""
Write-Host "[*] Tip: To speed up flutter doctor, you can:" -ForegroundColor Cyan
Write-Host "   - Run: flutter doctor --android-licenses (if needed)" -ForegroundColor White
Write-Host "   - Add Flutter folder to antivirus exclusions" -ForegroundColor White
Write-Host "   - Use: flutter doctor -v (for verbose output to see what's slow)" -ForegroundColor White
Write-Host ""

