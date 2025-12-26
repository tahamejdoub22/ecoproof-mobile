# EcoProof Mobile App

A Flutter mobile application fully integrated with the EcoProof NestJS backend, featuring object detection, camera integration, and complete API connectivity.

## Features

- ✅ **Complete Backend Integration** - All APIs integrated (Auth, Recycle Actions, Recycling Points, Users)
- ✅ **Object Detection** - Camera-based detection with multi-frame capture
- ✅ **Real-time Validation** - Confidence, motion, and size validation before submission
- ✅ **Image Processing** - SHA-256 and perceptual hashing for duplicate detection
- ✅ **Location Services** - GPS integration with accuracy validation
- ✅ **Clean Architecture** - Separation of concerns with services, models, and providers
- ✅ **State Management** - Provider pattern for reactive UI
- ✅ **Error Handling** - User-friendly error messages with detailed validation feedback
- ✅ **Material Design 3** - Modern UI with dark mode support

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration (API URLs, etc.)
│   ├── models/          # Data models
│   ├── providers/       # State management providers
│   └── services/        # API and business logic services
└── ui/
    ├── screens/         # App screens
    ├── widgets/         # Reusable widgets
    └── theme/           # App theming
```

## Setup Instructions

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/core/config/app_config.dart` and update the `baseUrl`:

```dart
static const String baseUrl = 'http://YOUR_IP:3000/api/v1';
```

**Important Notes:**
- **Android Emulator**: Use `http://10.0.2.2:3000/api/v1`
- **iOS Simulator**: Use `http://localhost:3000/api/v1`
- **Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:3000/api/v1`)
- **Default Backend Port**: 3000 (NestJS default)

### 3. Verify Backend is Running

Make sure your EcoProof backend is running:

```bash
cd C:\Users\taha mejdoub\OneDrive\Documents\ecoproof-backend
npm run start:dev
```

The backend should be accessible at `http://localhost:3000/api/v1`

### 4. Backend Integration

The app is fully integrated with your NestJS backend. All endpoints are configured:

- ✅ Authentication: `/api/v1/auth/*`
- ✅ Recycle Actions: `/api/v1/recycle-actions/*`
- ✅ Recycling Points: `/api/v1/recycling-points/*`
- ✅ Users: `/api/v1/users/*`

**API Response Format:**

The backend uses standardized responses:

**Login Response:**
```json
{
  "token": "jwt_token_here",
  "refreshToken": "refresh_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name"
  }
}
```

**Error Response:**
```json
{
  "message": "Error message here"
}
```

### 5. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For a specific device
flutter devices
flutter run -d <device_id>
```

## Object Detection

The app includes a complete object detection system:

### Features
- Multi-frame capture (4-5 frames)
- Real-time confidence scoring
- Motion detection between frames
- Bounding box area validation
- Image hashing (SHA-256 + perceptual hash)
- Pre-submission validation

### Validation Requirements
- Confidence: ≥ 80%
- Bounding Box Area: ≥ 25% of image
- Frame Count: ≥ 4 frames
- Motion Score: ≥ 30%
- All frames within 2-second window

### Integration with ML Model

Currently uses simulated detection. To integrate your ML model:

1. Replace `_detectObject()` in `lib/core/services/object_detection_service.dart`
2. Use TensorFlow Lite, MLKit, or your custom model
3. Return confidence and bounding box coordinates

See `INTEGRATION_COMPLETE.md` for detailed documentation.

## Dependencies

### Core
- `provider` - State management
- `dio` - HTTP client with interceptors
- `shared_preferences` - Local storage

### Camera & Image
- `camera` - Camera access
- `image` - Image processing
- `image_picker` - Image selection

### Location
- `geolocator` - GPS location services
- `permission_handler` - Permission management

### Utilities
- `crypto` - SHA-256 hashing
- `connectivity_plus` - Network status

## Development

### Code Generation

If you add models with `@JsonSerializable`, run:

```bash
flutter pub run build_runner build
```

### Testing

```bash
flutter test
```

## Troubleshooting

### Connection Issues

1. **Android Emulator**: Make sure you're using `10.0.2.2` instead of `localhost`
2. **Physical Device**: Ensure your device and computer are on the same network
3. **CORS**: If your backend has CORS enabled, make sure it allows requests from your app

### Build Issues

```bash
flutter clean
flutter pub get
flutter run
```

## Quick Start

1. **Start Backend**
   ```bash
   cd C:\Users\taha mejdoub\OneDrive\Documents\ecoproof-backend
   npm run start:dev
   ```

2. **Update Backend URL** in `lib/core/config/app_config.dart`

3. **Run App**
   ```bash
   flutter pub get
   flutter run
   ```

4. **Test Flow**
   - Login/Register
   - Browse Recycling Points
   - Select Material Type
   - Capture Object with Camera
   - Submit Action

## Documentation

- **[Complete Integration Guide](./INTEGRATION_COMPLETE.md)** - Full integration details
- **[Backend Integration](./BACKEND_INTEGRATION.md)** - Backend setup guide
- **[Quick Start](./QUICK_START.md)** - Quick setup instructions

## Next Steps

1. ✅ Backend integration - **COMPLETE**
2. ✅ Object detection - **COMPLETE**
3. ⏳ Integrate actual ML model (replace simulation)
4. ⏳ Add offline support
5. ⏳ Add map view for recycling points
6. ⏳ Add action history screen
7. ⏳ Add rewards dashboard

## License

This project is part of the EcoProof ecosystem.