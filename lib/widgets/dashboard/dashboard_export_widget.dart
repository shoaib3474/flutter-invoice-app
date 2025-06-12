import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard/reconciliation_dashboard_model.dart';
import '../../providers/reconciliation_dashboard_provider.dart';
import '../../services/export/dashboard_pdf_service.dart';
import '../../services/logger_service.dart';

class DashboardExportWidget extends StatelessWidget {
  final LoggerService _logger = LoggerService();
  final DashboardPdfService _pdfService = DashboardPdfService();

  DashboardExportWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReconciliationDashboardProvider>(
      builder: (context, provider, child) {
        final dashboardMetrics = provider.dashboardMetrics;
        final bool hasData = dashboardMetrics != null;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard Export',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!hasData && !provider.isLoading)
                  const Center(
                    child: Text('No dashboard data available for export'),
                  )
                else
                  Column(
                    children: [
                      _buildExportOption(
                        context,
                        title: 'Export as PDF',
                        icon: Icons.picture_as_pdf,
                        onTap: () => _exportAsPdf(context, dashboardMetrics!),
                        enabled: hasData,
                      ),
                      const Divider(),
                      _buildExportOption(
                        context,
                        title: 'Print Dashboard',
                        icon: Icons.print,
                        onTap: () => _printDashboard(context, dashboardMetrics!),
                        enabled: hasData,
                      ),
                      const Divider(),
                      _buildExportOption(
                        context,
                        title: 'Share Dashboard',
                        icon: Icons.share,
                        onTap: () => _shareDashboard(context, dashboardMetrics!),
                        enabled: hasData,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(title),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  Future<void> _exportAsPdf(BuildContext context, ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Exporting dashboard as PDF');
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      final filePath = await _pdfService.saveDashboardPdf(dashboard);
      await _pdfService.openDashboardPdf(dashboard);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('PDF saved to: $filePath'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              await _pdfService.openDashboardPdf(dashboard);
            },
          ),
        ),
      );
    } catch (e) {
      _logger.error('Error exporting dashboard as PDF', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printDashboard(BuildContext context, ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Printing dashboard');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing to print...'),
          duration: Duration(seconds: 1),
        ),
      );

      await _pdfService.printDashboardPdf(dashboard);
    } catch (e) {
      _logger.error('Error printing dashboard', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error printing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareDashboard(BuildContext context, ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Sharing dashboard');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing to share...'),
          duration: Duration(seconds: 1),
        ),
      );

      await _pdfService.shareDashboardPdf(dashboard);
    } catch (e) {
      _logger.error('Error sharing dashboard', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
