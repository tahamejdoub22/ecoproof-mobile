# Backend Integration Guide

This guide will help you integrate your EcoProof backend with the Flutter mobile app.

## Step 1: Find Your Backend URL

### For Local Development:

1. **Find your backend port** (commonly 3000, 5000, 8000, etc.)
2. **Find your computer's IP address**:
   - Windows: Run `ipconfig` in Command Prompt
   - Mac/Linux: Run `ifconfig` in Terminal
   - Look for IPv4 address (e.g., 192.168.1.100)

### For Different Testing Scenarios:

- **Android Emulator**: Use `http://10.0.2.2:PORT`
- **iOS Simulator**: Use `http://localhost:PORT`
- **Physical Device**: Use `http://YOUR_IP:PORT`

## Step 2: Update App Configuration

Edit `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:PORT/api';
```

## Step 3: Verify Your Backend API Structure

The app expects these endpoints:

### Authentication Endpoints

1. **POST `/auth/login`**
   - Request body: `{ "email": "user@example.com", "password": "password123" }`
   - Response: 
     ```json
     {
       "token": "jwt_token",
       "refreshToken": "refresh_token",
       "user": {
         "id": "user_id",
         "email": "user@example.com",
         "name": "User Name"
       }
     }
     ```

2. **POST `/auth/register`**
   - Request body: `{ "email": "...", "password": "...", "name": "..." }`
   - Response: Same as login

3. **POST `/auth/logout`**
   - Headers: `Authorization: Bearer {token}`
   - Response: `{ "message": "Logged out" }`

4. **POST `/auth/refresh`**
   - Request body: `{ "refreshToken": "..." }`
   - Response: `{ "token": "new_jwt_token" }`

5. **GET `/user/profile`**
   - Headers: `Authorization: Bearer {token}`
   - Response: User object

## Step 4: Adjust for Your Backend

If your backend uses different:
- **Field names**: Update `UserModel.fromJson()` in `lib/core/models/user_model.dart`
- **Response structure**: Update `AuthService` methods in `lib/core/services/auth_service.dart`
- **Error format**: Update `_handleError()` in `lib/core/services/api_service.dart`

## Step 5: Test the Connection

1. Start your backend server
2. Run the Flutter app: `flutter run`
3. Try logging in with test credentials
4. Check the console for any errors

## Common Issues

### CORS Errors
If you see CORS errors, configure your backend to allow requests from your app origin.

### Connection Refused
- Check if backend is running
- Verify the IP address and port
- For Android emulator, use `10.0.2.2` instead of `localhost`

### 401 Unauthorized
- Check if token is being sent correctly
- Verify token format matches backend expectations
- Check token expiration

## Adding New Endpoints

See `lib/core/services/example_api_service.dart` for examples of how to add new API endpoints.

