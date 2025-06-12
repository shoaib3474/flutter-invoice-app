import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_invoice_app/config/environment.dart';
import 'package:flutter_invoice_app/main.dart';
import 'package:flutter_invoice_app/providers/auth_provider.dart';
import 'package:flutter_invoice_app/providers/firebase_gst_provider.dart';
import 'package:flutter_invoice_app/providers/theme_provider.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('Widget Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      EnvironmentConfig.setEnvironment(Environment.development);
      await TestHelpers.setupFirebaseForTesting();
    });

    testWidgets('App should start without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => FirebaseGstProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should show login screen initially
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Theme toggle should work', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: provider.themeMode,
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Current theme: ${provider.themeMode}'),
                      ElevatedButton(
                        onPressed: provider.toggleTheme,
                        child: const Text('Toggle Theme'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initial theme should be system
      expect(find.text('Current theme: ThemeMode.system'), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();

      // Theme should change to dark
      expect(find.text('Current theme: ThemeMode.dark'), findsOneWidget);
    });

    testWidgets('Navigation should work with go_router', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => FirebaseGstProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should start on login page
      expect(find.text('Login'), findsOneWidget);
    });

    group('Environment Configuration', () {
      test('Development environment should have correct settings', () {
        EnvironmentConfig.setEnvironment(Environment.development);
        
        expect(EnvironmentConfig.isDevelopment, isTrue);
        expect(EnvironmentConfig.enableDebugMode, isTrue);
        expect(EnvironmentConfig.appName, contains('Dev'));
        expect(EnvironmentConfig.logLevel, equals('DEBUG'));
      });

      test('Production environment should have correct settings', () {
        EnvironmentConfig.setEnvironment(Environment.production);
        
        expect(EnvironmentConfig.isProduction, isTrue);
        expect(EnvironmentConfig.enableDebugMode, isFalse);
        expect(EnvironmentConfig.appName, equals('GST Invoice'));
        expect(EnvironmentConfig.logLevel, equals('ERROR'));
      });
    });
  });
}
