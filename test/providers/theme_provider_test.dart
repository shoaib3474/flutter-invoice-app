import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/providers/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme Provider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('should initialize with system theme mode', () {
      expect(themeProvider.themeMode, equals(ThemeMode.system));
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('should toggle theme correctly', () {
      // Initial state
      expect(themeProvider.themeMode, equals(ThemeMode.system));

      // First toggle - should go to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);

      // Second toggle - should go to light
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);

      // Third toggle - should go back to system
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.system));
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('should set specific theme mode', () {
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);

      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('should notify listeners when theme changes', () {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.toggleTheme();
      expect(notified, isTrue);
    });
  });
}
