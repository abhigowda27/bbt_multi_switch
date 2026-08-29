import 'package:bbtml_new/screens/select_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  AppThemeMode _appThemeMode = AppThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  AppThemeMode get appThemeMode => _appThemeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(AppThemeMode mode) async {
    _appThemeMode = mode;
    switch (mode) {
      case AppThemeMode.light:
        _themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        _themeMode = ThemeMode.system;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, appThemeModeToString(mode));
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(_key);
    if (storedValue != null) {
      setTheme(stringToAppThemeMode(storedValue));
    }
  }
}
