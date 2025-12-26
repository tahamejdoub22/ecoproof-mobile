class AppConfig {
  // Backend base URL - Update this with your backend URL
  // For local development, use: http://10.0.2.2:PORT (Android emulator)
  // For iOS simulator, use: http://localhost:PORT
  // For physical device, use: http://YOUR_IP:PORT
  // Default NestJS backend port is 3000
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  
  // User endpoints
  static const String profileEndpoint = '/users/profile';
  
  // Recycle Actions endpoints
  static const String submitActionEndpoint = '/recycle-actions';
  static const String myActionsEndpoint = '/recycle-actions/my-actions';
  
  // Recycling Points endpoints
  static const String recyclingPointsEndpoint = '/recycling-points';
  static const String nearestPointsEndpoint = '/recycling-points/nearest';
  
  // App configuration
  static const String appName = 'EcoProof';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
}

