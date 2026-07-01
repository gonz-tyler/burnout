// lib/providers/gender_settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { male, female, unselected }

class GenderSettingsProvider extends ChangeNotifier {
  Gender _gender = Gender.unselected;

  Gender get gender => _gender;

  GenderSettingsProvider() {
    _loadGender();
  }

  Future<void> _loadGender() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 2 (unselected) if nothing is saved
    final genderIndex = prefs.getInt('user_gender') ?? 2;
    _gender = Gender.values[genderIndex];
    notifyListeners();
  }

  Future<void> setGender(Gender newGender) async {
    _gender = newGender;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_gender', newGender.index);
  }
}
