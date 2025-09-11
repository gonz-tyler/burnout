import 'package:flutter/foundation.dart';

enum WeightUnit { kg, lbs }

enum DistanceUnit { km, miles }

class UserSettingsProvider extends ChangeNotifier {
  WeightUnit _weightUnit = WeightUnit.kg;
  WeightUnit get weightUnit => _weightUnit;

  void setWeightUnit(WeightUnit newUnit) {
    _weightUnit = newUnit;
    notifyListeners();
  }

  DistanceUnit _distanceUnit = DistanceUnit.km;
  DistanceUnit get distanceUnit => _distanceUnit;

  void setDistanceUnit(DistanceUnit newUnit) {
    _distanceUnit = newUnit;
    notifyListeners();
  }

  // TODO: Add logic to save/load this setting from SharedPreferences or Hive
}
