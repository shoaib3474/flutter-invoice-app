import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/alerts/alert_configuration_model.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:flutter_invoice_app/widgets/alerts/alert_configuration_form_widget.dart';
import 'package:provider/provider.dart';

class AlertConfigurationListWidget extends StatelessWidget {
  const AlertConfigurationListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final configs = provider.alertConfigurations;

        if (configs.isEmpty) {
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
                  'No alert configurations found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first alert configuration',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Alert Configuration'),
                  onPressed: () => _showCreateAlertDialog(context),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert Configurations (${configs.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    onPressed: () => _showCreateAlertDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: configs.length,
                itemBuilder: (context, index) {
                  final config = configs[index];
                  return _buildConfigItem(context, config, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfigItem(
      BuildContext context, AlertConfiguration config, AlertProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(
          config.getSeverityIcon(),
          color: config.getSeverityColor(),
          size: 28,
        ),
        title: Text(
          config.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: config.enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${config.getMetricTypeDisplayName()} ${config.getOperatorSymbol()} ${_formatThreshold(config)}',
              style: TextStyle(
                color: config.enabled ? null : Colors.grey,
              ),
            ),
            if (config.reconciliationType != null)
              Text(
                'Type: ${config.reconciliationType!.split('.').last}',
                style: TextStyle(
                  fontSize: 12,
                  color: config.enabled ? Colors.grey.shade600 : Colors.grey,
                ),
              ),
            if (config.description != null && config.description!.isNotEmpty)
              Text(
                config.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: config.enabled ? Colors.grey.shade600 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: config.enabled,
              onChanged: (value) {
                provider.toggleAlertConfigurationEnabled(config, value);
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAlertDialog(context, config);
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, config);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: (config.reconciliationType != null) ||
            (config.description != null && config.description!.isNotEmpty),
      ),
    );
  }

  String _formatThreshold(AlertConfiguration config) {
    if (config.metricType == AlertMetricType.complianceScore ||
        config.metricType == AlertMetricType.matchPercentage) {
      return '${config.threshold}%';
    } else if (config.metricType == AlertMetricType.taxDifference) {
      return '₹${config.threshold}';
    } else {
      return config.threshold.toString();
    }
  }

  void _showCreateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Alert Configuration'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: AlertConfigurationFormWidget(
                onSaved: () {
                  // Refresh the list after saving
                  Provider.of<AlertProvider>(context, listen: false)
                      .loadAlertConfigurations();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditAlertDialog(
      BuildContext context, AlertConfiguration config) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Alert Configuration'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: AlertConfigurationFormWidget(
                initialConfig: config,
                onSaved: () {
                  // Refresh the list after saving
                  Provider.of<AlertProvider>(context, listen: false)
                      .loadAlertConfigurations();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, AlertConfiguration config) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Alert Configuration'),
          content: Text(
              'Are you sure you want to delete the alert configuration "${config.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AlertProvider>(context, listen: false)
                    .deleteAlertConfiguration(config.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}
