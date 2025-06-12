import 'package:go_router/go_router.dart';
import '../../screens/build/enhanced_build_screen.dart';
import '../../screens/installation/enhanced_apk_installation_screen.dart';
import '../../screens/firebase/firebase_setup_screen.dart';
import '../../screens/setup/firebase_setup_checklist_screen.dart';
import '../../features/monitoring/screens/firebase_monitoring_screen.dart';
import '../../features/build/screens/enhanced_apk_build_screen.dart';

class BuildRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: 'build',
      name: 'build',
      builder: (context, state) => const EnhancedBuildScreen(),
    ),
    GoRoute(
      path: 'build-apk',
      name: 'build-apk',
      builder: (context, state) => const EnhancedApkBuildScreen(),
    ),
    GoRoute(
      path: 'installation',
      name: 'installation',
      builder: (context, state) => const EnhancedApkInstallationScreen(),
    ),
    GoRoute(
      path: 'firebase-setup',
      name: 'firebase-setup',
      builder: (context, state) => const FirebaseSetupScreen(),
    ),
    GoRoute(
      path: 'setup-checklist',
      name: 'setup-checklist',
      builder: (context, state) => const FirebaseSetupChecklistScreen(),
    ),
    GoRoute(
      path: 'monitoring',
      name: 'monitoring',
      builder: (context, state) => const FirebaseMonitoringScreen(),
    ),
  ];
}
