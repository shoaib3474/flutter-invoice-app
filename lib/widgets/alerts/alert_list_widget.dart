import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AlertListWidget extends StatelessWidget {
  const AlertListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final alerts = provider.alertInstances;

        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No alerts found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You have no alerts at this time',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alerts (${alerts.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Acknowledge All'),
                        onPressed: provider.unacknowledgedCount > 0
                            ? () => provider.acknowledgeAllAlerts()
                            : null,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear Acknowledged'),
                        onPressed: alerts.any((alert) => alert.acknowledged)
                            ? () => provider.deleteAllAcknowledgedAlerts()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertItem(context, alert, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertItem(
      BuildContext context, AlertInstance alert, AlertProvider provider) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final formattedDate = dateFormat.format(alert.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: alert.acknowledged ? null : Colors.grey.shade50,
      child: ListTile(
        leading: Icon(
          alert.severity.index == 0
              ? Icons.info_outline
              : alert.severity.index == 1
                  ? Icons.warning_amber_outlined
                  : Icons.error_outline,
          color: alert.severity.index == 0
              ? Colors.blue
              : alert.severity.index == 1
                  ? Colors.orange
                  : Colors.red,
          size: 28,
        ),
        title: Text(
          alert.message,
          style: TextStyle(
            fontWeight:
                alert.acknowledged ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Triggered: $formattedDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (alert.acknowledged && alert.acknowledgedAt != null)
              Text(
                'Acknowledged: ${dateFormat.format(alert.acknowledgedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alert.acknowledged)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Acknowledge',
                onPressed: () => provider.acknowledgeAlert(alert.id),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => provider.deleteAlertInstance(alert.id),
            ),
          ],
        ),
        isThreeLine: alert.acknowledged && alert.acknowledgedAt != null,
      ),
    );
  }
}
