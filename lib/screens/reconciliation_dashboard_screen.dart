import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:flutter_invoice_app/providers/reconciliation_dashboard_provider.dart';
import 'package:flutter_invoice_app/screens/alert_management_screen.dart';
import 'package:flutter_invoice_app/screens/reconciliation_screen.dart';
import 'package:flutter_invoice_app/services/logger_service.dart';
import 'package:flutter_invoice_app/widgets/alerts/alert_badge_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/compliance_score_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/dashboard_export_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/monthly_trend_chart_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/recent_reconciliations_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/reconciliation_type_chart_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/summary_metrics_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/top_discrepancies_widget.dart';
import 'package:provider/provider.dart';

class ReconciliationDashboardScreen extends StatefulWidget {
  const ReconciliationDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ReconciliationDashboardScreen> createState() =>
      _ReconciliationDashboardScreenState();
}

class _ReconciliationDashboardScreenState
    extends State<ReconciliationDashboardScreen> {
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing ReconciliationDashboardScreen');
    // Load dashboard metrics when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _logger.info('Loading dashboard metrics');
      final dashboardProvider =
          Provider.of<ReconciliationDashboardProvider>(context, listen: false);
      await dashboardProvider.loadDashboardMetrics();

      // Evaluate dashboard metrics against alert configurations
      if (dashboardProvider.dashboardMetrics != null) {
        _logger.info('Evaluating dashboard metrics against alert configurations');
        final alertProvider =
            Provider.of<AlertProvider>(context, listen: false);
        final triggeredAlerts = await alertProvider
            .evaluateDashboardMetrics(dashboardProvider.dashboardMetrics!);

        // Show alert notification if new alerts were triggered
        if (triggeredAlerts.isNotEmpty) {
          _logger.info('${triggeredAlerts.length} new alerts triggered');
          _showAlertNotification(triggeredAlerts);
        }
      }
    });
  }

  void _showAlertNotification(List<AlertInstance> alerts) {
    if (!mounted) return;

    final criticalAlerts =
        alerts.where((a) => a.severity == AlertSeverity.critical).length;
    final warningAlerts =
        alerts.where((a) => a.severity == AlertSeverity.warning).length;
    final infoAlerts =
        alerts.where((a) => a.severity == AlertSeverity.info).length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'New alerts: ${alerts.length} (${criticalAlerts > 0 ? '$criticalAlerts critical, ' : ''}${warningAlerts > 0 ? '$warningAlerts warnings, ' : ''}${infoAlerts > 0 ? '$infoAlerts info' : ''})'.trim().replaceAll(RegExp(r', $'), ''),
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlertManagementScreen(),
              ),
            );
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Reconciliation Dashboard'),
        actions: [
          AlertBadgeWidget(
            child: IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'Alerts',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertManagementScreen(),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlertManagementScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              _logger.info('Manually refreshing dashboard metrics');
              final dashboardProvider =
                  Provider.of<ReconciliationDashboardProvider>(context, listen: false);
              await dashboardProvider.loadDashboardMetrics();

              // Evaluate dashboard metrics against alert configurations
              if (dashboardProvider.dashboardMetrics != null) {
                final alertProvider =
                    Provider.of<AlertProvider>(context, listen: false);
                final triggeredAlerts = await alertProvider
                    .evaluateDashboardMetrics(dashboardProvider.dashboardMetrics!);

                // Show alert notification if new alerts were triggered
                if (triggeredAlerts.isNotEmpty) {
                  _showAlertNotification(triggeredAlerts);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Reconciliation',
            onPressed: () {
              _logger.info('Navigating to ReconciliationScreen');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReconciliationScreen(),
                ),
              ).then((_) {
                // Refresh dashboard after returning from reconciliation screen
                _logger.info('Returned from ReconciliationScreen, refreshing dashboard');
                Provider.of<ReconciliationDashboardProvider>(context, listen: false)
                    .loadDashboardMetrics();
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _logger.info('Showing export options');
                _showExportOptions(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Dashboard'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ReconciliationDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            _logger.warning('Error loading dashboard: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _logger.info('Retrying dashboard load after error');
                      provider.loadDashboardMetrics();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final metrics = provider.dashboardMetrics;
          if (metrics == null) {
            return const Center(
              child: Text('No dashboard data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              _logger.info('Pull-to-refresh triggered for dashboard');
              return provider.loadDashboardMetrics();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary metrics
                  SummaryMetricsWidget(
                    totalReconciliations: metrics.totalReconciliations,
                    pendingIssues: metrics.pendingIssues,
                    totalTaxDifference: metrics.totalTaxDifference,
                  ),
                  const SizedBox(height: 16),

                  // Compliance score and reconciliation type chart
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ComplianceScoreWidget(
                          complianceScore: metrics.complianceScore,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ReconciliationTypeChartWidget(
                          typeMetrics: metrics.reconciliationTypeMetrics,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Monthly trend chart
                  MonthlyTrendChartWidget(
                    monthlyMetrics: metrics.monthlyMetrics,
                  ),
                  const SizedBox(height: 16),

                  // Top discrepancies and recent reconciliations
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TopDiscrepanciesWidget(
                          topDiscrepancies: metrics.topDiscrepancies,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RecentReconciliationsWidget(
                          recentReconciliations: metrics.recentReconciliations,
                          onViewDetails: (id) {
                            _logger.info('Viewing details for reconciliation $id');
                            // Navigate to reconciliation details screen
                            // Implementation depends on your navigation structure
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Dashboard Export Widget
                  DashboardExportWidget(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _logger.info('Creating new reconciliation from FAB');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReconciliationScreen(),
            ),
          ).then((_) {
            // Refresh dashboard after returning from reconciliation screen
            _logger.info('Returned from ReconciliationScreen via FAB, refreshing dashboard');
            Provider.of<ReconciliationDashboardProvider>(context, listen: false)
                .loadDashboardMetrics();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New Reconciliation'),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DashboardExportWidget(),
    );
  }
}
