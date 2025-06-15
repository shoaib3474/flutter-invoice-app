import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/error_logger_service.dart';

class FirebaseLinksWidget extends StatelessWidget {
  const FirebaseLinksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  l10n.firebaseQuickLinks!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLinkItem(
              context,
              title: l10n.crashlyticsConsole,
              description: l10n.crashlyticsDescription,
              icon: Icons.bug_report,
              color: Colors.red,
              url:
                  'https://console.firebase.google.com/project/your-project-id/crashlytics',
            ),
            _buildLinkItem(
              context,
              title: l10n.analyticsConsole,
              description: l10n.analyticsConsoleDescription,
              icon: Icons.analytics,
              color: Colors.blue,
              url:
                  'https://console.firebase.google.com/project/your-project-id/analytics',
            ),
            _buildLinkItem(
              context,
              title: l10n.performanceConsole,
              description: l10n.performanceDescription,
              icon: Icons.speed,
              color: Colors.green,
              url:
                  'https://console.firebase.google.com/project/your-project-id/performance',
            ),
            _buildLinkItem(
              context,
              title: l10n.remoteConfigConsole,
              description: l10n.remoteConfigDescription,
              icon: Icons.settings_remote,
              color: Colors.purple,
              url:
                  'https://console.firebase.google.com/project/your-project-id/config',
            ),
            _buildLinkItem(
              context,
              title: l10n.firestoreConsole,
              description: l10n.firestoreDescription,
              icon: Icons.storage,
              color: Colors.orange,
              url:
                  'https://console.firebase.google.com/project/your-project-id/firestore',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.firebaseProjectNote!,
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

  Widget _buildLinkItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyUrl(context, url),
              tooltip: 'Copy URL',
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () => _openUrl(context, url),
              tooltip: 'Open in browser',
            ),
          ],
        ),
      ),
    );
  }

  void _copyUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final errorLogger = ErrorLoggerService();

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        errorLogger.logInfo('Opened Firebase Console URL: $url');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open URL'),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () => _copyUrl(context, url),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      errorLogger.logError(
        'Failed to open URL',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'url': url},
      );
    }
  }
}
