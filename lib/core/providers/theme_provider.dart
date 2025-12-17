import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  AppThemeMode _currentMode = AppThemeMode.black;

  AppThemeMode get currentMode => _currentMode;
  ThemeData get currentTheme => AppTheme.getTheme(_currentMode);

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(AppThemeMode mode) async {
    _currentMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode');
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < AppThemeMode.values.length) {
      _currentMode = AppThemeMode.values[modeIndex];
    } else {
      _currentMode = AppThemeMode.black; // Default
    }
    notifyListeners();
  }
}
