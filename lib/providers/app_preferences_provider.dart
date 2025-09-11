import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider extends ChangeNotifier {
  bool _showMoodQuiz = true;
  bool _showQuotes = true; // Example setting from old app

  bool get showMoodQuiz => _showMoodQuiz;
  bool get showQuotes => _showQuotes;

  AppPreferencesProvider() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _showMoodQuiz = prefs.getBool('showMoodQuiz') ?? true;
    _showQuotes = prefs.getBool('showQuotes') ?? true;
    notifyListeners();
  }

  Future<void> updateMoodQuizSetting(bool value) async {
    _showMoodQuiz = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showMoodQuiz', value);
  }

  Future<void> updateQuotesSetting(bool value) async {
    _showQuotes = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showQuotes', value);
  }
}
