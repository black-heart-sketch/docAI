import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('fr'), // French
    Locale('es'), // Spanish
    Locale('ar'), // Arabic
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> setLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _currentLocale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      final locale = Locale(languageCode);
      if (supportedLocales.contains(locale)) {
        _currentLocale = locale;
        notifyListeners();
      }
    }
  }
}
