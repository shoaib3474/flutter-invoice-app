import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../analytics/services/analytics_service.dart';

class AnalyticsTestWidget extends StatelessWidget {
  const AnalyticsTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analytics = AnalyticsService();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.analyticsTest,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.analyticsTestDescription),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _testScreenView(analytics),
                  icon: const Icon(Icons.screen_share, size: 16),
                  label: Text(l10n.screenView),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testUserAction(analytics),
                  icon: const Icon(Icons.touch_app, size: 16),
                  label: Text(l10n.userAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testBusinessEvent(analytics),
                  icon: const Icon(Icons.business, size: 16),
                  label: Text(l10n.businessEvent),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testCustomEvent(analytics),
                  icon: const Icon(Icons.star, size: 16),
                  label: Text(l10n.customEvent),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testScreenView(AnalyticsService analytics) {
    analytics.logScreenView(
      'test_screen',
      screenClass: 'MonitoringScreen',
    );
  }

  void _testUserAction(AnalyticsService analytics) {
    analytics.logUserAction(
      'test_button_clicked',
      parameters: {
        'button_name': 'analytics_test',
        'screen': 'monitoring',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void _testBusinessEvent(AnalyticsService analytics) {
    analytics.logInvoiceCreated(
      'TEST-INV-${DateTime.now().millisecondsSinceEpoch}',
      1500.0,
    );
  }

  void _testCustomEvent(AnalyticsService analytics) {
    analytics.logUserAction(
      'feature_tested',
      parameters: {
        'feature': 'firebase_monitoring',
        'test_type': 'analytics',
        'success': true,
      },
    );
  }
}
