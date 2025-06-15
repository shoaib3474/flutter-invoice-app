import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/repositories/reconciliation_repository.dart';

class ReconciliationProvider with ChangeNotifier {
  ReconciliationProvider(this._repository);
  final ReconciliationRepository _repository;

  // State variables
  List<ReconciliationResult> _reconciliationResults = [];
  ReconciliationResult? _selectedResult;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReconciliationResult> get reconciliationResults =>
      _reconciliationResults;
  ReconciliationResult? get selectedResult => _selectedResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all reconciliation results
  Future<void> loadAllReconciliationResults() async {
    _setLoading(true);

    try {
      _reconciliationResults = await _repository.getAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error = 'Failed to load reconciliation results: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load reconciliation results by type
  Future<void> loadReconciliationResultsByType(ReconciliationType type) async {
    _setLoading(true);

    try {
      _reconciliationResults =
          await _repository.getReconciliationResultsByType(type);
      _error = null;
    } catch (e) {
      _error = 'Failed to load reconciliation results: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load reconciliation result by ID
  Future<void> loadReconciliationResultById(String id) async {
    _setLoading(true);

    try {
      _selectedResult = await _repository.getReconciliationResultById(id);
      _error = null;
    } catch (e) {
      _error = 'Failed to load reconciliation result: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Reconcile GSTR-1 with GSTR-2A
  Future<void> reconcileGSTR1WithGSTR2A(String gstin, String period) async {
    _setLoading(true);

    try {
      _selectedResult =
          await _repository.reconcileGSTR1WithGSTR2A(gstin, period);
      await loadAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error = 'Failed to reconcile GSTR-1 with GSTR-2A: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Reconcile GSTR-1 with GSTR-3B
  Future<void> reconcileGSTR1WithGSTR3B(String gstin, String period) async {
    _setLoading(true);

    try {
      _selectedResult =
          await _repository.reconcileGSTR1WithGSTR3B(gstin, period);
      await loadAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error = 'Failed to reconcile GSTR-1 with GSTR-3B: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Reconcile GSTR-2A with GSTR-2B
  Future<void> reconcileGSTR2AWithGSTR2B(String gstin, String period) async {
    _setLoading(true);

    try {
      _selectedResult =
          await _repository.reconcileGSTR2AWithGSTR2B(gstin, period);
      await loadAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error = 'Failed to reconcile GSTR-2A with GSTR-2B: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Reconcile GSTR-2B with GSTR-3B
  Future<void> reconcileGSTR2BWithGSTR3B(String gstin, String period) async {
    _setLoading(true);

    try {
      _selectedResult =
          await _repository.reconcileGSTR2BWithGSTR3B(gstin, period);
      await loadAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error = 'Failed to reconcile GSTR-2B with GSTR-3B: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Perform comprehensive reconciliation
  Future<void> performComprehensiveReconciliation(
      String gstin, String period) async {
    _setLoading(true);

    try {
      _selectedResult =
          await _repository.performComprehensiveReconciliation(gstin, period);
      await loadAllReconciliationResults();
      _error = null;
    } catch (e) {
      _error =
          'Failed to perform comprehensive reconciliation: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Export reconciliation result to JSON
  Future<String> exportReconciliationToJson(String id) async {
    _setLoading(true);

    try {
      final jsonData = await _repository.exportReconciliationToJson(id);
      _error = null;
      return jsonData;
    } catch (e) {
      _error = 'Failed to export reconciliation result: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete reconciliation result
  Future<void> deleteReconciliationResult(String id) async {
    _setLoading(true);

    try {
      await _repository.deleteReconciliationResult(id);
      await loadAllReconciliationResults();
      if (_selectedResult?.id == id) {
        _selectedResult = null;
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete reconciliation result: ${e.toString()}';
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
