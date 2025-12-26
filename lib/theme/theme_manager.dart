// lib/theme/theme_manager.dart
import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // This tells the app to rebuild with the new theme
  }
}