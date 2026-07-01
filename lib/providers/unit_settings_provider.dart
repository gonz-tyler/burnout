// lib/providers/unit_settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class UnitSettingsProvider extends ChangeNotifier {
  UnitSystem _unitSystem = UnitSystem.metric; // Default to Metric (kg/km)

  UnitSystem get unitSystem => _unitSystem;

  UnitSettingsProvider() {
    _loadUnitSystem();
  }

  Future<void> _loadUnitSystem() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 0 (metric) if nothing is saved
    final unitIndex = prefs.getInt('unit_system') ?? 0;
    _unitSystem = UnitSystem.values[unitIndex];
    notifyListeners();
  }

  Future<void> setUnitSystem(UnitSystem newSystem) async {
    _unitSystem = newSystem;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unit_system', newSystem.index);
  }
}
