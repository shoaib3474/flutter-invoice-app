import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/test/copy_commands_guide_screen.dart';
import '../../screens/test/firebase_quick_fix_screen.dart';
import '../../screens/test/firebase_setup_test_screen.dart';
import '../../screens/test/firebase_troubleshooting_screen.dart';
import '../../screens/test/migration_test_screen.dart';
import '../../screens/test/pdf_test_screen.dart';

class TestRoutes {
  static List<GoRoute> get routes => kDebugMode
      ? [
          GoRoute(
            path: '/test',
            name: 'test',
            builder: (context, state) => const TestScreensMenuScreen(),
            routes: [
              // GoRoute(
              //   path: 'pdf',
              //   name: 'pdf-test',
              //   builder: (context, state) => const PdfTestScreen(),
              // ),
              // GoRoute(
              //   path: 'migration',
              //   name: 'migration-test',
              //   builder: (context, state) => const MigrationTestScreen(),
              // ),
              // GoRoute(
              //   path: 'firebase-setup',
              //   name: 'firebase-setup-test',
              //   builder: (context, state) => const FirebaseSetupTestScreen(),
              // ),
              GoRoute(
                path: 'firebase-troubleshooting',
                name: 'firebase-troubleshooting',
                builder: (context, state) =>
                    const FirebaseTroubleshootingScreen(),
              ),
              GoRoute(
                path: 'firebase-quick-fix',
                name: 'firebase-quick-fix',
                builder: (context, state) => const FirebaseQuickFixScreen(),
              ),
              GoRoute(
                path: 'copy-commands',
                name: 'copy-commands',
                builder: (context, state) => const CopyCommandsGuideScreen(),
              ),
              GoRoute(
                path: '404-test',
                name: '404-test',
                builder: (context, state) => const TestNotFoundScreen(),
              ),
            ],
          ),
        ]
      : [];
}

class TestScreensMenuScreen extends StatelessWidget {
  const TestScreensMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screens')),
      body: const Center(
        child: Text('Test screens menu'),
      ),
    );
  }
}

class TestNotFoundScreen extends StatelessWidget {
  const TestNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404 Test')),
      body: const Center(
        child: Text('This is a test 404 page'),
      ),
    );
  }
}
