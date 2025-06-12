import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr2a_model.dart' as gstr2a;
import 'package:flutter_invoice_app/models/gst_returns/gstr2b_model.dart' as gstr2b;
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/services/database/database_helper.dart';
import 'package:flutter_invoice_app/services/gstr1_service.dart';
import 'package:flutter_invoice_app/services/gstr2a_service.dart';
import 'package:flutter_invoice_app/services/gstr2b_service.dart';
import 'package:flutter_invoice_app/services/gstr3b_service.dart';
import 'package:uuid/uuid.dart';

class ReconciliationService {
  final DatabaseHelper _databaseHelper;
  final GSTR1Service _gstr1Service;
  final GSTR2AService _gstr2aService;
  final GSTR2BService _gstr2bService;
  final GSTR3BService _gstr3bService;
  final _uuid = const Uuid();

  ReconciliationService(
    this._databaseHelper,
    this._gstr1Service,
    this._gstr2aService,
    this._gstr2bService,
    this._gstr3bService,
  );

  // Fetch all reconciliation results
  Future<List<ReconciliationResult>> getAllReconciliationResults() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('reconciliation_results');
    
    return List.generate(maps.length, (i) {
      return ReconciliationResult.fromJson(maps[i]);
    });
  }

  // Fetch reconciliation result by ID
  Future<ReconciliationResult?> getReconciliationResultById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reconciliation_results',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ReconciliationResult.fromJson(maps.first);
    }
    
    return null;
  }

  // Fetch reconciliation results by type
  Future<List<ReconciliationResult>> getReconciliationResultsByType(
    ReconciliationType type,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reconciliation_results',
      where: 'type = ?',
      whereArgs: [type.toString().split('.').last],
    );
    
    return List.generate(maps.length, (i) {
      return ReconciliationResult.fromJson(maps[i]);
    });
  }

  // Save reconciliation result
  Future<String> saveReconciliationResult(ReconciliationResult result) async {
    final db = await _databaseHelper.database;
    final id = _uuid.v4();
    
    final resultMap = result.toJson();
    resultMap['id'] = id;
    
    await db.insert(
      'reconciliation_results',
      resultMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  // Update reconciliation result
  Future<void> updateReconciliationResult(
    String id,
    ReconciliationResult result,
  ) async {
    final db = await _databaseHelper.database;
    
    final resultMap = result.toJson();
    resultMap['id'] = id;
    
    await db.update(
      'reconciliation_results',
      resultMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete reconciliation result
  Future<void> deleteReconciliationResult(String id) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'reconciliation_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reconcile GSTR-1 with GSTR-2A
  Future<ReconciliationResult> reconcileGSTR1WithGSTR2A(
    String gstin,
    String period,
  ) async {
    try {
      // Fetch GSTR-1 and GSTR-2A data
      final gstr1 = await _gstr1Service.getGSTR1ByPeriod(gstin, period);
      final gstr2a = await _gstr2aService.getGSTR2AByPeriod(gstin, period);
      
      if (gstr1 == null || gstr2a == null) {
        throw Exception('GSTR-1 or GSTR-2A data not found for the specified period');
      }
      
      // Create maps for quick lookup
      final gstr1Invoices = <String, B2BInvoice>{};
      for (var invoice in gstr1.b2bInvoices) {
        final key = '${invoice.invoiceNumber}_${invoice.invoiceDate.toIso8601String()}_${invoice.counterpartyGstin}';
        gstr1Invoices[key] = invoice;
      }
      
      final gstr2aInvoices = <String, gstr2a.B2BInvoice>{};
      for (var invoice in gstr2a.b2bInvoices) {
        final key = '${invoice.invoiceNumber}_${invoice.invoiceDate.toIso8601String()}_${invoice.counterpartyGstin}';
        gstr2aInvoices[key] = invoice;
      }
      
      // Reconcile invoices
      final reconciliationItems = <ReconciliationItem>[];
      final allInvoiceKeys = {...gstr1Invoices.keys, ...gstr2aInvoices.keys};
      
      int matchedCount = 0;
      int partiallyMatchedCount = 0;
      int mismatchedCount = 0;
      int onlyInGSTR1Count = 0;
      int onlyInGSTR2ACount = 0;
      
      double totalTaxableValueGSTR1 = 0;
      double totalTaxableValueGSTR2A = 0;
      double totalIgstGSTR1 = 0;
      double totalIgstGSTR2A = 0;
      double totalCgstGSTR1 = 0;
      double totalCgstGSTR2A = 0;
      double totalSgstGSTR1 = 0;
      double totalSgstGSTR2A = 0;
      
      for (var key in allInvoiceKeys) {
        final gstr1Invoice = gstr1Invoices[key];
        final gstr2aInvoice = gstr2aInvoices[key];
        
        if (gstr1Invoice != null) {
          totalTaxableValueGSTR1 += gstr1Invoice.taxableValue;
          totalIgstGSTR1 += gstr1Invoice.igstAmount;
          totalCgstGSTR1 += gstr1Invoice.cgstAmount;
          totalSgstGSTR1 += gstr1Invoice.sgstAmount;
        }
        
        if (gstr2aInvoice != null) {
          totalTaxableValueGSTR2A += gstr2aInvoice.taxableValue;
          totalIgstGSTR2A += gstr2aInvoice.igstAmount;
          totalCgstGSTR2A += gstr2aInvoice.cgstAmount;
          totalSgstGSTR2A += gstr2aInvoice.sgstAmount;
        }
        
        if (gstr1Invoice != null && gstr2aInvoice != null) {
          // Both invoices exist, check for discrepancies
          final discrepancies = <String>[];
          
          if (gstr1Invoice.taxableValue != gstr2aInvoice.taxableValue) {
            discrepancies.add('Taxable value mismatch');
          }
          
          if (gstr1Invoice.igstAmount != gstr2aInvoice.igstAmount) {
            discrepancies.add('IGST amount mismatch');
          }
          
          if (gstr1Invoice.cgstAmount != gstr2aInvoice.cgstAmount) {
            discrepancies.add('CGST amount mismatch');
          }
          
          if (gstr1Invoice.sgstAmount != gstr2aInvoice.sgstAmount) {
            discrepancies.add('SGST amount mismatch');
          }
          
          MatchStatus matchStatus;
          if (discrepancies.isEmpty) {
            matchStatus = MatchStatus.matched;
            matchedCount++;
          } else if (discrepancies.length < 4) {
            matchStatus = MatchStatus.partiallyMatched;
            partiallyMatchedCount++;
          } else {
            matchStatus = MatchStatus.mismatched;
            mismatchedCount++;
          }
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr1Invoice.invoiceNumber,
              invoiceDate: gstr1Invoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr1Invoice.counterpartyGstin,
              counterpartyName: gstr1Invoice.counterpartyName,
              taxableValueSource1: gstr1Invoice.taxableValue,
              taxableValueSource2: gstr2aInvoice.taxableValue,
              igstSource1: gstr1Invoice.igstAmount,
              igstSource2: gstr2aInvoice.igstAmount,
              cgstSource1: gstr1Invoice.cgstAmount,
              cgstSource2: gstr2aInvoice.cgstAmount,
              sgstSource1: gstr1Invoice.sgstAmount,
              sgstSource2: gstr2aInvoice.sgstAmount,
              matchStatus: matchStatus,
              discrepancies: discrepancies.isNotEmpty ? discrepancies : null,
            ),
          );
        } else if (gstr1Invoice != null) {
          // Invoice only in GSTR-1
          onlyInGSTR1Count++;
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr1Invoice.invoiceNumber,
              invoiceDate: gstr1Invoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr1Invoice.counterpartyGstin,
              counterpartyName: gstr1Invoice.counterpartyName,
              taxableValueSource1: gstr1Invoice.taxableValue,
              igstSource1: gstr1Invoice.igstAmount,
              cgstSource1: gstr1Invoice.cgstAmount,
              sgstSource1: gstr1Invoice.sgstAmount,
              matchStatus: MatchStatus.onlyInSource1,
              remarks: 'Invoice present in GSTR-1 but not in GSTR-2A',
            ),
          );
        } else if (gstr2aInvoice != null) {
          // Invoice only in GSTR-2A
          onlyInGSTR2ACount++;
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr2aInvoice.invoiceNumber,
              invoiceDate: gstr2aInvoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr2aInvoice.counterpartyGstin,
              counterpartyName: gstr2aInvoice.counterpartyName,
              taxableValueSource2: gstr2aInvoice.taxableValue,
              igstSource2: gstr2aInvoice.igstAmount,
              cgstSource2: gstr2aInvoice.cgstAmount,
              sgstSource2: gstr2aInvoice.sgstAmount,
              matchStatus: MatchStatus.onlyInSource2,
              remarks: 'Invoice present in GSTR-2A but not in GSTR-1',
            ),
          );
        }
      }
      
      // Calculate total tax difference
      final totalTaxGSTR1 = totalIgstGSTR1 + totalCgstGSTR1 + totalSgstGSTR1;
      final totalTaxGSTR2A = totalIgstGSTR2A + totalCgstGSTR2A + totalSgstGSTR2A;
      final totalTaxDifference = (totalTaxGSTR1 - totalTaxGSTR2A).abs();
      
      // Create summary
      final summary = ReconciliationSummary(
        totalInvoices: allInvoiceKeys.length,
        matchedInvoices: matchedCount,
        partiallyMatchedInvoices: partiallyMatchedCount,
        mismatchedInvoices: mismatchedCount,
        onlyInSource1Invoices: onlyInGSTR1Count,
        onlyInSource2Invoices: onlyInGSTR2ACount,
        totalTaxableValueSource1: totalTaxableValueGSTR1,
        totalTaxableValueSource2: totalTaxableValueGSTR2A,
        totalIgstSource1: totalIgstGSTR1,
        totalIgstSource2: totalIgstGSTR2A,
        totalCgstSource1: totalCgstGSTR1,
        totalCgstSource2: totalCgstGSTR2A,
        totalSgstSource1: totalSgstGSTR1,
        totalSgstSource2: totalSgstGSTR2A,
        totalTaxDifference: totalTaxDifference,
      );
      
      // Create reconciliation result
      final result = ReconciliationResult(
        id: _uuid.v4(),
        gstin: gstin,
        period: period,
        type: ReconciliationType.gstr1VsGstr2a,
        reconciliationDate: DateTime.now(),
        summary: summary,
        items: reconciliationItems,
      );
      
      // Save result to database
      await saveReconciliationResult(result);
      
      return result;
    } catch (e) {
      throw Exception('Failed to reconcile GSTR-1 with GSTR-2A: ${e.toString()}');
    }
  }

  // Reconcile GSTR-1 with GSTR-3B
  Future<ReconciliationResult> reconcileGSTR1WithGSTR3B(
    String gstin,
    String period,
  ) async {
    try {
      // Fetch GSTR-1 and GSTR-3B data
      final gstr1 = await _gstr1Service.getGSTR1ByPeriod(gstin, period);
      final gstr3b = await _gstr3bService.getGSTR3BByPeriod(gstin, period);
      
      if (gstr1 == null || gstr3b == null) {
        throw Exception('GSTR-1 or GSTR-3B data not found for the specified period');
      }
      
      // Calculate GSTR-1 totals
      double totalTaxableValueGSTR1 = 0;
      double totalIgstGSTR1 = 0;
      double totalCgstGSTR1 = 0;
      double totalSgstGSTR1 = 0;
      
      for (var invoice in gstr1.b2bInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.b2clInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.b2csInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.exportInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
      }
      
      // Get GSTR-3B totals
      final totalTaxableValueGSTR3B = gstr3b.outwardSupplies.taxableOutwardSupplies;
      final totalIgstGSTR3B = gstr3b.outwardSupplies.igstAmount;
      final totalCgstGSTR3B = gstr3b.outwardSupplies.cgstAmount;
      final totalSgstGSTR3B = gstr3b.outwardSupplies.sgstAmount;
      
      // Calculate differences
      final taxableValueDiff = (totalTaxableValueGSTR1 - totalTaxableValueGSTR3B).abs();
      final igstDiff = (totalIgstGSTR1 - totalIgstGSTR3B).abs();
      final cgstDiff = (totalCgstGSTR1 - totalCgstGSTR3B).abs();
      final sgstDiff = (totalSgstGSTR1 - totalSgstGSTR3B).abs();
      
      // Determine match status
      MatchStatus matchStatus;
      final discrepancies = <String>[];
      
      if (taxableValueDiff > 0.01) {
        discrepancies.add('Taxable value mismatch');
      }
      
      if (igstDiff > 0.01) {
        discrepancies.add('IGST amount mismatch');
      }
      
      if (cgstDiff > 0.01) {
        discrepancies.add('CGST amount mismatch');
      }
      
      if (sgstDiff > 0.01) {
        discrepancies.add('SGST amount mismatch');
      }
      
      if (discrepancies.isEmpty) {
        matchStatus = MatchStatus.matched;
      } else if (discrepancies.length < 4) {
        matchStatus = MatchStatus.partiallyMatched;
      } else {
        matchStatus = MatchStatus.mismatched;
      }
      
      // Create reconciliation item
      final reconciliationItem = ReconciliationItem(
        id: _uuid.v4(),
        taxableValueSource1: totalTaxableValueGSTR1,
        taxableValueSource2: totalTaxableValueGSTR3B,
        igstSource1: totalIgstGSTR1,
        igstSource2: totalIgstGSTR3B,
        cgstSource1: totalCgstGSTR1,
        cgstSource2: totalCgstGSTR3B,
        sgstSource1: totalSgstGSTR1,
        sgstSource2: totalSgstGSTR3B,
        matchStatus: matchStatus,
        discrepancies: discrepancies.isNotEmpty ? discrepancies : null,
        remarks: 'Summary reconciliation between GSTR-1 and GSTR-3B',
      );
      
      // Calculate total tax difference
      final totalTaxGSTR1 = totalIgstGSTR1 + totalCgstGSTR1 + totalSgstGSTR1;
      final totalTaxGSTR3B = totalIgstGSTR3B + totalCgstGSTR3B + totalSgstGSTR3B;
      final totalTaxDifference = (totalTaxGSTR1 - totalTaxGSTR3B).abs();
      
      // Create summary
      final summary = ReconciliationSummary(
        totalInvoices: 1, // Summary level reconciliation
        matchedInvoices: matchStatus == MatchStatus.matched ? 1 : 0,
        partiallyMatchedInvoices: matchStatus == MatchStatus.partiallyMatched ? 1 : 0,
        mismatchedInvoices: matchStatus == MatchStatus.mismatched ? 1 : 0,
        onlyInSource1Invoices: 0,
        onlyInSource2Invoices: 0,
        totalTaxableValueSource1: totalTaxableValueGSTR1,
        totalTaxableValueSource2: totalTaxableValueGSTR3B,
        totalIgstSource1: totalIgstGSTR1,
        totalIgstSource2: totalIgstGSTR3B,
        totalCgstSource1: totalCgstGSTR1,
        totalCgstSource2: totalCgstGSTR3B,
        totalSgstSource1: totalSgstGSTR1,
        totalSgstSource2: totalSgstGSTR3B,
        totalTaxDifference: totalTaxDifference,
      );
      
      // Create reconciliation result
      final result = ReconciliationResult(
        id: _uuid.v4(),
        gstin: gstin,
        period: period,
        type: ReconciliationType.gstr1VsGstr3b,
        reconciliationDate: DateTime.now(),
        summary: summary,
        items: [reconciliationItem],
      );
      
      // Save result to database
      await saveReconciliationResult(result);
      
      return result;
    } catch (e) {
      throw Exception('Failed to reconcile GSTR-1 with GSTR-3B: ${e.toString()}');
    }
  }

  // Reconcile GSTR-2A with GSTR-2B
  Future<ReconciliationResult> reconcileGSTR2AWithGSTR2B(
    String gstin,
    String period,
  ) async {
    try {
      // Fetch GSTR-2A and GSTR-2B data
      final gstr2a = await _gstr2aService.getGSTR2AByPeriod(gstin, period);
      final gstr2b = await _gstr2bService.getGSTR2BByPeriod(gstin, period);
      
      if (gstr2a == null || gstr2b == null) {
        throw Exception('GSTR-2A or GSTR-2B data not found for the specified period');
      }
      
      // Create maps for quick lookup
      final gstr2aInvoices = <String, gstr2a.B2BInvoice>{};
      for (var invoice in gstr2a.b2bInvoices) {
        final key = '${invoice.invoiceNumber}_${invoice.invoiceDate.toIso8601String()}_${invoice.counterpartyGstin}';
        gstr2aInvoices[key] = invoice;
      }
      
      final gstr2bInvoices = <String, gstr2b.B2BInvoice>{};
      for (var invoice in gstr2b.b2bInvoices) {
        final key = '${invoice.invoiceNumber}_${invoice.invoiceDate.toIso8601String()}_${invoice.counterpartyGstin}';
        gstr2bInvoices[key] = invoice;
      }
      
      // Reconcile invoices
      final reconciliationItems = <ReconciliationItem>[];
      final allInvoiceKeys = {...gstr2aInvoices.keys, ...gstr2bInvoices.keys};
      
      int matchedCount = 0;
      int partiallyMatchedCount = 0;
      int mismatchedCount = 0;
      int onlyInGSTR2ACount = 0;
      int onlyInGSTR2BCount = 0;
      
      double totalTaxableValueGSTR2A = 0;
      double totalTaxableValueGSTR2B = 0;
      double totalIgstGSTR2A = 0;
      double totalIgstGSTR2B = 0;
      double totalCgstGSTR2A = 0;
      double totalCgstGSTR2B = 0;
      double totalSgstGSTR2A = 0;
      double totalSgstGSTR2B = 0;
      
      for (var key in allInvoiceKeys) {
        final gstr2aInvoice = gstr2aInvoices[key];
        final gstr2bInvoice = gstr2bInvoices[key];
        
        if (gstr2aInvoice != null) {
          totalTaxableValueGSTR2A += gstr2aInvoice.taxableValue;
          totalIgstGSTR2A += gstr2aInvoice.igstAmount;
          totalCgstGSTR2A += gstr2aInvoice.cgstAmount;
          totalSgstGSTR2A += gstr2aInvoice.sgstAmount;
        }
        
        if (gstr2bInvoice != null) {
          totalTaxableValueGSTR2B += gstr2bInvoice.taxableValue;
          totalIgstGSTR2B += gstr2bInvoice.igstAmount;
          totalCgstGSTR2B += gstr2bInvoice.cgstAmount;
          totalSgstGSTR2B += gstr2bInvoice.sgstAmount;
        }
        
        if (gstr2aInvoice != null && gstr2bInvoice != null) {
          // Both invoices exist, check for discrepancies
          final discrepancies = <String>[];
          
          if (gstr2aInvoice.taxableValue != gstr2bInvoice.taxableValue) {
            discrepancies.add('Taxable value mismatch');
          }
          
          if (gstr2aInvoice.igstAmount != gstr2bInvoice.igstAmount) {
            discrepancies.add('IGST amount mismatch');
          }
          
          if (gstr2aInvoice.cgstAmount != gstr2bInvoice.cgstAmount) {
            discrepancies.add('CGST amount mismatch');
          }
          
          if (gstr2aInvoice.sgstAmount != gstr2bInvoice.sgstAmount) {
            discrepancies.add('SGST amount mismatch');
          }
          
          MatchStatus matchStatus;
          if (discrepancies.isEmpty) {
            matchStatus = MatchStatus.matched;
            matchedCount++;
          } else if (discrepancies.length < 4) {
            matchStatus = MatchStatus.partiallyMatched;
            partiallyMatchedCount++;
          } else {
            matchStatus = MatchStatus.mismatched;
            mismatchedCount++;
          }
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr2aInvoice.invoiceNumber,
              invoiceDate: gstr2aInvoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr2aInvoice.counterpartyGstin,
              counterpartyName: gstr2aInvoice.counterpartyName,
              taxableValueSource1: gstr2aInvoice.taxableValue,
              taxableValueSource2: gstr2bInvoice.taxableValue,
              igstSource1: gstr2aInvoice.igstAmount,
              igstSource2: gstr2bInvoice.igstAmount,
              cgstSource1: gstr2aInvoice.cgstAmount,
              cgstSource2: gstr2bInvoice.cgstAmount,
              sgstSource1: gstr2aInvoice.sgstAmount,
              sgstSource2: gstr2bInvoice.sgstAmount,
              matchStatus: matchStatus,
              discrepancies: discrepancies.isNotEmpty ? discrepancies : null,
            ),
          );
        } else if (gstr2aInvoice != null) {
          // Invoice only in GSTR-2A
          onlyInGSTR2ACount++;
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr2aInvoice.invoiceNumber,
              invoiceDate: gstr2aInvoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr2aInvoice.counterpartyGstin,
              counterpartyName: gstr2aInvoice.counterpartyName,
              taxableValueSource1: gstr2aInvoice.taxableValue,
              igstSource1: gstr2aInvoice.igstAmount,
              cgstSource1: gstr2aInvoice.cgstAmount,
              sgstSource1: gstr2aInvoice.sgstAmount,
              matchStatus: MatchStatus.onlyInSource1,
              remarks: 'Invoice present in GSTR-2A but not in GSTR-2B',
            ),
          );
        } else if (gstr2bInvoice != null) {
          // Invoice only in GSTR-2B
          onlyInGSTR2BCount++;
          
          reconciliationItems.add(
            ReconciliationItem(
              id: _uuid.v4(),
              invoiceNumber: gstr2bInvoice.invoiceNumber,
              invoiceDate: gstr2bInvoice.invoiceDate.toIso8601String(),
              counterpartyGstin: gstr2bInvoice.counterpartyGstin,
              counterpartyName: gstr2bInvoice.counterpartyName,
              taxableValueSource2: gstr2bInvoice.taxableValue,
              igstSource2: gstr2bInvoice.igstAmount,
              cgstSource2: gstr2bInvoice.cgstAmount,
              sgstSource2: gstr2bInvoice.sgstAmount,
              matchStatus: MatchStatus.onlyInSource2,
              remarks: 'Invoice present in GSTR-2B but not in GSTR-2A',
            ),
          );
        }
      }
      
      // Calculate total tax difference
      final totalTaxGSTR2A = totalIgstGSTR2A + totalCgstGSTR2A + totalSgstGSTR2A;
      final totalTaxGSTR2B = totalIgstGSTR2B + totalCgstGSTR2B + totalSgstGSTR2B;
      final totalTaxDifference = (totalTaxGSTR2A - totalTaxGSTR2B).abs();
      
      // Create summary
      final summary = ReconciliationSummary(
        totalInvoices: allInvoiceKeys.length,
        matchedInvoices: matchedCount,
        partiallyMatchedInvoices: partiallyMatchedCount,
        mismatchedInvoices: mismatchedCount,
        onlyInSource1Invoices: onlyInGSTR2ACount,
        onlyInSource2Invoices: onlyInGSTR2BCount,
        totalTaxableValueSource1: totalTaxableValueGSTR2A,
        totalTaxableValueSource2: totalTaxableValueGSTR2B,
        totalIgstSource1: totalIgstGSTR2A,
        totalIgstSource2: totalIgstGSTR2B,
        totalCgstSource1: totalCgstGSTR2A,
        totalCgstSource2: totalCgstGSTR2B,
        totalSgstSource1: totalSgstGSTR2A,
        totalSgstSource2: totalSgstGSTR2B,
        totalTaxDifference: totalTaxDifference,
      );
      
      // Create reconciliation result
      final result = ReconciliationResult(
        id: _uuid.v4(),
        gstin: gstin,
        period: period,
        type: ReconciliationType.gstr2aVsGstr2b,
        reconciliationDate: DateTime.now(),
        summary: summary,
        items: reconciliationItems,
      );
      
      // Save result to database
      await saveReconciliationResult(result);
      
      return result;
    } catch (e) {
      throw Exception('Failed to reconcile GSTR-2A with GSTR-2B: ${e.toString()}');
    }
  }

  // Reconcile GSTR-2B with GSTR-3B
  Future<ReconciliationResult> reconcileGSTR2BWithGSTR3B(
    String gstin,
    String period,
  ) async {
    try {
      // Fetch GSTR-2B and GSTR-3B data
      final gstr2b = await _gstr2bService.getGSTR2BByPeriod(gstin, period);
      final gstr3b = await _gstr3bService.getGSTR3BByPeriod(gstin, period);
      
      if (gstr2b == null || gstr3b == null) {
        throw Exception('GSTR-2B or GSTR-3B data not found for the specified period');
      }
      
      // Calculate GSTR-2B totals
      double totalTaxableValueGSTR2B = 0;
      double totalIgstGSTR2B = 0;
      double totalCgstGSTR2B = 0;
      double totalSgstGSTR2B = 0;
      
      for (var invoice in gstr2b.b2bInvoices) {
        if (invoice.eligibilityType == 'Eligible') {
          totalTaxableValueGSTR2B += invoice.taxableValue;
          totalIgstGSTR2B += invoice.igstAmount;
          totalCgstGSTR2B += invoice.cgstAmount;
          totalSgstGSTR2B += invoice.sgstAmount;
        }
      }
      
      // Get GSTR-3B ITC details
      final totalIgstGSTR3B = gstr3b.itcDetails.itcAvailed;
      final totalCgstGSTR3B = gstr3b.itcDetails.itcAvailed;
      final totalSgstGSTR3B = gstr3b.itcDetails.itcAvailed;
      
      // Calculate differences
      final igstDiff = (totalIgstGSTR2B - totalIgstGSTR3B).abs();
      final cgstDiff = (totalCgstGSTR2B - totalCgstGSTR3B).abs();
      final sgstDiff = (totalSgstGSTR2B - totalSgstGSTR3B).abs();
      
      // Determine match status
      MatchStatus matchStatus;
      final discrepancies = <String>[];
      
      if (igstDiff > 0.01) {
        discrepancies.add('IGST ITC mismatch');
      }
      
      if (cgstDiff > 0.01) {
        discrepancies.add('CGST ITC mismatch');
      }
      
      if (sgstDiff > 0.01) {
        discrepancies.add('SGST ITC mismatch');
      }
      
      if (discrepancies.isEmpty) {
        matchStatus = MatchStatus.matched;
      } else if (discrepancies.length < 3) {
        matchStatus = MatchStatus.partiallyMatched;
      } else {
        matchStatus = MatchStatus.mismatched;
      }
      
      // Create reconciliation item
      final reconciliationItem = ReconciliationItem(
        id: _uuid.v4(),
        taxableValueSource1: totalTaxableValueGSTR2B,
        igstSource1: totalIgstGSTR2B,
        igstSource2: totalIgstGSTR3B,
        cgstSource1: totalCgstGSTR2B,
        cgstSource2: totalCgstGSTR3B,
        sgstSource1: totalSgstGSTR2B,
        sgstSource2: totalSgstGSTR3B,
        matchStatus: matchStatus,
        discrepancies: discrepancies.isNotEmpty ? discrepancies : null,
        remarks: 'ITC reconciliation between GSTR-2B and GSTR-3B',
      );
      
      // Calculate total tax difference
      final totalTaxGSTR2B = totalIgstGSTR2B + totalCgstGSTR2B + totalSgstGSTR2B;
      final totalTaxGSTR3B = totalIgstGSTR3B + totalCgstGSTR3B + totalSgstGSTR3B;
      final totalTaxDifference = (totalTaxGSTR2B - totalTaxGSTR3B).abs();
      
      // Create summary
      final summary = ReconciliationSummary(
        totalInvoices: 1, // Summary level reconciliation
        matchedInvoices: matchStatus == MatchStatus.matched ? 1 : 0,
        partiallyMatchedInvoices: matchStatus == MatchStatus.partiallyMatched ? 1 : 0,
        mismatchedInvoices: matchStatus == MatchStatus.mismatched ? 1 : 0,
        onlyInSource1Invoices: 0,
        onlyInSource2Invoices: 0,
        totalTaxableValueSource1: totalTaxableValueGSTR2B,
        totalTaxableValueSource2: 0, // Not applicable for GSTR-3B ITC
        totalIgstSource1: totalIgstGSTR2B,
        totalIgstSource2: totalIgstGSTR3B,
        totalCgstSource1: totalCgstGSTR2B,
        totalCgstSource2: totalCgstGSTR3B,
        totalSgstSource1: totalSgstGSTR2B,
        totalSgstSource2: totalSgstGSTR3B,
        totalTaxDifference: totalTaxDifference,
      );
      
      // Create reconciliation result
      final result = ReconciliationResult(
        id: _uuid.v4(),
        gstin: gstin,
        period: period,
        type: ReconciliationType.gstr2bVsGstr3b,
        reconciliationDate: DateTime.now(),
        summary: summary,
        items: [reconciliationItem],
      );
      
      // Save result to database
      await saveReconciliationResult(result);
      
      return result;
    } catch (e) {
      throw Exception('Failed to reconcile GSTR-2B with GSTR-3B: ${e.toString()}');
    }
  }

  // Comprehensive reconciliation (GSTR-1, GSTR-2A, GSTR-2B, GSTR-3B)
  Future<ReconciliationResult> performComprehensiveReconciliation(
    String gstin,
    String period,
  ) async {
    try {
      // Fetch all GST returns data
      final gstr1 = await _gstr1Service.getGSTR1ByPeriod(gstin, period);
      final gstr2a = await _gstr2aService.getGSTR2AByPeriod(gstin, period);
      final gstr2b = await _gstr2bService.getGSTR2BByPeriod(gstin, period);
      final gstr3b = await _gstr3bService.getGSTR3BByPeriod(gstin, period);
      
      if (gstr1 == null || gstr2a == null || gstr2b == null || gstr3b == null) {
        throw Exception('One or more GST returns not found for the specified period');
      }
      
      // Calculate totals for each return
      double totalTaxableValueGSTR1 = 0;
      double totalIgstGSTR1 = 0;
      double totalCgstGSTR1 = 0;
      double totalSgstGSTR1 = 0;
      
      for (var invoice in gstr1.b2bInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.b2clInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.b2csInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
        totalCgstGSTR1 += invoice.cgstAmount;
        totalSgstGSTR1 += invoice.sgstAmount;
      }
      
      for (var invoice in gstr1.exportInvoices) {
        totalTaxableValueGSTR1 += invoice.taxableValue;
        totalIgstGSTR1 += invoice.igstAmount;
      }
      
      double totalTaxableValueGSTR2A = 0;
      double totalIgstGSTR2A = 0;
      double totalCgstGSTR2A = 0;
      double totalSgstGSTR2A = 0;
      
      for (var invoice in gstr2a.b2bInvoices) {
        totalTaxableValueGSTR2A += invoice.taxableValue;
        totalIgstGSTR2A += invoice.igstAmount;
        totalCgstGSTR2A += invoice.cgstAmount;
        totalSgstGSTR2A += invoice.sgstAmount;
      }
      
      double totalTaxableValueGSTR2B = 0;
      double totalIgstGSTR2B = 0;
      double totalCgstGSTR2B = 0;
      double totalSgstGSTR2B = 0;
      
      for (var invoice in gstr2b.b2bInvoices) {
        totalTaxableValueGSTR2B += invoice.taxableValue;
        totalIgstGSTR2B += invoice.igstAmount;
        totalCgstGSTR2B += invoice.cgstAmount;
        totalSgstGSTR2B += invoice.sgstAmount;
      }
      
      final totalTaxableValueGSTR3B = gstr3b.outwardSupplies.taxableOutwardSupplies;
      final totalIgstGSTR3B = gstr3b.outwardSupplies.igstAmount;
      final totalCgstGSTR3B = gstr3b.outwardSupplies.cgstAmount;
      final totalSgstGSTR3B = gstr3b.outwardSupplies.sgstAmount;
      
      // Create reconciliation items for each comparison
      final reconciliationItems = <ReconciliationItem>[];
      
      // GSTR-1 vs GSTR-3B
      final gstr1VsGstr3bDiscrepancies = <String>[];
      
      if ((totalTaxableValueGSTR1 - totalTaxableValueGSTR3B).abs() > 0.01) {
        gstr1VsGstr3bDiscrepancies.add('Taxable value mismatch');
      }
      
      if ((totalIgstGSTR1 - totalIgstGSTR3B).abs() > 0.01) {
        gstr1VsGstr3bDiscrepancies.add('IGST amount mismatch');
      }
      
      if ((totalCgstGSTR1 - totalCgstGSTR3B).abs() > 0.01) {
        gstr1VsGstr3bDiscrepancies.add('CGST amount mismatch');
      }
      
      if ((totalSgstGSTR1 - totalSgstGSTR3B).abs() > 0.01) {
        gstr1VsGstr3bDiscrepancies.add('SGST amount mismatch');
      }
      
      MatchStatus gstr1VsGstr3bStatus;
      if (gstr1VsGstr3bDiscrepancies.isEmpty) {
        gstr1VsGstr3bStatus = MatchStatus.matched;
      } else if (gstr1VsGstr3bDiscrepancies.length < 4) {
        gstr1VsGstr3bStatus = MatchStatus.partiallyMatched;
      } else {
        gstr1VsGstr3bStatus = MatchStatus.mismatched;
      }
      
      reconciliationItems.add(
        ReconciliationItem(
          id: _uuid.v4(),
          taxableValueSource1: totalTaxableValueGSTR1,
          taxableValueSource2: totalTaxableValueGSTR3B,
          igstSource1: totalIgstGSTR1,
          igstSource2: totalIgstGSTR3B,
          cgstSource1: totalCgstGSTR1,
          cgstSource2: totalCgstGSTR3B,
          sgstSource1: totalSgstGSTR1,
          sgstSource2: totalSgstGSTR3B,
          matchStatus: gstr1VsGstr3bStatus,
          discrepancies: gstr1VsGstr3bDiscrepancies.isNotEmpty ? gstr1VsGstr3bDiscrepancies : null,
          remarks: 'GSTR-1 vs GSTR-3B reconciliation',
        ),
      );
      
      // GSTR-2A vs GSTR-2B
      final gstr2aVsGstr2bDiscrepancies = <String>[];
      
      if ((totalTaxableValueGSTR2A - totalTaxableValueGSTR2B).abs() > 0.01) {
        gstr2aVsGstr2bDiscrepancies.add('Taxable value mismatch');
      }
      
      if ((totalIgstGSTR2A - totalIgstGSTR2B).abs() > 0.01) {
        gstr2aVsGstr2bDiscrepancies.add('IGST amount mismatch');
      }
      
      if ((totalCgstGSTR2A - totalCgstGSTR2B).abs() > 0.01) {
        gstr2aVsGstr2bDiscrepancies.add('CGST amount mismatch');
      }
      
      if ((totalSgstGSTR2A - totalSgstGSTR2B).abs() > 0.01) {
        gstr2aVsGstr2bDiscrepancies.add('SGST amount mismatch');
      }
      
      MatchStatus gstr2aVsGstr2bStatus;
      if (gstr2aVsGstr2bDiscrepancies.isEmpty) {
        gstr2aVsGstr2bStatus = MatchStatus.matched;
      } else if (gstr2aVsGstr2bDiscrepancies.length < 4) {
        gstr2aVsGstr2bStatus = MatchStatus.partiallyMatched;
      } else {
        gstr2aVsGstr2bStatus = MatchStatus.mismatched;
      }
      
      reconciliationItems.add(
        ReconciliationItem(
          id: _uuid.v4(),
          taxableValueSource1: totalTaxableValueGSTR2A,
          taxableValueSource2: totalTaxableValueGSTR2B,
          igstSource1: totalIgstGSTR2A,
          igstSource2: totalIgstGSTR2B,
          cgstSource1: totalCgstGSTR2A,
          cgstSource2: totalCgstGSTR2B,
          sgstSource1: totalSgstGSTR2A,
          sgstSource2: totalSgstGSTR2B,
          matchStatus: gstr2aVsGstr2bStatus,
          discrepancies: gstr2aVsGstr2bDiscrepancies.isNotEmpty ? gstr2aVsGstr2bDiscrepancies : null,
          remarks: 'GSTR-2A vs GSTR-2B reconciliation',
        ),
      );
      
      // Calculate total tax difference
      final totalTaxGSTR1 = totalIgstGSTR1 + totalCgstGSTR1 + totalSgstGSTR1;
      final totalTaxGSTR2A = totalIgstGSTR2A + totalCgstGSTR2A + totalSgstGSTR2A;
      final totalTaxGSTR2B = totalIgstGSTR2B + totalCgstGSTR2B + totalSgstGSTR2B;
      final totalTaxGSTR3B = totalIgstGSTR3B + totalCgstGSTR3B + totalSgstGSTR3B;
      
      final maxTaxDifference = [
        (totalTaxGSTR1 - totalTaxGSTR3B).abs(),
        (totalTaxGSTR2A - totalTaxGSTR2B).abs(),
      ].reduce((a, b) => a > b ? a : b);
      
      // Create summary
      final summary = ReconciliationSummary(
        totalInvoices: 2, // Summary level reconciliation for 2 comparisons
        matchedInvoices: (gstr1VsGstr3bStatus == MatchStatus.matched ? 1 : 0) +
                         (gstr2aVsGstr2bStatus == MatchStatus.matched ? 1 : 0),
        partiallyMatchedInvoices: (gstr1VsGstr3bStatus == MatchStatus.partiallyMatched ? 1 : 0) +
                                  (gstr2aVsGstr2bStatus == MatchStatus.partiallyMatched ? 1 : 0),
        mismatchedInvoices: (gstr1VsGstr3bStatus == MatchStatus.mismatched ? 1 : 0) +
                            (gstr2aVsGstr2bStatus == MatchStatus.mismatched ? 1 : 0),
        onlyInSource1Invoices: 0,
        onlyInSource2Invoices: 0,
        totalTaxableValueSource1: totalTaxableValueGSTR1,
        totalTaxableValueSource2: totalTaxableValueGSTR3B,
        totalTaxableValueSource3: totalTaxableValueGSTR2B,
        totalIgstSource1: totalIgstGSTR1,
        totalIgstSource2: totalIgstGSTR3B,
        totalIgstSource3: totalIgstGSTR2B,
        totalCgstSource1: totalCgstGSTR1,
        totalCgstSource2: totalCgstGSTR3B,
        totalCgstSource3: totalCgstGSTR2B,
        totalSgstSource1: totalSgstGSTR1,
        totalSgstSource2: totalSgstGSTR3B,
        totalSgstSource3: totalSgstGSTR2B,
        totalTaxDifference: maxTaxDifference,
      );
      
      // Create reconciliation result
      final result = ReconciliationResult(
        id: _uuid.v4(),
        gstin: gstin,
        period: period,
        type: ReconciliationType.comprehensive,
        reconciliationDate: DateTime.now(),
        summary: summary,
        items: reconciliationItems,
      );
      
      // Save result to database
      await saveReconciliationResult(result);
      
      return result;
    } catch (e) {
      throw Exception('Failed to perform comprehensive reconciliation: ${e.toString()}');
    }
  }

  // Export reconciliation result to JSON
  Future<String> exportReconciliationToJson(String id) async {
    try {
      final result = await getReconciliationResultById(id);
      
      if (result != null) {
        return jsonEncode(result.toJson());
      }
      
      throw Exception('Reconciliation result not found');
    } catch (e) {
      throw Exception('Failed to export reconciliation result: ${e.toString()}');
    }
  }
}
