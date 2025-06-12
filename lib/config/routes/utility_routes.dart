import 'package:go_router/go_router.dart';
import '../../screens/alert_management_screen.dart';
import '../../screens/filing_reminders_screen.dart';
import '../../screens/gstin_tracking_screen.dart';
import '../../screens/pan_search_screen.dart';
import '../../screens/hsn_sac_lookup_screen.dart';
import '../../screens/gst_payment_screen.dart';
import '../../screens/payment/stripe_payment_screen.dart';
import '../../screens/invoice_converter_home_screen.dart';
import '../../screens/batch_invoice_converter_screen.dart';
import '../../screens/qrmp_scheme_screen.dart';
import '../../screens/export_demo_screen.dart';
import '../../screens/sync_status_screen.dart';
import '../../screens/ocr/document_scanner_screen.dart';

class UtilityRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: 'alerts',
      name: 'alerts',
      builder: (context, state) => const AlertManagementScreen(),
    ),
    GoRoute(
      path: 'reminders',
      name: 'reminders',
      builder: (context, state) => const FilingRemindersScreen(),
    ),
    GoRoute(
      path: 'gstin-tracking',
      name: 'gstin-tracking',
      builder: (context, state) => const GstinTrackingScreen(),
    ),
    GoRoute(
      path: 'pan-search',
      name: 'pan-search',
      builder: (context, state) => const PanSearchScreen(),
    ),
    GoRoute(
      path: 'hsn-sac',
      name: 'hsn-sac',
      builder: (context, state) => const HsnSacLookupScreen(),
    ),
    GoRoute(
      path: 'payments',
      name: 'payments',
      builder: (context, state) => const GSTPaymentScreen(),
    ),
    GoRoute(
      path: 'stripe-payment',
      name: 'stripe-payment',
      builder: (context, state) => const StripePaymentScreen(),
    ),
    GoRoute(
      path: 'converter',
      name: 'converter',
      builder: (context, state) => const InvoiceConverterHomeScreen(),
    ),
    GoRoute(
      path: 'batch-converter',
      name: 'batch-converter',
      builder: (context, state) => const BatchInvoiceConverterScreen(),
    ),
    GoRoute(
      path: 'qrmp',
      name: 'qrmp',
      builder: (context, state) => const QRMPSchemeScreen(),
    ),
    GoRoute(
      path: 'export-demo',
      name: 'export-demo',
      builder: (context, state) => const ExportDemoScreen(),
    ),
    GoRoute(
      path: 'sync-status',
      name: 'sync-status',
      builder: (context, state) => const SyncStatusScreen(),
    ),
    GoRoute(
      path: 'document-scanner',
      name: 'document-scanner',
      builder: (context, state) => const DocumentScannerScreen(),
    ),
  ];
}
