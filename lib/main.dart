import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_provider.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/recycling_points/recycling_points_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize API service with backend URL
  final apiService = ApiService(
    baseUrl: AppConfig.baseUrl,
    prefs: prefs,
  );
  
  // Initialize auth service
  final authService = AuthService(apiService: apiService, prefs: prefs);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            apiService: apiService,
          ),
        ),
      ],
      child: const EcoProofApp(),
    ),
  );
}

class EcoProofApp extends StatelessWidget {
  const EcoProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoProof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/recycling-points': (context) => const RecyclingPointsScreen(),
      },
    );
  }
}

