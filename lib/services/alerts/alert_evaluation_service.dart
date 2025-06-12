import 'package:flutter_invoice_app/models/alerts/alert_configuration_model.dart';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/repositories/alert_repository.dart';

class AlertEvaluationService {
  final AlertRepository _alertRepository;

  AlertEvaluationService(this._alertRepository);

  // Evaluate dashboard metrics against alert configurations
  Future<List<AlertInstance>> evaluateDashboardMetrics(
      ReconciliationDashboardMetrics metrics) async {
    final alertConfigs = await _alertRepository.getEnabledAlertConfigurations();
    final triggeredAlerts = <AlertInstance>[];

    for (final config in alertConfigs) {
      final alertInstance = _evaluateMetricAgainstConfig(config, metrics);
      if (alertInstance != null) {
        await _alertRepository.insertAlertInstance(alertInstance);
        triggeredAlerts.add(alertInstance);
      }
    }

    return triggeredAlerts;
  }

  // Evaluate a single reconciliation result against alert configurations
  Future<List<AlertInstance>> evaluateReconciliationResult(
      ReconciliationResult result) async {
    final alertConfigs = await _alertRepository.getEnabledAlertConfigurations();
    final triggeredAlerts = <AlertInstance>[];

    for (final config in alertConfigs) {
      // Skip if the config is specific to a different reconciliation type
      if (config.reconciliationType != null &&
          config.reconciliationType != result.type.toString()) {
        continue;
      }

      final alertInstance = _evaluateReconciliationAgainstConfig(config, result);
      if (alertInstance != null) {
        await _alertRepository.insertAlertInstance(alertInstance);
        triggeredAlerts.add(alertInstance);
      }
    }

    return triggeredAlerts;
  }

  // Helper method to evaluate a metric against a configuration
  AlertInstance? _evaluateMetricAgainstConfig(
      AlertConfiguration config, ReconciliationDashboardMetrics metrics) {
    double actualValue;
    String metricName = config.getMetricTypeDisplayName();

    // Extract the appropriate metric value based on the metric type
    switch (config.metricType) {
      case AlertMetricType.complianceScore:
        actualValue = metrics.complianceScore;
        break;
      case AlertMetricType.matchPercentage:
        // For overall dashboard, we use compliance score as match percentage
        actualValue = metrics.complianceScore;
        break;
      case AlertMetricType.taxDifference:
        actualValue = metrics.totalTaxDifference;
        break;
      case AlertMetricType.issueCount:
        actualValue = metrics.pendingIssues.toDouble();
        break;
      case AlertMetricType.reconciliationCount:
        actualValue = metrics.totalReconciliations.toDouble();
        break;
    }

    // Check if the condition is met
    if (_isConditionMet(config.operator, actualValue, config.threshold)) {
      // Create alert message
      final message = _createAlertMessage(
        config.name,
        metricName,
        config.getOperatorSymbol(),
        actualValue,
        config.threshold,
      );

      // Create and return alert instance
      return AlertInstance.create(
        alertConfigId: config.id,
        metricType: config.metricType,
        severity: config.severity,
        message: message,
        actualValue: actualValue,
        thresholdValue: config.threshold,
        context: 'Dashboard',
      );
    }

    return null;
  }

  // Helper method to evaluate a reconciliation result against a configuration
  AlertInstance? _evaluateReconciliationAgainstConfig(
      AlertConfiguration config, ReconciliationResult result) {
    double actualValue;
    String metricName = config.getMetricTypeDisplayName();
    final summary = result.summary;

    // Extract the appropriate metric value based on the metric type
    switch (config.metricType) {
      case AlertMetricType.complianceScore:
      case AlertMetricType.matchPercentage:
        // Calculate match percentage for this reconciliation
        final totalInvoices = summary.totalInvoices;
        final matchedInvoices = summary.matchedInvoices;
        actualValue = totalInvoices > 0
            ? (matchedInvoices / totalInvoices) * 100
            : 100;
        break;
      case AlertMetricType.taxDifference:
        actualValue = summary.totalTaxDifference;
        break;
      case AlertMetricType.issueCount:
        actualValue =
            (summary.mismatchedInvoices + summary.partiallyMatchedInvoices)
                .toDouble();
        break;
      case AlertMetricType.reconciliationCount:
        // Not applicable for a single reconciliation
        return null;
    }

    // Check if the condition is met
    if (_isConditionMet(config.operator, actualValue, config.threshold)) {
      // Create alert message
      final message = _createAlertMessage(
        config.name,
        metricName,
        config.getOperatorSymbol(),
        actualValue,
        config.threshold,
        context: 'Reconciliation ${result.type} for period ${result.period}',
      );

      // Create and return alert instance
      return AlertInstance.create(
        alertConfigId: config.id,
        metricType: config.metricType,
        severity: config.severity,
        message: message,
        actualValue: actualValue,
        thresholdValue: config.threshold,
        context: result.id,
      );
    }

    return null;
  }

  // Helper method to check if a condition is met
  bool _isConditionMet(
      AlertOperator operator, double actualValue, double threshold) {
    switch (operator) {
      case AlertOperator.lessThan:
        return actualValue < threshold;
      case AlertOperator.greaterThan:
        return actualValue > threshold;
      case AlertOperator.equalTo:
        return actualValue == threshold;
      case AlertOperator.notEqualTo:
        return actualValue != threshold;
      case AlertOperator.lessThanOrEqual:
        return actualValue <= threshold;
      case AlertOperator.greaterThanOrEqual:
        return actualValue >= threshold;
    }
  }

  // Helper method to create alert message
  String _createAlertMessage(
    String alertName,
    String metricName,
    String operatorSymbol,
    double actualValue,
    double threshold, {
    String? context,
  }) {
    final formattedActual = _formatValue(actualValue, metricName);
    final formattedThreshold = _formatValue(threshold, metricName);
    
    String message = '$alertName: $metricName is $formattedActual, which is $operatorSymbol $formattedThreshold';
    
    if (context != null) {
      message += ' in $context';
    }
    
    return message;
  }

  // Helper method to format values based on metric type
  String _formatValue(double value, String metricName) {
    if (metricName == 'Compliance Score' || metricName == 'Match Percentage') {
      return '${value.toStringAsFixed(1)}%';
    } else if (metricName == 'Tax Difference') {
      return '₹${value.toStringAsFixed(2)}';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
