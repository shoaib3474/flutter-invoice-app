import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/services/theme/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Load the saved theme
  Future<void> _loadTheme() async {
    _themeMode = await _themeService.getThemeMode();
    notifyListeners();
  }
  
  // Set a specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _themeService.saveThemeMode(mode);
    notifyListeners();
  }
  
  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _themeMode = await _themeService.toggleTheme(_themeMode);
    notifyListeners();
  }
}
