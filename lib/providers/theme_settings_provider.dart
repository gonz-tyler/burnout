import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeSettingsProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  String _seedColor = 'green';

  AppThemeMode get themeMode => _themeMode;
  String get seedColor => _seedColor;

  ThemeSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = AppThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _seedColor = prefs.getString('seedColor') ?? 'green';
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setSeedColor(String color) async {
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('seedColor', color);
  }

  loadSettings() {}
}
