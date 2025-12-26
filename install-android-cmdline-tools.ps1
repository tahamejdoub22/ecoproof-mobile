# Android SDK Command-Line Tools Installation Script
# This script downloads and installs the Android SDK cmdline-tools
# Usage: .\install-android-cmdline-tools.ps1

param(
    [string]$AndroidSdkPath = $null
)

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Android SDK Command-Line Tools Installation" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# Determine Android SDK path
if (-not $AndroidSdkPath) {
    $AndroidSdkPath = [Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")
    if (-not $AndroidSdkPath) {
        $AndroidSdkPath = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
    }
    if (-not $AndroidSdkPath) {
        $AndroidSdkPath = "$env:LOCALAPPDATA\Android\sdk"
    }
}

# Check if SDK path exists
if (-not (Test-Path $AndroidSdkPath)) {
    Write-Host "[X] Android SDK not found at: $AndroidSdkPath" -ForegroundColor Red
    Write-Host "   Please set ANDROID_HOME or provide the SDK path:" -ForegroundColor Yellow
    Write-Host "   .\install-android-cmdline-tools.ps1 -AndroidSdkPath `"C:\Android\sdk`"" -ForegroundColor Gray
    exit 1
}

Write-Host "[OK] Android SDK found at: $AndroidSdkPath" -ForegroundColor Green

# Check if cmdline-tools already exists
$cmdlineToolsPath = Join-Path $AndroidSdkPath "cmdline-tools"
if (Test-Path "$cmdlineToolsPath\latest") {
    Write-Host "[OK] cmdline-tools already installed at: $cmdlineToolsPath\latest" -ForegroundColor Green
    Write-Host "   No action needed!" -ForegroundColor Green
    exit 0
}

# Create cmdline-tools directory
Write-Host ""
Write-Host "[*] Creating cmdline-tools directory..." -ForegroundColor Cyan
if (-not (Test-Path $cmdlineToolsPath)) {
    New-Item -ItemType Directory -Path $cmdlineToolsPath -Force | Out-Null
    Write-Host "[OK] Directory created" -ForegroundColor Green
} else {
    Write-Host "[OK] Directory already exists" -ForegroundColor Green
}

# Download cmdline-tools
Write-Host ""
Write-Host "[*] Downloading Android SDK Command-Line Tools..." -ForegroundColor Cyan
Write-Host "   This may take a few minutes depending on your internet connection..." -ForegroundColor Yellow

$tempDir = Join-Path $env:TEMP "android-cmdline-tools"
$zipFile = Join-Path $tempDir "commandlinetools-win.zip"
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"

# Create temp directory
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

try {
    # Download the file
    Write-Host "   Downloading from: $downloadUrl" -ForegroundColor Gray
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -ErrorAction Stop
    Write-Host "[OK] Download complete" -ForegroundColor Green
    
    # Extract the zip file
    Write-Host ""
    Write-Host "[*] Extracting cmdline-tools..." -ForegroundColor Cyan
    $extractPath = Join-Path $tempDir "cmdline-tools-extract"
    if (Test-Path $extractPath) {
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
    
    # Use .NET to extract (more reliable than Expand-Archive for large files)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractPath)
    Write-Host "[OK] Extraction complete" -ForegroundColor Green
    
    # Find the cmdline-tools folder in the extracted files
    $extractedFolders = Get-ChildItem -Path $extractPath -Directory
    $cmdlineToolsFolder = $null
    
    foreach ($folder in $extractedFolders) {
        if ($folder.Name -eq "cmdline-tools") {
            $cmdlineToolsFolder = $folder.FullName
            break
        }
        # Sometimes it extracts directly to a folder with version name
        if (Test-Path (Join-Path $folder.FullName "bin\sdkmanager.bat")) {
            $cmdlineToolsFolder = $folder.FullName
            break
        }
    }
    
    if (-not $cmdlineToolsFolder) {
        # Check if bin\sdkmanager.bat exists directly
        if (Test-Path (Join-Path $extractPath "bin\sdkmanager.bat")) {
            $cmdlineToolsFolder = $extractPath
        } else {
            throw "Could not find cmdline-tools in extracted files"
        }
    }
    
    # Move to SDK directory as "latest"
    Write-Host ""
    Write-Host "[*] Installing cmdline-tools to SDK..." -ForegroundColor Cyan
    $latestPath = Join-Path $cmdlineToolsPath "latest"
    
    if (Test-Path $latestPath) {
        Remove-Item -Path $latestPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # If the extracted folder is already named "cmdline-tools", move its contents
    if ((Split-Path -Leaf $cmdlineToolsFolder) -eq "cmdline-tools") {
        $contents = Get-ChildItem -Path $cmdlineToolsFolder
        New-Item -ItemType Directory -Path $latestPath -Force | Out-Null
        foreach ($item in $contents) {
            Move-Item -Path $item.FullName -Destination $latestPath -Force
        }
    } else {
        # Move the entire folder
        Move-Item -Path $cmdlineToolsFolder -Destination $latestPath -Force
    }
    
    Write-Host "[OK] cmdline-tools installed successfully!" -ForegroundColor Green
    
    # Clean up
    Write-Host ""
    Write-Host "[*] Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Cleanup complete" -ForegroundColor Green
    
} catch {
    Write-Host "[X] Error installing cmdline-tools: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "[*] Manual installation instructions:" -ForegroundColor Cyan
    Write-Host "   1. Download from: https://developer.android.com/studio#command-line-tools-only" -ForegroundColor White
    Write-Host "   2. Extract to: $cmdlineToolsPath\latest" -ForegroundColor White
    Write-Host "   3. Run: flutter doctor" -ForegroundColor White
    exit 1
}

# Verify installation
Write-Host ""
Write-Host "[*] Verifying installation..." -ForegroundColor Cyan
$sdkmanagerPath = Join-Path $latestPath "bin\sdkmanager.bat"
if (Test-Path $sdkmanagerPath) {
    Write-Host "[OK] cmdline-tools installed successfully!" -ForegroundColor Green
    Write-Host "   Location: $latestPath" -ForegroundColor Gray
} else {
    Write-Host "[!] Warning: sdkmanager.bat not found at expected location" -ForegroundColor Yellow
    Write-Host "   Please verify the installation manually" -ForegroundColor Yellow
}

# Update PATH if needed
Write-Host ""
Write-Host "[*] Checking PATH configuration..." -ForegroundColor Cyan
$binPath = Join-Path $latestPath "bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$binPath*") {
    Write-Host "[*] Adding cmdline-tools to PATH..." -ForegroundColor Cyan
    try {
        $newPath = if ($currentPath) { "$currentPath;$binPath" } else { $binPath }
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path += ";$binPath"
        Write-Host "[OK] PATH updated" -ForegroundColor Green
    } catch {
        Write-Host "[!] Warning: Could not update PATH: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] cmdline-tools already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "[OK] Installation Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Next steps:" -ForegroundColor Cyan
Write-Host "   1. Close and reopen PowerShell to load updated PATH" -ForegroundColor White
Write-Host "   2. Run: flutter doctor" -ForegroundColor White
Write-Host "   3. If prompted, accept Android licenses: flutter doctor --android-licenses" -ForegroundColor White
Write-Host ""

