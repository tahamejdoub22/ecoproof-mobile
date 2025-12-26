import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String? _currentLanguage = 'en';

  bool get isDarkMode => _isDarkMode;
  String? get currentLanguage => _currentLanguage;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
}

