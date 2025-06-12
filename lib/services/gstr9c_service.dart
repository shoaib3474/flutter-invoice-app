import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/gstr9c_model.dart';
import '../models/gstr9_model.dart';

class GSTR9CService {
  // Singleton pattern
  static final GSTR9CService _instance = GSTR9CService._internal();
  factory GSTR9CService() => _instance;
  GSTR9CService._internal();

  // Generate a blank GSTR9C template based on GSTR9 data
  Future<GSTR9C> generateBlankGSTR9C(GSTR9 gstr9) async {
    // Calculate turnover as per annual return from GSTR9
    final turnoverAsPerAnnualReturn = gstr9.part1.totalOutwardSupplies;
    
    return GSTR9C(
      gstin: gstr9.gstin,
      financialYear: gstr9.financialYear,
      legalName: gstr9.legalName,
      tradeName: gstr9.tradeName,
      reconciliation: GSTR9CReconciliation(
        turnoverAsPerAuditedFinancialStatements: 0.0,
        turnoverAsPerAnnualReturn: turnoverAsPerAnnualReturn,
        unReconciled: -turnoverAsPerAnnualReturn, // Initially negative since audited is 0
        reconciliationItems: [],
      ),
      auditorRecommendation: GSTR9CAuditorRecommendation(
        recommendations: [],
      ),
      taxPayable: GSTR9CTaxPayable(
        taxPayableAsPerReconciliation: 0.0,
        taxPaidAsPerAnnualReturn: gstr9.part3.taxPayableOnOutwardSupplies + gstr9.part3.taxPayableOnReverseCharge,
        differentialTaxPayable: -(gstr9.part3.taxPayableOnOutwardSupplies + gstr9.part3.taxPayableOnReverseCharge),
        interestPayable: 0.0,
      ),
      auditorDetails: '',
      certificationDetails: '',
    );
  }

  // Save GSTR9C to a JSON file
  Future<String> saveGSTR9CToJson(GSTR9C gstr9c) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'GSTR9C_${gstr9c.gstin}_${gstr9c.financialYear}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonEncode(gstr9c.toJson()));
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save GSTR9C: $e');
    }
  }

  // Load GSTR9C from a JSON file
  Future<GSTR9C> loadGSTR9CFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      return GSTR9C.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load GSTR9C: $e');
    }
  }

  // Update GSTR9C with reconciliation data
  Future<GSTR9C> updateReconciliation(
    GSTR9C gstr9c, {
    required double turnoverAsPerAuditedFinancialStatements,
    required List<GSTR9CReconciliationItem> reconciliationItems,
  }) async {
    // Calculate turnover as per annual return from GSTR9
    final turnoverAsPerAnnualReturn = gstr9c.reconciliation.turnoverAsPerAnnualReturn;
    
    // Calculate unreconciled amount
    final unReconciled = turnoverAsPerAuditedFinancialStatements - turnoverAsPerAnnualReturn;
    
    // Create updated reconciliation
    final updatedReconciliation = GSTR9CReconciliation(
      turnoverAsPerAuditedFinancialStatements: turnoverAsPerAuditedFinancialStatements,
      turnoverAsPerAnnualReturn: turnoverAsPerAnnualReturn,
      unReconciled: unReconciled,
      reconciliationItems: reconciliationItems,
    );
    
    // Return updated GSTR9C
    return GSTR9C(
      gstin: gstr9c.gstin,
      financialYear: gstr9c.financialYear,
      legalName: gstr9c.legalName,
      tradeName: gstr9c.tradeName,
      reconciliation: updatedReconciliation,
      auditorRecommendation: gstr9c.auditorRecommendation,
      taxPayable: gstr9c.taxPayable,
      auditorDetails: gstr9c.auditorDetails,
      certificationDetails: gstr9c.certificationDetails,
    );
  }

  // Update GSTR9C with auditor recommendations
  Future<GSTR9C> updateAuditorRecommendations(
    GSTR9C gstr9c, {
    required List<GSTR9CAuditorRecommendationItem> recommendations,
  }) async {
    // Create updated auditor recommendation
    final updatedAuditorRecommendation = GSTR9CAuditorRecommendation(
      recommendations: recommendations,
    );
    
    // Return updated GSTR9C
    return GSTR9C(
      gstin: gstr9c.gstin,
      financialYear: gstr9c.financialYear,
      legalName: gstr9c.legalName,
      tradeName: gstr9c.tradeName,
      reconciliation: gstr9c.reconciliation,
      auditorRecommendation: updatedAuditorRecommendation,
      taxPayable: gstr9c.taxPayable,
      auditorDetails: gstr9c.auditorDetails,
      certificationDetails: gstr9c.certificationDetails,
    );
  }

  // Update GSTR9C with tax payable data
  Future<GSTR9C> updateTaxPayable(
    GSTR9C gstr9c, {
    required double taxPayableAsPerReconciliation,
    required double taxPaidAsPerAnnualReturn,
    required double interestPayable,
  }) async {
    // Calculate differential tax payable
    final differentialTaxPayable = taxPayableAsPerReconciliation - taxPaidAsPerAnnualReturn;
    
    // Create updated tax payable
    final updatedTaxPayable = GSTR9CTaxPayable(
      taxPayableAsPerReconciliation: taxPayableAsPerReconciliation,
      taxPaidAsPerAnnualReturn: taxPaidAsPerAnnualReturn,
      differentialTaxPayable: differentialTaxPayable,
      interestPayable: interestPayable,
    );
    
    // Return updated GSTR9C
    return GSTR9C(
      gstin: gstr9c.gstin,
      financialYear: gstr9c.financialYear,
      legalName: gstr9c.legalName,
      tradeName: gstr9c.tradeName,
      reconciliation: gstr9c.reconciliation,
      auditorRecommendation: gstr9c.auditorRecommendation,
      taxPayable: updatedTaxPayable,
      auditorDetails: gstr9c.auditorDetails,
      certificationDetails: gstr9c.certificationDetails,
    );
  }

  // Update GSTR9C with auditor and certification details
  Future<GSTR9C> updateAuditorDetails(
    GSTR9C gstr9c, {
    required String auditorDetails,
    required String certificationDetails,
  }) async {
    // Return updated GSTR9C
    return GSTR9C(
      gstin: gstr9c.gstin,
      financialYear: gstr9c.financialYear,
      legalName: gstr9c.legalName,
      tradeName: gstr9c.tradeName,
      reconciliation: gstr9c.reconciliation,
      auditorRecommendation: gstr9c.auditorRecommendation,
      taxPayable: gstr9c.taxPayable,
      auditorDetails: auditorDetails,
      certificationDetails: certificationDetails,
    );
  }

  // Generate a PDF report for GSTR9C
  Future<String> generatePDFReport(GSTR9C gstr9c) async {
    // This is a placeholder for PDF generation functionality
    // In a real app, you would use a PDF generation library
    throw UnimplementedError('PDF generation not implemented yet');
  }
}
