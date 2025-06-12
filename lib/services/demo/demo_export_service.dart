import 'dart:math';

import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';

class DemoExportService {
  static final DemoExportService _instance = DemoExportService._internal();
  final Random _random = Random();

  factory DemoExportService() {
    return _instance;
  }

  DemoExportService._internal();

  // Generate demo GSTR1 data
  Future<GSTR1> generateDemoGstr1() async {
    final gstin = '27AADCB2230M1ZT';
    final returnPeriod = 'Apr 2023';

    // Generate B2B invoices
    List<B2BInvoice> b2bInvoices = List.generate(
      10,
      (index) => _generateDemoB2BInvoice(index),
    );

    // Generate B2CL invoices
    List<B2CLInvoice> b2clInvoices = List.generate(
      5,
      (index) => _generateDemoB2CLInvoice(index),
    );

    // Generate B2CS invoices
    List<B2CSInvoice> b2csInvoices = List.generate(
      3,
      (index) => _generateDemoB2CSInvoice(index),
    );

    // Generate Export invoices
    List<ExportInvoice> exportInvoices = List.generate(
      2,
      (index) => _generateDemoExportInvoice(index),
    );

    // Calculate totals
    double totalTaxableValue = 0;
    double totalIgst = 0;
    double totalCgst = 0;
    double totalSgst = 0;

    for (var invoice in b2bInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }

    for (var invoice in b2clInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }

    for (var invoice in b2csInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
      totalCgst += invoice.cgstAmount;
      totalSgst += invoice.sgstAmount;
    }

    for (var invoice in exportInvoices) {
      totalTaxableValue += invoice.taxableValue;
      totalIgst += invoice.igstAmount;
    }

    return GSTR1(
      gstin: gstin,
      returnPeriod: returnPeriod,
      b2bInvoices: b2bInvoices,
      b2clInvoices: b2clInvoices,
      b2csInvoices: b2csInvoices,
      exportInvoices: exportInvoices,
      totalTaxableValue: totalTaxableValue,
      totalIgst: totalIgst,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      status: 'Filed',
      filingDate: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  // Generate demo GSTR3B data
  Future<GSTR3B> generateDemoGstr3B() async {
    final gstin = '27AADCB2230M1ZT';
    final returnPeriod = 'Apr 2023';

    // Generate outward supplies
    final outwardSupplies = OutwardSupplies(
      taxableOutwardSupplies: 1000000 + _random.nextDouble() * 500000,
      taxableOutwardSuppliesZeroRated: 50000 + _random.nextDouble() * 50000,
      taxableOutwardSuppliesNilRated: 30000 + _random.nextDouble() * 30000,
      nonGstOutwardSupplies: 20000 + _random.nextDouble() * 20000,
      intraStateSupplies: 600000 + _random.nextDouble() * 300000,
      interStateSupplies: 400000 + _random.nextDouble() * 200000,
      igstAmount: 72000 + _random.nextDouble() * 36000,
      cgstAmount: 54000 + _random.nextDouble() * 27000,
      sgstAmount: 54000 + _random.nextDouble() * 27000,
      cessAmount: 10000 + _random.nextDouble() * 5000,
    );

    // Generate inward supplies
    final inwardSupplies = InwardSupplies(
      reverseChargeSupplies: 50000 + _random.nextDouble() * 25000,
      importOfGoods: 100000 + _random.nextDouble() * 50000,
      importOfServices: 80000 + _random.nextDouble() * 40000,
      ineligibleITC: 5000 + _random.nextDouble() * 2500,
      eligibleITC: 30000 + _random.nextDouble() * 15000,
      igstAmount: 32400 + _random.nextDouble() * 16200,
      cgstAmount: 7200 + _random.nextDouble() * 3600,
      sgstAmount: 7200 + _random.nextDouble() * 3600,
      cessAmount: 3000 + _random.nextDouble() * 1500,
    );

    // Generate ITC details
    final itcDetails = ITCDetails(
      itcAvailed: 46800 + _random.nextDouble() * 23400,
      itcReversed: 2000 + _random.nextDouble() * 1000,
      itcNet: 44800 + _random.nextDouble() * 22400,
      ineligibleITC: 5000 + _random.nextDouble() * 2500,
    );

    // Generate tax payment
    final taxPayment = TaxPayment(
      igstAmount: 72000 - 32400 + _random.nextDouble() * 5000,
      cgstAmount: 54000 - 7200 + _random.nextDouble() * 2500,
      sgstAmount: 54000 - 7200 + _random.nextDouble() * 2500,
      cessAmount: 10000 - 3000 + _random.nextDouble() * 500,
      interestAmount: 1000 + _random.nextDouble() * 500,
      lateFeesAmount: 0,
      penaltyAmount: 0,
      totalAmount: 0, // Will be calculated below
    );

    // Calculate total amount
    taxPayment.totalAmount = taxPayment.igstAmount + taxPayment.cgstAmount + taxPayment.sgstAmount +
        taxPayment.cessAmount + taxPayment.interestAmount + taxPayment.lateFeesAmount +
        taxPayment.penaltyAmount;

    return GSTR3B(
      gstin: gstin,
      returnPeriod: returnPeriod,
      outwardSupplies: outwardSupplies,
      inwardSupplies: inwardSupplies,
      itcDetails: itcDetails,
      taxPayment: taxPayment,
      status: 'Filed',
      filingDate: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  // Generate demo reconciliation result
  Future<ReconciliationResult> generateDemoReconciliationResult() async {
    // Generate comparison items
    List<ComparisonItem> items = [];

    // Generate matched items
    items.addAll(List.generate(
      30,
          (index) => _generateDemoComparisonItem(index, 'Matched'),
    ));

    // Generate partially matched items
    items.addAll(List.generate(
      10,
          (index) => _generateDemoComparisonItem(30 + index, 'Partially Matched'),
    ));

    // Generate not matched items
    items.addAll(List.generate(
      5,
          (index) => _generateDemoComparisonItem(40 + index, 'Not Matched'),
    ));

    // Generate only in source 1 items
    items.addAll(List.generate(
      3,
          (index) => _generateDemoComparisonItem(45 + index, 'Only in Source1'),
    ));

    // Generate only in source 2 items
    items.addAll(List.generate(
      2,
          (index) => _generateDemoComparisonItem(48 + index, 'Only in Source2'),
    ));

    // Calculate summary
    int matchedInvoices = items.where((item) => item.matchStatus == 'Matched').length;
    int partiallyMatchedInvoices = items.where((item) => item.matchStatus == 'Partially Matched').length;
    int unmatchedInvoices = items.where((item) => item.matchStatus == 'Not Matched').length;
    int onlyInSource1Invoices = items.where((item) => item.matchStatus == 'Only in Source1').length;
    int onlyInSource2Invoices = items.where((item) => item.matchStatus == 'Only in Source2').length;

    double totalTaxableValueInSource1 = items.fold(0, (sum, item) => sum + (item.taxableValueInSource1 ?? 0));
    double totalTaxableValueInSource2 = items.fold(0, (sum, item) => sum + (item.taxableValueInSource2 ?? 0));

    double totalTaxInSource1 = items.fold(0, (sum, item) => sum + (item.igstInSource1 ?? 0) + (item.cgstInSource1 ?? 0) + (item.sgstInSource1 ?? 0));
    double totalTaxInSource2 = items.fold(0, (sum, item) => sum + (item.igstInSource2 ?? 0) + (item.cgstInSource2 ?? 0) + (item.sgstInSource2 ?? 0));

    double taxDifference = totalTaxInSource1 - totalTaxInSource2;

    final summary = ComparisonSummary(
      totalInvoices: items.length,
      matchedInvoices: matchedInvoices,
      partiallyMatchedInvoices: partiallyMatchedInvoices,
      unmatchedInvoices: unmatchedInvoices,
      onlyInSource1Invoices: onlyInSource1Invoices,
      onlyInSource2Invoices: onlyInSource2Invoices,
      onlyInSource3Invoices: 0,
      totalTaxableValueInSource1: totalTaxableValueInSource1,
      totalTaxableValueInSource2: totalTaxableValueInSource2,
      totalTaxableValueInSource3: 0,
      totalTaxInSource1: totalTaxInSource1,
      totalTaxInSource2: totalTaxInSource2,
      totalTaxInSource3: 0,
      taxDifference: taxDifference,
    );

    return ReconciliationResult(
      items: items,
      summary: summary,
    );
  }

  // Helper methods to generate demo data
  B2BInvoice _generateDemoB2BInvoice(int index) {
    final taxableValue = 10000.0 + _random.nextDouble() * 90000.0;
    final igstAmount = _random.nextBool() ? taxableValue * 0.18 : 0.0;
    final cgstAmount = igstAmount > 0 ? 0.0 : taxableValue * 0.09;
    final sgstAmount = igstAmount > 0 ? 0.0 : taxableValue * 0.09;

    return B2BInvoice(
      id: 'B2B_$index',
      invoiceNumber: 'INV-${1000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      counterpartyGstin: '29AABCU9603R1ZJ',
      counterpartyName: 'Demo Supplier ${index + 1}',
      taxableValue: taxableValue,
      igstAmount: igstAmount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      cessAmount: taxableValue * 0.01,
      placeOfSupply: '27-Maharashtra',
      reverseCharge: _random.nextBool(),
      invoiceType: 'Regular',
    );
  }

  B2CLInvoice _generateDemoB2CLInvoice(int index) {
    final taxableValue = 5000.0 + _random.nextDouble() * 45000.0;
    final igstAmount = _random.nextBool() ? taxableValue * 0.18 : 0.0;
    final cgstAmount = igstAmount > 0 ? 0.0 : taxableValue * 0.09;
    final sgstAmount = igstAmount > 0 ? 0.0 : taxableValue * 0.09;

    return B2CLInvoice(
      id: 'B2CL_$index',
      invoiceNumber: 'INVB2CL-${2000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      taxableValue: taxableValue,
      igstAmount: igstAmount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      cessAmount: taxableValue * 0.01,
      placeOfSupply: '27-Maharashtra',
    );
  }

  B2CSInvoice _generateDemoB2CSInvoice(int index) {
    final taxableValue = 1000.0 + _random.nextDouble() * 9000.0;

    return B2CSInvoice(
      id: 'B2CS_$index',
      type: 'OE',
      placeOfSupply: '27-Maharashtra',
      taxableValue: taxableValue,
      igstAmount: 0.0,
      cgstAmount: taxableValue * 0.09,
      sgstAmount: taxableValue * 0.09,
      cessAmount: taxableValue * 0.01,
    );
  }

  ExportInvoice _generateDemoExportInvoice(int index) {
    final taxableValue = 20000.0 + _random.nextDouble() * 180000.0;

    return ExportInvoice(
      id: 'EXP_$index',
      invoiceNumber: 'INVEXP-${3000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      taxableValue: taxableValue,
      igstAmount: taxableValue * 0.18,
      shippingBillNumber: 'SB${100000 + _random.nextInt(900000)}',
      shippingBillDate: DateTime.now().subtract(Duration(days: _random.nextInt(20))),
      portCode: 'INBOM1',
      exportType: _random.nextBool() ? 'With Payment' : 'Without Payment',
    );
  }

  ComparisonItem _generateDemoComparisonItem(int index, String matchStatus) {
    final invoiceNumber = 'INV-${10000 + index}';
    final invoiceDate = DateTime.now().subtract(Duration(days: _random.nextInt(90))).toString().substring(0, 10);
    final counterpartyGstin = '29AABCU9603R1ZJ';
    final counterpartyName = 'Demo Supplier ${index + 1}';

    double? taxableValueInSource1 = 0;
    double? taxableValueInSource2 = 0;
    double? igstInSource1 = 0;
    double? igstInSource2 = 0;
    double? cgstInSource1 = 0;
    double? cgstInSource2 = 0;
    double? sgstInSource1 = 0;
    double? sgstInSource2 = 0;
    String remarks = '';

    switch (matchStatus) {
      case 'Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 = taxableValueInSource1;

        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
          igstInSource2 = igstInSource1;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
          cgstInSource2 = cgstInSource1;
          sgstInSource2 = sgstInSource1;
        }

        remarks = 'Invoice matched across all sources';
        break;

      case 'Partially Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 = taxableValueInSource1 * (0.9 + _random.nextDouble() * 0.2);

        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
          igstInSource2 = taxableValueInSource2 * 0.18;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
          cgstInSource2 = taxableValueInSource2 * 0.09;
          sgstInSource2 = taxableValueInSource2 * 0.09;
        }

        remarks = 'Invoice values differ slightly across sources';
        break;

      case 'Not Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 = 10000 + _random.nextDouble() * 90000;

        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
        }

        if (_random.nextBool()) {
          igstInSource2 = taxableValueInSource2 * 0.18;
        } else {
          cgstInSource2 = taxableValueInSource2 * 0.09;
          sgstInSource2 = taxableValueInSource2 * 0.09;
        }

        remarks = 'Invoice values significantly different across sources';
        break;

      case 'Only in Source1':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;

        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
        }

        remarks = 'Invoice present only in Source1';
        break;

      case 'Only in Source2':
        taxableValueInSource2 = 10000 + _random.nextDouble() * 90000;

        if (_random.nextBool()) {
          igstInSource2 = taxableValueInSource2 * 0.18;
        } else {
          cgstInSource2 = taxableValueInSource2 * 0.09;
          sgstInSource2 = taxableValueInSource2 * 0.09;
        }

        remarks = 'Invoice present only in Source2';
        break;
    }

    return ComparisonItem(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      counterpartyGstin: counterpartyGstin,
      counterpartyName: counterpartyName,
      taxableValueInSource1: taxableValueInSource1,
      taxableValueInSource2: taxableValueInSource2,
      taxableValueInSource3: null,
      igstInSource1: igstInSource1,
      igstInSource2: igstInSource2,
      igstInSource3: null,
      cgstInSource1: cgstInSource1,
      cgstInSource2: cgstInSource2,
      cgstInSource3: null,
      sgstInSource1: sgstInSource1,
      sgstInSource2: sgstInSource2,
      sgstInSource3: null,
      matchStatus: matchStatus,
      remarks: remarks,
    );
  }
}
