# Flutter Installation Fix Guide

## 🚨 Problems You're Experiencing

1. **Flutter works in Git Bash but `flutter doctor` is very slow**
2. **Flutter doesn't work in PowerShell**

## ✅ Quick Fix

### Step 1: Run the Fix Script

Open PowerShell in your project directory and run:

```powershell
.\fix-flutter-path.ps1
```

This script will:
- ✅ Find your Flutter installation
- ✅ Add Flutter to PowerShell PATH permanently
- ✅ Configure environment variables to speed up Flutter
- ✅ Test flutter doctor

### Step 2: Restart PowerShell

After running the script, **close and reopen PowerShell** for the PATH changes to take effect.

### Step 3: Verify It Works

In the new PowerShell window:

```powershell
flutter --version
flutter doctor
```

## 🔍 If Flutter Doctor is Still Slow

Run the diagnostic script:

```powershell
.\diagnose-flutter.ps1
```

This will help identify the issue. Common causes:

### 1. Network Issues
- **Solution**: Check your internet connection
- Flutter needs to connect to Google servers

### 2. Firewall Blocking
- **Solution**: Allow Flutter through Windows Firewall
- Add Flutter folder to firewall exceptions

### 3. Antivirus Scanning
- **Solution**: Add Flutter folder to antivirus exclusions
- Example: `C:\src\flutter` (or wherever Flutter is installed)

### 4. Git Bash PATH vs PowerShell PATH
- Git Bash and PowerShell use different PATH configurations
- The fix script adds Flutter to Windows User PATH (works for both)

## 📝 Manual Fix (If Scripts Don't Work)

### Add Flutter to PowerShell PATH Manually

1. **Find Flutter Installation**
   - Common locations:
     - `C:\src\flutter\bin`
     - `C:\flutter\bin`
     - `%LOCALAPPDATA%\Android\flutter\bin`

2. **Add to User PATH**
   - Press `Win + R`
   - Type: `sysdm.cpl` and press Enter
   - Click "Environment Variables"
   - Under "User variables", select "Path" and click "Edit"
   - Click "New" and add your Flutter `bin` folder path
   - Click "OK" on all dialogs

3. **Restart PowerShell**

### Speed Up Flutter Doctor

Add these environment variables (User level):

1. Open Environment Variables (same as above)
2. Under "User variables", click "New"
3. Add these variables:

   **Variable**: `FLUTTER_STORAGE_BASE_URL`  
   **Value**: `https://storage.flutter-io.cn`

   **Variable**: `PUB_HOSTED_URL`  
   **Value**: `https://pub.flutter-io.cn`

4. Restart PowerShell

### Disable Analytics (Optional)

```powershell
flutter config --no-analytics
```

This can speed up Flutter commands slightly.

## 🐛 Troubleshooting

### Flutter Not Found After Adding to PATH

1. **Restart PowerShell** (PATH changes require restart)
2. **Check the path is correct**: The path should end with `\bin`
3. **Verify Flutter exists**: Check that `flutter.bat` exists in that folder

### Flutter Doctor Hangs Forever

1. **Check network**: `ping storage.googleapis.com`
2. **Try verbose mode**: `flutter doctor -v` (shows what's hanging)
3. **Check antivirus**: Temporarily disable to test
4. **Try offline mode**: `flutter doctor --no-version-check`

### Git Bash Works But PowerShell Doesn't

- Git Bash uses a different PATH configuration
- The fix script adds Flutter to Windows User PATH (works for both)
- After running the script, both should work

## 📚 Additional Resources

- [Official Flutter Windows Install Guide](https://docs.flutter.dev/get-started/install/windows)
- [Flutter Troubleshooting](https://docs.flutter.dev/troubleshooting)

## ✅ Verification Checklist

After fixing, verify:

- [ ] `flutter --version` works in PowerShell
- [ ] `flutter doctor` completes (even if slow)
- [ ] Flutter is in User PATH (check with `$env:PATH`)
- [ ] Environment variables are set
- [ ] No antivirus blocking Flutter

---

**Need Help?** Run `.\diagnose-flutter.ps1` to get detailed information about your Flutter setup.

