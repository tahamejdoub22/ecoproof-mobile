# Flutter Setup Guide for Windows

## 🚨 Issue: Flutter Not Found

Flutter is not installed or not in your PATH. Follow these steps to install and configure Flutter.

## 📥 Option 1: Install Flutter (Recommended)

### Step 1: Download Flutter SDK

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download the latest Flutter SDK (ZIP file)
3. Extract to a location like:
   - `C:\src\flutter` (recommended)
   - Or `C:\Users\taha mejdoub\flutter`

### Step 2: Add Flutter to PATH

#### Method A: Using System Environment Variables (Permanent)

1. **Open System Properties**:
   - Press `Win + R`
   - Type: `sysdm.cpl`
   - Press Enter

2. **Go to Environment Variables**:
   - Click "Environment Variables" button
   - Under "User variables", find "Path"
   - Click "Edit"

3. **Add Flutter Path**:
   - Click "New"
   - Add: `C:\src\flutter\bin` (or your Flutter installation path + `\bin`)
   - Click "OK" on all dialogs

4. **Restart PowerShell/Terminal**:
   - Close all PowerShell/CMD windows
   - Open a new one
   - Test: `flutter --version`

#### Method B: Using PowerShell (Temporary - Current Session Only)

```powershell
# Add Flutter to PATH for current session
$env:PATH += ";C:\src\flutter\bin"

# Verify
flutter --version
```

### Step 3: Verify Installation

```powershell
flutter doctor
```

This will check your Flutter installation and show what's missing.

## 🔧 Option 2: Use Flutter from Specific Location (If Already Installed)

If Flutter is installed but not in PATH, you can use it directly:

```powershell
# Replace with your actual Flutter path
& "C:\src\flutter\bin\flutter.bat" pub get
```

Or add it to PATH temporarily:

```powershell
$env:PATH += ";C:\src\flutter\bin"
flutter pub get
```

## ✅ Quick Setup Script

Create a file `setup-flutter.ps1` in your project:

```powershell
# Flutter Setup Script
$flutterPath = "C:\src\flutter\bin"

if (Test-Path "$flutterPath\flutter.bat") {
    Write-Host "✅ Flutter found at: $flutterPath"
    $env:PATH += ";$flutterPath"
    Write-Host "✅ Flutter added to PATH for this session"
    flutter doctor
} else {
    Write-Host "❌ Flutter not found at: $flutterPath"
    Write-Host "Please install Flutter first:"
    Write-Host "https://docs.flutter.dev/get-started/install/windows"
}
```

Run it:
```powershell
.\setup-flutter.ps1
```

## 📋 Prerequisites Checklist

Before installing Flutter, make sure you have:

- [ ] **Windows 10 or later** (64-bit)
- [ ] **Git for Windows** - https://git-scm.com/download/win
- [ ] **Android Studio** (for Android development) - https://developer.android.com/studio
- [ ] **Visual Studio** (for Windows development) - Optional
- [ ] **Chrome** (for web development) - Optional

## 🚀 After Installation

Once Flutter is installed and in PATH:

1. **Verify Installation**:
   ```powershell
   flutter doctor
   ```

2. **Install Dependencies**:
   ```powershell
   cd C:\Users\taha mejdoub\Documents\ecoproof-mobile
   flutter pub get
   ```

3. **Check for Devices**:
   ```powershell
   flutter devices
   ```

4. **Run the App**:
   ```powershell
   flutter run
   ```

## 🐛 Common Issues

### Issue: "Flutter not found" after adding to PATH
**Solution**: Restart your terminal/PowerShell window

### Issue: "Git not found"
**Solution**: Install Git from https://git-scm.com/download/win

### Issue: "Android SDK not found"
**Solution**: Install Android Studio and set up Android SDK

### Issue: "License not accepted"
**Solution**: Run:
```powershell
flutter doctor --android-licenses
```

## 📚 Resources

- **Official Flutter Install Guide**: https://docs.flutter.dev/get-started/install/windows
- **Flutter Documentation**: https://docs.flutter.dev
- **Flutter Community**: https://flutter.dev/community

## ⚡ Quick Start (If Flutter is Already Installed)

If you know where Flutter is installed, add it to PATH for this session:

```powershell
# Example: If Flutter is at C:\src\flutter
$env:PATH += ";C:\src\flutter\bin"
flutter pub get
```

Or use the full path:

```powershell
& "C:\src\flutter\bin\flutter.bat" pub get
```

---

**Next Steps:**
1. Install Flutter SDK
2. Add to PATH
3. Run `flutter doctor` to verify
4. Run `flutter pub get` in your project

Good luck! 🚀

