# Quick Start Guide

## 1. Install Flutter (if not already installed)

Download from: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

## 2. Get Dependencies

```bash
flutter pub get
```

## 3. Configure Backend

1. Open `lib/core/config/app_config.dart`
2. Update `baseUrl` with your backend URL:
   - Android Emulator: `http://10.0.2.2:8000/api`
   - iOS Simulator: `http://localhost:8000/api`
   - Physical Device: `http://YOUR_COMPUTER_IP:8000/api`

## 4. Find Your Computer's IP (for physical device)

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

**Mac/Linux:**
```bash
ifconfig
```
or
```bash
ip addr show
```

## 5. Run the App

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run

# Or run on a specific device
flutter run -d <device_id>
```

## 6. Test Login

1. Make sure your backend is running
2. Open the app
3. Try logging in with test credentials
4. Check console for any errors

## Troubleshooting

### "Connection refused" error
- Verify backend is running
- Check the URL in `app_config.dart`
- For Android emulator, use `10.0.2.2` not `localhost`

### "CORS" error
- Configure your backend to allow requests from your app
- For development, you may need to disable CORS checks

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Next Steps

- Customize the UI
- Add your specific features
- Add more API endpoints (see `example_api_service.dart`)
- Set up CI/CD if needed

