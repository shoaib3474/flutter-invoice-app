import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  // Get the saved theme mode from shared preferences
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0; // Default to system
    return ThemeMode.values[themeIndex];
  }
  
  // Save the theme mode to shared preferences
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
  
  // Toggle between light and dark mode
  Future<ThemeMode> toggleTheme(ThemeMode current) async {
    final newMode = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await saveThemeMode(newMode);
    return newMode;
  }
}
