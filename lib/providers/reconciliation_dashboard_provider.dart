import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/services/dashboard/reconciliation_dashboard_service.dart';

class ReconciliationDashboardProvider with ChangeNotifier {
  final ReconciliationDashboardService _dashboardService;
  
  ReconciliationDashboardProvider(this._dashboardService);
  
  // State variables
  ReconciliationDashboardMetrics? _dashboardMetrics;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  ReconciliationDashboardMetrics? get dashboardMetrics => _dashboardMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load dashboard metrics
  Future<void> loadDashboardMetrics() async {
    _setLoading(true);
    
    try {
      _dashboardMetrics = await _dashboardService.getDashboardMetrics();
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard metrics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
