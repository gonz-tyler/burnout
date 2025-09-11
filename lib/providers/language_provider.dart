// lib/providers/language_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Use Locale? (nullable) where null represents system default.
  Locale? _currentLocale;

  Locale? get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    // Add more locales here
  ];

  LanguageProvider() {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode =
        prefs.getString('languageCode') ?? 'system'; // Default to "system"

    if (languageCode == 'system') {
      _currentLocale = null;
    } else {
      _currentLocale = Locale(languageCode);
    }
    notifyListeners();
  }

  Future<void> changeLanguage(Locale? newLocale) async {
    _currentLocale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.setString('languageCode', 'system');
    } else {
      await prefs.setString('languageCode', newLocale.languageCode);
    }
  }
}
