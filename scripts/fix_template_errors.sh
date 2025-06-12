#!/bin/bash

echo "🔧 Fixing template-related errors..."

# Fix settings_screen.dart
cat > lib/screens/settings/settings_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'logo_settings_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Logo Settings'),
            subtitle: const Text('Manage company logo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme Settings'),
            subtitle: const Text('Customize app appearance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Test Screens'),
            subtitle: const Text('Access test and debug screens'),
            onTap: () {
              Navigator.pushNamed(context, '/test-screens');
            },
          ),
        ],
      ),
    );
  }
}
EOF

# Fix test_screens_menu_screen.dart
cat > lib/screens/settings/test_screens_menu_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../test/firebase_setup_test_screen.dart';
import '../test/firebase_troubleshooting_screen.dart';

class TestScreensMenuScreen extends StatelessWidget {
  const TestScreensMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screens'),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Firebase Setup Test'),
              subtitle: const Text('Test Firebase configuration'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirebaseSetupTestScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Firebase Troubleshooting'),
              subtitle: const Text('Diagnose Firebase issues'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirebaseTroubleshootingScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.scanner),
              title: const Text('Document Scanner Test'),
              subtitle: const Text('Test OCR functionality'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document scanner test not implemented yet')),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Stripe Config Test'),
              subtitle: const Text('Test payment configuration'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stripe config test not implemented yet')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
EOF

echo "✅ Template error fixes completed!"
EOF

```bat file="scripts/fix_template_errors.bat"
@echo off
echo 🔧 Fixing template-related errors...

echo 🔧 Fixing settings_screen.dart...
(
echo import 'package:flutter/material.dart';
echo import 'logo_settings_screen.dart';
echo import 'theme_settings_screen.dart';
echo.
echo class SettingsScreen extends StatelessWidget {
echo   const SettingsScreen^({super.key}^);
echo.
echo   @override
echo   Widget build^(BuildContext context^) {
echo     return Scaffold^(
echo       appBar: AppBar^(
echo         title: const Text^('Settings'^),
echo       ^),
echo       body: ListView^(
echo         children: [
echo           ListTile^(
echo             leading: const Icon^(Icons.image^),
echo             title: const Text^('Logo Settings'^),
echo             subtitle: const Text^('Manage company logo'^),
echo             onTap: ^(^) {
echo               Navigator.push^(
echo                 context,
echo                 MaterialPageRoute^(builder: ^(context^) =^> const LogoSettingsScreen^(^)^),
echo               ^);
echo             },
echo           ^),
echo         ],
echo       ^),
echo     ^);
echo   }
echo }
) > lib\screens\settings\settings_screen.dart

echo ✅ Template error fixes completed!
