# Quick platform installation with minimal output
$env:PATH += ";C:\tools\flutter\bin"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = "C:\Android\sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\sdk"

$sdkmanager = "C:\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat"

Write-Host "Installing Android 33 platform..." -ForegroundColor Cyan

# Accept licenses non-interactively
$yes = "y"
for ($i=0; $i -lt 20; $i++) { $yes += "`ny" }
$yes | & $sdkmanager --licenses --sdk_root="C:\Android\sdk" 2>&1 | Out-Null

# Install platform with minimal output
& $sdkmanager "platforms;android-33" --sdk_root="C:\Android\sdk" --verbose 2>&1 | Select-String -Pattern "(Installing|Done|Error)" | ForEach-Object { Write-Host $_ }

Write-Host "Checking installation..." -ForegroundColor Cyan
flutter config --android-sdk "C:\Android\sdk"
flutter doctor

