import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ Fixed: Safe navigation with mounted checks and error handling
extension SafeNavigation on BuildContext {
  void _safeNavigate(String path, {Object? extra}) {
    if (mounted) {
      try {
        if (extra != null) {
          go(path, extra: extra);
        } else {
          go(path);
        }
      } catch (e) {
        debugPrint('Navigation error to $path: $e');
      }
    }
  }

  // Auth navigation
  void goToLogin() => _safeNavigate('/login');
  void goToRegister() => _safeNavigate('/register');
  void goToResetPassword() => _safeNavigate('/reset-password');

  // Main navigation
  void goToHome() => _safeNavigate('/');
  void goToSettings() => _safeNavigate('/settings');

  // Invoice navigation
  void goToInvoices() => _safeNavigate('/invoices');
  void goToCreateInvoice() => _safeNavigate('/invoices/create');
  void goToEditInvoice(String id) => _safeNavigate('/invoices/edit/$id');
  void goToInvoiceDetail(String id) => _safeNavigate('/invoices/detail/$id');

  // GST navigation
  void goToDashboard() => _safeNavigate('/dashboard');
  void goToGSTR1() => _safeNavigate('/gstr1');
  void goToGSTR3B() => _safeNavigate('/gstr3b');
  void goToGSTR4() => _safeNavigate('/gstr4');
  void goToGSTR9() => _safeNavigate('/gstr9');
  void goToGSTR9C() => _safeNavigate('/gstr9c');

  // Utility navigation
  void goToAlerts() => _safeNavigate('/alerts');
  void goToReminders() => _safeNavigate('/reminders');
  void goToGstinTracking() => _safeNavigate('/gstin-tracking');
  void goToPanSearch() => _safeNavigate('/pan-search');
  void goToHsnSac() => _safeNavigate('/hsn-sac');
  void goToPayments() => _safeNavigate('/payments');
  void goToConverter() => _safeNavigate('/converter');
  void goToQrmp() => _safeNavigate('/qrmp');

  // Build navigation
  void goToBuild() => _safeNavigate('/build');
  void goToBuildApk() => _safeNavigate('/build-apk');
  void goToInstallation() => _safeNavigate('/installation');
  void goToFirebaseSetup() => _safeNavigate('/firebase-setup');
  void goToMonitoring() => _safeNavigate('/monitoring');

  // Test navigation (debug only)
  void goToTestScreens() => _safeNavigate('/test');
  void goToFirebaseTest() => _safeNavigate('/test/firebase-setup');
  void goToDocumentScannerTest() => _safeNavigate('/test/document-scanner');
  void goToStripeConfigTest() => _safeNavigate('/test/stripe-config');
  void goTo404Test() => _safeNavigate('/test/404-test');
}
