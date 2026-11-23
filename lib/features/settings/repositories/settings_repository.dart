import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

/// Device-local preferences.
class SettingsRepository {
  SettingsRepository(this._box);

  final Box<dynamic> _box;

  String get languageCode => _box.get('locale', defaultValue: 'en') as String;
  Future<void> setLanguageCode(String code) => _box.put('locale', code);

  ThemeMode get themeMode => ThemeMode.values.asNameMap()[_box.get('themeMode')] ?? ThemeMode.system;
  Future<void> setThemeMode(ThemeMode mode) => _box.put('themeMode', mode.name);

  bool get onboardingDone => _box.get('onboardingDone', defaultValue: false) as bool;
  Future<void> setOnboardingDone() => _box.put('onboardingDone', true);

  String get currency => _box.get('currency', defaultValue: 'PKR') as String;
  Future<void> setCurrency(String code) => _box.put('currency', code);

  /// Returns true exactly once: when the user completes their 3rd split.
  Future<bool> registerSplitAndShouldAskReview() async {
    final count = (_box.get('splitCount', defaultValue: 0) as int) + 1;
    await _box.put('splitCount', count);
    if (count < 3 || (_box.get('reviewAsked', defaultValue: false) as bool)) return false;
    await _box.put('reviewAsked', true);
    return true;
  }
}
