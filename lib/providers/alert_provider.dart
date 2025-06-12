import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/alerts/alert_configuration_model.dart';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/repositories/alert_repository.dart';
import 'package:flutter_invoice_app/services/alerts/alert_evaluation_service.dart';

class AlertProvider with ChangeNotifier {
  final AlertRepository _alertRepository;
  final AlertEvaluationService _alertEvaluationService;

  AlertProvider(this._alertRepository, this._alertEvaluationService);

  // State variables
  List<AlertConfiguration> _alertConfigurations = [];
  List<AlertInstance> _alertInstances = [];
  bool _isLoading = false;
  String? _error;
  int _unacknowledgedCount = 0;

  // Getters
  List<AlertConfiguration> get alertConfigurations => _alertConfigurations;
  List<AlertInstance> get alertInstances => _alertInstances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unacknowledgedCount => _unacknowledgedCount;

  // Load alert configurations
  Future<void> loadAlertConfigurations() async {
    _setLoading(true);
    try {
      _alertConfigurations = await _alertRepository.getAllAlertConfigurations();
      _error = null;
    } catch (e) {
      _error = 'Failed to load alert configurations: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load alert instances
  Future<void> loadAlertInstances() async {
    _setLoading(true);
    try {
      _alertInstances = await _alertRepository.getAllAlertInstances();
      _updateUnacknowledgedCount();
      _error = null;
    } catch (e) {
      _error = 'Failed to load alert instances: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create a new alert configuration
  Future<void> createAlertConfiguration(AlertConfiguration config) async {
    _setLoading(true);
    try {
      await _alertRepository.insertAlertConfiguration(config);
      await loadAlertConfigurations();
      _error = null;
    } catch (e) {
      _error = 'Failed to create alert configuration: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing alert configuration
  Future<void> updateAlertConfiguration(AlertConfiguration config) async {
    _setLoading(true);
    try {
      await _alertRepository.updateAlertConfiguration(config);
      await loadAlertConfigurations();
      _error = null;
    } catch (e) {
      _error = 'Failed to update alert configuration: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Delete an alert configuration
  Future<void> deleteAlertConfiguration(String id) async {
    _setLoading(true);
    try {
      await _alertRepository.deleteAlertConfiguration(id);
      await loadAlertConfigurations();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete alert configuration: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Toggle alert configuration enabled status
  Future<void> toggleAlertConfigurationEnabled(
      AlertConfiguration config, bool enabled) async {
    final updatedConfig = config.copyWith(enabled: enabled);
    await updateAlertConfiguration(updatedConfig);
  }

  // Acknowledge an alert
  Future<void> acknowledgeAlert(String id) async {
    try {
      await _alertRepository.acknowledgeAlert(id);
      await loadAlertInstances();
    } catch (e) {
      _error = 'Failed to acknowledge alert: ${e.toString()}';
      notifyListeners();
    }
  }

  // Acknowledge all alerts
  Future<void> acknowledgeAllAlerts() async {
    try {
      await _alertRepository.acknowledgeAllAlerts();
      await loadAlertInstances();
    } catch (e) {
      _error = 'Failed to acknowledge all alerts: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete an alert instance
  Future<void> deleteAlertInstance(String id) async {
    try {
      await _alertRepository.deleteAlertInstance(id);
      await loadAlertInstances();
    } catch (e) {
      _error = 'Failed to delete alert: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete all acknowledged alerts
  Future<void> deleteAllAcknowledgedAlerts() async {
    try {
      await _alertRepository.deleteAllAcknowledgedAlerts();
      await loadAlertInstances();
    } catch (e) {
      _error = 'Failed to delete acknowledged alerts: ${e.toString()}';
      notifyListeners();
    }
  }

  // Evaluate dashboard metrics against alert configurations
  Future<List<AlertInstance>> evaluateDashboardMetrics(
      ReconciliationDashboardMetrics metrics) async {
    try {
      final triggeredAlerts =
          await _alertEvaluationService.evaluateDashboardMetrics(metrics);
      await loadAlertInstances();
      return triggeredAlerts;
    } catch (e) {
      _error = 'Failed to evaluate dashboard metrics: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Evaluate reconciliation result against alert configurations
  Future<List<AlertInstance>> evaluateReconciliationResult(
      ReconciliationResult result) async {
    try {
      final triggeredAlerts =
          await _alertEvaluationService.evaluateReconciliationResult(result);
      await loadAlertInstances();
      return triggeredAlerts;
    } catch (e) {
      _error = 'Failed to evaluate reconciliation result: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to update unacknowledged count
  void _updateUnacknowledgedCount() {
    _unacknowledgedCount = _alertInstances
        .where((alert) => !alert.acknowledged)
        .length;
    notifyListeners();
  }
}
