import 'package:go_router/go_router.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/test_screens_menu_screen.dart';
import '../../screens/debug_screen.dart';
import '../../screens/app_optimization_screen.dart';
import '../../screens/database_migration_screen.dart';

class SettingsRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: 'settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'test-screens',
          name: 'test-screens',
          builder: (context, state) => const TestScreensMenuScreen(),
        ),
      ],
    ),
    GoRoute(
      path: 'debug',
      name: 'debug',
      builder: (context, state) => const DebugScreen(),
    ),
    GoRoute(
      path: 'optimization',
      name: 'optimization',
      builder: (context, state) => const AppOptimizationScreen(),
    ),
    GoRoute(
      path: 'database-migration',
      name: 'database-migration',
      builder: (context, state) => const DatabaseMigrationScreen(),
    ),
  ];
}
