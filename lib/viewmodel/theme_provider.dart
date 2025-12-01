import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString("app_theme");

    if (savedTheme == "light") {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    if (theme == AppTheme.light) {
      await prefs.setString("app_theme", "light");
    } else if (theme == AppTheme.dark) {
      await prefs.setString("app_theme", "dark");
    } else {
      await prefs.setString("app_theme", "system");
    }
  }

  void setTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
        _themeMode = ThemeMode.system;
        break;
    }

    saveTheme(theme); // ← حفظ الثيم
    notifyListeners();
  }
}
