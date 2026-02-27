import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _lightThemeValue = 'light';
  static const String _darkThemeValue = 'dark';

  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode == _darkThemeValue) {
      return ThemeMode.dark;
    }
    return ThemeMode.light;
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggleThemeMode() async {
    await setDarkMode(!isDarkMode);
  }

  Future<void> setDarkMode(bool isDarkModeEnabled) async {
    state = isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(
      _themeModeKey,
      isDarkModeEnabled ? _darkThemeValue : _lightThemeValue,
    );
  }
}
