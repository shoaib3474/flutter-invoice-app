import 'package:go_router/go_router.dart';
import '../../screens/dashboard/gst_dashboard_screen.dart';
import '../../screens/gstr1_screen.dart';
import '../../screens/gstr3b_screen.dart';
import '../../screens/gstr4_screen.dart';
import '../../screens/gstr9_screen.dart';
import '../../screens/gstr9c_screen.dart';
import '../../screens/reconciliation_screen.dart';
import '../../screens/reconciliation_dashboard_screen.dart';
import '../../screens/reconciliation_history_screen.dart';

class GSTRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: '/gst/dashboard',
      name: 'gst-dashboard',
      builder: (context, state) => const GstDashboardScreen(),
    ),
    GoRoute(
      path: '/gst/gstr1',
      name: 'gstr1',
      builder: (context, state) => const GSTR1Screen(),
    ),
    GoRoute(
      path: '/gst/gstr3b',
      name: 'gstr3b',
      builder: (context, state) => const GSTR3BScreen(),
    ),
    GoRoute(
      path: '/gst/gstr4',
      name: 'gstr4',
      builder: (context, state) => const GSTR4Screen(),
    ),
    GoRoute(
      path: '/gst/gstr9',
      name: 'gstr9',
      builder: (context, state) => const GSTR9Screen(),
    ),
    GoRoute(
      path: '/gst/gstr9c',
      name: 'gstr9c',
      builder: (context, state) => const GSTR9CScreen(),
    ),
    GoRoute(
      path: '/gst/reconciliation',
      name: 'reconciliation',
      builder: (context, state) => const ReconciliationScreen(),
    ),
    GoRoute(
      path: '/gst/reconciliation-dashboard',
      name: 'reconciliation-dashboard',
      builder: (context, state) => const ReconciliationDashboardScreen(),
    ),
    GoRoute(
      path: '/gst/reconciliation-history',
      name: 'reconciliation-history',
      builder: (context, state) => const ReconciliationHistoryScreen(),
    ),
  ];
}
