import 'package:flutter/material.dart';
import '../../../core/services/error_logger_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../analytics/services/analytics_service.dart';

class CrashReportSimulatorWidget extends StatelessWidget {
  const CrashReportSimulatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final errorLogger = ErrorLoggerService();
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
                const Icon(Icons.science, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  l10n.crashSimulator,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.crashSimulatorDescription),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _simulateAuthError(errorLogger, analytics),
                  icon: const Icon(Icons.login, size: 16),
                  label: Text(l10n.authError),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _simulateNetworkError(errorLogger, analytics),
                  icon: const Icon(Icons.wifi_off, size: 16),
                  label: Text(l10n.networkError),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _simulateValidationError(errorLogger, analytics),
                  icon: const Icon(Icons.error, size: 16),
                  label: Text(l10n.validationError),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _simulateCriticalError(errorLogger, analytics),
                  icon: const Icon(Icons.dangerous, size: 16),
                  label: Text(l10n.criticalError),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.crashSimulatorNote,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateAuthError(ErrorLoggerService errorLogger, AnalyticsService analytics) {
    try {
      // Simulate authentication error
      throw Exception('Invalid credentials provided');
    } catch (e, stackTrace) {
      errorLogger.logError(
        'Authentication failed',
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'feature': 'auth',
          'operation': 'login',
          'email': 'test@example.com',
          'attempt_count': 3,
        },
      );
      
      analytics.logError('auth_error', 'Invalid credentials');
    }
  }

  void _simulateNetworkError(ErrorLoggerService errorLogger, AnalyticsService analytics) {
    errorLogger.logNetworkError(
      '/api/gst/returns',
      500,
      'Internal Server Error',
      requestData: {
        'gstin': '29ABCDE1234F1Z5',
        'return_type': 'GSTR1',
        'period': '2024-01',
      },
    );
    
    analytics.logError('network_error', 'GST API timeout');
  }

  void _simulateValidationError(ErrorLoggerService errorLogger, AnalyticsService analytics) {
    errorLogger.logBusinessError(
      'invoice',
      'validation',
      'Invalid GSTIN format provided',
      context: {
        'gstin': 'INVALID_GSTIN',
        'invoice_id': 'INV-2024-001',
        'user_input': true,
      },
    );
    
    analytics.logError('validation_error', 'Invalid GSTIN format');
  }

  void _simulateCriticalError(ErrorLoggerService errorLogger, AnalyticsService analytics) {
    try {
      // Simulate critical system error
      throw StateError('Database connection lost during transaction');
    } catch (e, stackTrace) {
      errorLogger.logCritical(
        'Critical system failure',
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'feature': 'database',
          'operation': 'transaction',
          'transaction_id': 'TXN-2024-001',
          'data_loss_risk': true,
        },
      );
      
      analytics.logError('critical_error', 'Database connection lost');
    }
  }
}
