import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/services/database/database_helper.dart';
import 'package:flutter_invoice_app/services/gstr1_service.dart';
import 'package:flutter_invoice_app/services/gstr2a_service.dart';
import 'package:flutter_invoice_app/services/gstr2b_service.dart';
import 'package:flutter_invoice_app/services/gstr3b_service.dart';
import 'package:flutter_invoice_app/services/reconciliation/reconciliation_service.dart';

class ReconciliationRepository {
  final ReconciliationService _reconciliationService;
  
  ReconciliationRepository(
    DatabaseHelper databaseHelper,
    GSTR1Service gstr1Service,
    GSTR2AService gstr2aService,
    GSTR2BService gstr2bService,
    GSTR3BService gstr3bService,
  ) : _reconciliationService = ReconciliationService(
        databaseHelper,
        gstr1Service,
        gstr2aService,
        gstr2bService,
        gstr3bService,
      );
  
  // Get all reconciliation results
  Future<List<ReconciliationResult>> getAllReconciliationResults() {
    return _reconciliationService.getAllReconciliationResults();
  }
  
  // Get reconciliation result by ID
  Future<ReconciliationResult?> getReconciliationResultById(String id) {
    return _reconciliationService.getReconciliationResultById(id);
  }
  
  // Get reconciliation results by type
  Future<List<ReconciliationResult>> getReconciliationResultsByType(
    ReconciliationType type,
  ) {
    return _reconciliationService.getReconciliationResultsByType(type);
  }
  
  // Reconcile GSTR-1 with GSTR-2A
  Future<ReconciliationResult> reconcileGSTR1WithGSTR2A(
    String gstin,
    String period,
  ) {
    return _reconciliationService.reconcileGSTR1WithGSTR2A(gstin, period);
  }
  
  // Reconcile GSTR-1 with GSTR-3B
  Future<ReconciliationResult> reconcileGSTR1WithGSTR3B(
    String gstin,
    String period,
  ) {
    return _reconciliationService.reconcileGSTR1WithGSTR3B(gstin, period);
  }
  
  // Reconcile GSTR-2A with GSTR-2B
  Future<ReconciliationResult> reconcileGSTR2AWithGSTR2B(
    String gstin,
    String period,
  ) {
    return _reconciliationService.reconcileGSTR2AWithGSTR2B(gstin, period);
  }
  
  // Reconcile GSTR-2B with GSTR-3B
  Future<ReconciliationResult> reconcileGSTR2BWithGSTR3B(
    String gstin,
    String period,
  ) {
    return _reconciliationService.reconcileGSTR2BWithGSTR3B(gstin, period);
  }
  
  // Perform comprehensive reconciliation
  Future<ReconciliationResult> performComprehensiveReconciliation(
    String gstin,
    String period,
  ) {
    return _reconciliationService.performComprehensiveReconciliation(gstin, period);
  }
  
  // Export reconciliation result to JSON
  Future<String> exportReconciliationToJson(String id) {
    return _reconciliationService.exportReconciliationToJson(id);
  }
  
  // Delete reconciliation result
  Future<void> deleteReconciliationResult(String id) {
    return _reconciliationService.deleteReconciliationResult(id);
  }
}
