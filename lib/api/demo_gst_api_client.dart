// ignore_for_file: avoid_redundant_argument_values

import 'dart:math';

import '../models/api/api_response.dart';
import '../models/gst_returns/gstr1_model.dart' as gstr1;
import '../models/gst_returns/gstr3b_model.dart';
import '../models/gst_returns/gstr9_model.dart';
import '../models/gst_returns/gstr9c_model.dart';

/// Demo implementation of the GST API client that returns mock data
class DemoGstApiClient {
  final Random _random = Random();

  // GSTR-1 endpoints
  Future<ApiResponse<gstr1.GSTR1Summary>> getGSTR1Summary(
    String gstin,
    String returnPeriod,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(500)));

    return ApiResponse<gstr1.GSTR1Summary>(
      success: true,
      statusCode: 200,
      message: 'GSTR-1 summary fetched successfully',
      data: gstr1.GSTR1Summary(
        gstin: gstin,
        returnPeriod: returnPeriod,
        totalInvoices: 120 + _random.nextInt(50),
        totalTaxableValue: 1500000 + _random.nextDouble() * 500000,
        totalIgst: 120000 + _random.nextDouble() * 50000,
        totalCgst: 90000 + _random.nextDouble() * 30000,
        totalSgst: 90000 + _random.nextDouble() * 30000,
        b2bInvoiceCount: 80 + _random.nextInt(20),
        b2clInvoiceCount: 30 + _random.nextInt(15),
        b2csInvoiceCount: 10 + _random.nextInt(15),
        exportInvoiceCount: 0 + _random.nextInt(5),
        status: 'Filed',
        filingDate:
            DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ),
    );
  }

  Future<ApiResponse<gstr1.GSTR1>> getGSTR1Details(
    String gstin,
    String returnPeriod,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));

    // Generate mock B2B invoices
    List<gstr1.B2BInvoice> b2bInvoices = List.generate(
      80 + _random.nextInt(20),
      _generateMockB2BInvoice,
    );

    // Generate mock B2CL invoices
    List<gstr1.B2CLInvoice> b2clInvoices = List.generate(
      30 + _random.nextInt(15),
      _generateMockB2CLInvoice,
    );

    // Generate mock B2CS invoices
    List<gstr1.B2CSInvoice> b2csInvoices = List.generate(
      10 + _random.nextInt(15),
      _generateMockB2CSInvoice,
    );

    // Generate mock Export invoices
    List<gstr1.ExportInvoice> exportInvoices = List.generate(
      _random.nextInt(5),
      _generateMockExportInvoice,
    );

    // Calculate totals
    double totalTaxableValue = [
      ...b2bInvoices.map((e) => e.taxableValue),
      ...b2clInvoices.map((e) => e.taxableValue),
      ...b2csInvoices.map((e) => e.taxableValue),
      ...exportInvoices.map((e) => e.taxableValue),
    ].fold(0, (sum, value) => sum + value);

    double totalIgst = [
      ...b2bInvoices.map((e) => e.igstAmount),
      ...b2clInvoices.map((e) => e.igstAmount),
      ...exportInvoices.map((e) => e.igstAmount),
    ].fold(0, (sum, value) => sum + value);

    double totalCgst = [
      ...b2bInvoices.map((e) => e.cgstAmount),
      ...b2clInvoices.map((e) => e.cgstAmount),
    ].fold(0, (sum, value) => sum + value);

    double totalSgst = [
      ...b2bInvoices.map((e) => e.sgstAmount),
      ...b2clInvoices.map((e) => e.sgstAmount),
    ].fold(0, (sum, value) => sum + value);

    return ApiResponse<gstr1.GSTR1>(
      success: true,
      statusCode: 200,
      message: 'GSTR-1 details fetched successfully',
      data: gstr1.GSTR1(
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
        filingDate:
            DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ),
    );
  }

  Future<ApiResponse<String>> saveGSTR1(gstr1.GSTR1 gstr1Data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));

    return ApiResponse<String>(
      success: true,
      statusCode: 200,
      message: 'GSTR-1 saved successfully',
      data:
          'GSTR1_${gstr1Data.gstin}_${gstr1Data.returnPeriod}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<ApiResponse<String>> submitGSTR1(gstr1.GSTR1 gstr1Data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(1500)));

    return ApiResponse<String>(
      success: true,
      statusCode: 200,
      message: 'GSTR-1 submitted successfully',
      data:
          'GSTR1_${gstr1Data.gstin}_${gstr1Data.returnPeriod}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // GSTR-3B endpoints
  Future<ApiResponse<GSTR3BSummary>> getGSTR3BSummary(
    String gstin,
    String returnPeriod,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(500)));

    return ApiResponse<GSTR3BSummary>(
      success: true,
      statusCode: 200,
      message: 'GSTR-3B summary fetched successfully',
      data: GSTR3BSummary(
        gstin: gstin,
        returnPeriod: returnPeriod,
        totalOutwardSupplies: 1500000 + _random.nextDouble() * 500000,
        totalInwardSupplies: 1200000 + _random.nextDouble() * 400000,
        totalIgst: 120000 + _random.nextDouble() * 50000,
        totalCgst: 90000 + _random.nextDouble() * 30000,
        totalSgst: 90000 + _random.nextDouble() * 30000,
        totalCess: 15000 + _random.nextDouble() * 5000,
        totalTaxPayable: 300000 + _random.nextDouble() * 100000,
        totalItcAvailed: 250000 + _random.nextDouble() * 80000,
        status: 'Filed',
        filingDate:
            DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ),
    );
  }

  // GSTR-9 endpoints
  Future<ApiResponse<GSTR9>> autoPopulateGSTR9(
    String gstin,
    String financialYear,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(2000)));

    return ApiResponse<GSTR9>(
      success: true,
      statusCode: 200,
      message: 'GSTR-9 auto-populated successfully',
      data: _generateMockGSTR9(gstin, financialYear),
    );
  }

  // GSTR-9C endpoints
  Future<ApiResponse<GSTR9C>> autoPopulateGSTR9C(
    String gstin,
    String financialYear,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(2000)));

    return ApiResponse<GSTR9C>(
      success: true,
      statusCode: 200,
      message: 'GSTR-9C auto-populated successfully',
      data: _generateMockGSTR9C(gstin, financialYear),
    );
  }

  // Comparison endpoints
  Future<ApiResponse<ComparisonResult>> compareGSTR2AGSTR2B(
    String gstin,
    String returnPeriod,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(1500)));

    return ApiResponse<ComparisonResult>(
      success: true,
      statusCode: 200,
      message: 'GSTR-2A and GSTR-2B comparison completed successfully',
      data: _generateMockComparisonResult(
        'GSTR-2A vs GSTR-2B',
        gstin,
        returnPeriod,
        twoWayComparison: true,
      ),
    );
  }

  Future<ApiResponse<ComparisonResult>> compareGSTR1GSTR2BGSTR3B(
    String gstin,
    String returnPeriod,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(2000)));

    return ApiResponse<ComparisonResult>(
      success: true,
      statusCode: 200,
      message: 'GSTR-1, GSTR-2B, and GSTR-3B comparison completed successfully',
      data: _generateMockComparisonResult(
        'GSTR-1 vs GSTR-2B vs GSTR-3B',
        gstin,
        returnPeriod,
        twoWayComparison: false,
      ),
    );
  }

  // Helper methods to generate mock data
  gstr1.B2BInvoice _generateMockB2BInvoice(int index) {
    String counterpartyGstin = _generateRandomGSTIN('');
    double taxableValue = 10000 + _random.nextDouble() * 90000;
    double igstAmount = 0;
    double cgstAmount = 0;
    double sgstAmount = 0;

    // Randomly decide if it's IGST or CGST+SGST
    if (_random.nextBool()) {
      igstAmount = taxableValue * 0.18;
    } else {
      cgstAmount = taxableValue * 0.09;
      sgstAmount = taxableValue * 0.09;
    }

    return gstr1.B2BInvoice(
      id: 'B2B_${index}_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: 'INV${10000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(90))),
      counterpartyGstin: counterpartyGstin,
      counterpartyName: 'Supplier ${counterpartyGstin.substring(2, 7)}',
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

  gstr1.B2CLInvoice _generateMockB2CLInvoice(int index) {
    double taxableValue = 5000 + _random.nextDouble() * 45000;
    double igstAmount = 0;
    double cgstAmount = 0;
    double sgstAmount = 0;

    // Randomly decide if it's IGST or CGST+SGST
    if (_random.nextBool()) {
      igstAmount = taxableValue * 0.18;
    } else {
      cgstAmount = taxableValue * 0.09;
      sgstAmount = taxableValue * 0.09;
    }

    return gstr1.B2CLInvoice(
      id: 'B2CL_${index}_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: 'INVB2CL${10000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(90))),
      taxableValue: taxableValue,
      igstAmount: igstAmount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      cessAmount: taxableValue * 0.01,
      placeOfSupply: '27-Maharashtra',
    );
  }

  gstr1.B2CSInvoice _generateMockB2CSInvoice(int index) {
    double taxableValue = 1000 + _random.nextDouble() * 9000;

    return gstr1.B2CSInvoice(
      id: 'B2CS_${index}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'OE',
      placeOfSupply: '27-Maharashtra',
      taxableValue: taxableValue,
      igstAmount: 0,
      cgstAmount: taxableValue * 0.09,
      sgstAmount: taxableValue * 0.09,
      cessAmount: taxableValue * 0.01,
    );
  }

  gstr1.ExportInvoice _generateMockExportInvoice(int index) {
    double taxableValue = 20000 + _random.nextDouble() * 180000;

    return gstr1.ExportInvoice(
      id: 'EXP_${index}_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: 'INVEXP${10000 + index}',
      invoiceDate: DateTime.now().subtract(Duration(days: _random.nextInt(90))),
      taxableValue: taxableValue,
      igstAmount: taxableValue * 0.18,
      shippingBillNumber: 'SB${100000 + _random.nextInt(900000)}',
      shippingBillDate:
          DateTime.now().subtract(Duration(days: _random.nextInt(60))),
      portCode: 'INBOM1',
      exportType: _random.nextBool() ? 'With Payment' : 'Without Payment',
    );
  }

  GSTR9 _generateMockGSTR9(String gstin, String financialYear) {
    // Generate mock data for GSTR-9
    double totalOutwardSupplies = 18000000 + _random.nextDouble() * 6000000;
    double zeroRatedSupplies = totalOutwardSupplies * 0.05;
    double nilRatedSupplies = totalOutwardSupplies * 0.03;
    double exemptedSupplies = totalOutwardSupplies * 0.02;
    double nonGSTSupplies = totalOutwardSupplies * 0.01;

    double inwardSuppliesReverseCharge =
        2000000 + _random.nextDouble() * 1000000;
    double importsOfGoods = 3000000 + _random.nextDouble() * 1500000;
    double importsOfServices = 1000000 + _random.nextDouble() * 500000;

    double taxPayableOutwardSupplies = (totalOutwardSupplies -
            zeroRatedSupplies -
            nilRatedSupplies -
            exemptedSupplies -
            nonGSTSupplies) *
        0.18;
    double taxPayableReverseCharge = inwardSuppliesReverseCharge * 0.18;
    double interestPayable =
        (taxPayableOutwardSupplies + taxPayableReverseCharge) * 0.02;
    double lateFeePayable = 5000 + _random.nextDouble() * 5000;
    double penaltyPayable = 0;

    double itcAvailed = (importsOfGoods + importsOfServices) * 0.18;
    double itcReversed = itcAvailed * 0.05;
    double itcIneligible = itcAvailed * 0.03;

    double refundClaimed = taxPayableOutwardSupplies * 0.1;
    double refundSanctioned = refundClaimed * 0.8;
    double refundRejected = refundClaimed * 0.1;
    double refundPending = refundClaimed * 0.1;

    return GSTR9(
      gstin: gstin,
      financialYear: financialYear,
      legalName: 'Demo Company Pvt Ltd',
      tradeName: 'Demo Company',
      part1: GSTR9Part1(
        totalOutwardSupplies: totalOutwardSupplies,
        zeroRatedSupplies: zeroRatedSupplies,
        nilRatedSupplies: nilRatedSupplies,
        exemptedSupplies: exemptedSupplies,
        nonGSTSupplies: nonGSTSupplies,
      ),
      part2: GSTR9Part2(
        inwardSuppliesAttractingReverseCharge: inwardSuppliesReverseCharge,
        importsOfGoodsAndServices: importsOfGoods + importsOfServices,
        inwardSuppliesLiableToReverseCharge: inwardSuppliesReverseCharge,
      ),
      part3: GSTR9Part3(
        taxPayableOnOutwardSupplies: taxPayableOutwardSupplies,
        taxPayableOnReverseCharge: taxPayableReverseCharge,
        interestPayable: interestPayable,
        lateFeePayable: lateFeePayable,
        penaltyPayable: penaltyPayable,
      ),
      part4: GSTR9Part4(
        itcAvailedOnInvoices: itcAvailed,
        itcReversedAndReclaimed: itcReversed,
        itcAvailedButIneligible: itcIneligible,
      ),
      part5: GSTR9Part5(
        refundClaimed: refundClaimed,
        refundSanctioned: refundSanctioned,
        refundRejected: refundRejected,
        refundPending: refundPending,
      ),
      part6: GSTR9Part6(
        taxPayableAsPerSection73Or74: 0,
        taxPaidAsPerSection73Or74: 0,
        interestPayableAsPerSection73Or74: 0,
        interestPaidAsPerSection73Or74: 0,
      ),
    );
  }

  GSTR9C _generateMockGSTR9C(String gstin, String financialYear) {
    // Generate mock data for GSTR-9C
    double turnoverAsPerAuditedFinancialStatements =
        20000000 + _random.nextDouble() * 5000000;
    double turnoverAsPerAnnualReturn =
        19000000 + _random.nextDouble() * 4500000;
    double unReconciled =
        turnoverAsPerAuditedFinancialStatements - turnoverAsPerAnnualReturn;

    List<GSTR9CReconciliationItem> reconciliationItems = [
      GSTR9CReconciliationItem(
        description: 'Sales Return not considered in GST Returns',
        amount: unReconciled * 0.4,
        reason: 'Sales returns processed after filing of returns',
      ),
      GSTR9CReconciliationItem(
        description: 'Discount given to customers',
        amount: unReconciled * 0.3,
        reason: 'Credit notes issued after filing of returns',
      ),
      GSTR9CReconciliationItem(
        description: 'Other adjustments',
        amount: unReconciled * 0.3,
        reason: 'Miscellaneous adjustments',
      ),
    ];

    List<GSTR9CAuditorRecommendationItem> recommendations = [
      GSTR9CAuditorRecommendationItem(
        description: 'Additional tax liability on unreconciled turnover',
        amount: unReconciled * 0.18,
        reason: 'Tax not paid on the unreconciled turnover',
      ),
      GSTR9CAuditorRecommendationItem(
        description: 'Interest on delayed payment',
        amount: unReconciled * 0.18 * 0.18,
        reason: 'Interest for delayed payment of tax',
      ),
    ];

    double taxPayableAsPerReconciliation = unReconciled * 0.18;
    double taxPaidAsPerAnnualReturn = turnoverAsPerAnnualReturn * 0.18;
    double differentialTaxPayable =
        taxPayableAsPerReconciliation - taxPaidAsPerAnnualReturn;
    double interestPayable = differentialTaxPayable * 0.18;

    return GSTR9C(
      gstin: gstin,
      financialYear: financialYear,
      legalName: 'Demo Company Pvt Ltd',
      tradeName: 'Demo Company',
      reconciliation: GSTR9CReconciliation(
        turnoverAsPerAuditedFinancialStatements:
            turnoverAsPerAuditedFinancialStatements,
        turnoverAsPerAnnualReturn: turnoverAsPerAnnualReturn,
        unReconciled: unReconciled,
        reconciliationItems: reconciliationItems,
      ),
      auditorRecommendation: GSTR9CAuditorRecommendation(
        recommendations: recommendations,
      ),
      taxPayable: GSTR9CTaxPayable(
        taxPayableAsPerReconciliation: taxPayableAsPerReconciliation,
        taxPaidAsPerAnnualReturn: taxPaidAsPerAnnualReturn,
        differentialTaxPayable: differentialTaxPayable,
        interestPayable: interestPayable,
      ),
      auditorDetails: 'CA John Doe, M. No. 123456',
      certificationDetails:
          'Certified that the reconciliation statement has been prepared in accordance with the provisions of the CGST Act and rules made thereunder.',
    );
  }

  ComparisonResult _generateMockComparisonResult(
    String comparisonType,
    String gstin,
    String returnPeriod, {
    required bool twoWayComparison,
  }) {
    // Generate mock comparison items
    List<ComparisonItem> items = List.generate(
      50 + _random.nextInt(50),
      (index) => _generateMockComparisonItem(index, twoWayComparison),
    );

    // Calculate summary
    int matchedInvoices =
        items.where((item) => item.matchStatus == 'Matched').length;
    int partiallyMatchedInvoices =
        items.where((item) => item.matchStatus == 'Partially Matched').length;
    int unmatchedInvoices =
        items.where((item) => item.matchStatus == 'Not Matched').length;
    int onlyInSource1Invoices =
        items.where((item) => item.matchStatus == 'Only in Source1').length;
    int onlyInSource2Invoices =
        items.where((item) => item.matchStatus == 'Only in Source2').length;
    int? onlyInSource3Invoices = twoWayComparison
        ? null
        : items.where((item) => item.matchStatus == 'Only in Source3').length;

    double totalTaxableValueInSource1 =
        items.fold(0, (sum, item) => sum + item.taxableValueInSource1);
    double totalTaxableValueInSource2 =
        items.fold(0, (sum, item) => sum + item.taxableValueInSource2);
    double? totalTaxableValueInSource3 = twoWayComparison
        ? null
        : items.fold(
            0, (sum, item) => sum! + (item.taxableValueInSource3 ?? 0.0));

    double totalTaxInSource1 = items.fold(
        0,
        (sum, item) =>
            sum + item.igstInSource1 + item.cgstInSource1 + item.sgstInSource1);
    double totalTaxInSource2 = items.fold(
        0,
        (sum, item) =>
            sum + item.igstInSource2 + item.cgstInSource2 + item.sgstInSource2);
    double? totalTaxInSource3 = twoWayComparison
        ? null
        : items.fold(
            0,
            (sum, item) =>
                sum! +
                (item.igstInSource3 ?? 0.0) +
                (item.cgstInSource3 ?? 0.0) +
                (item.sgstInSource3 ?? 0.0));

    double taxDifference = totalTaxInSource1 - totalTaxInSource2;

    return ComparisonResult(
      comparisonType: comparisonType,
      generatedAt: DateTime.now(),
      items: items,
      summary: ComparisonSummary(
        totalInvoices: items.length,
        matchedInvoices: matchedInvoices,
        partiallyMatchedInvoices: partiallyMatchedInvoices,
        unmatchedInvoices: unmatchedInvoices,
        onlyInSource1Invoices: onlyInSource1Invoices,
        onlyInSource2Invoices: onlyInSource2Invoices,
        onlyInSource3Invoices: onlyInSource3Invoices,
        totalTaxableValueInSource1: totalTaxableValueInSource1,
        totalTaxableValueInSource2: totalTaxableValueInSource2,
        totalTaxableValueInSource3: totalTaxableValueInSource3,
        totalTaxInSource1: totalTaxInSource1,
        totalTaxInSource2: totalTaxInSource2,
        totalTaxInSource3: totalTaxInSource3,
        taxDifference: taxDifference,
      ),
    );
  }

  ComparisonItem _generateMockComparisonItem(int index, bool twoWayComparison) {
    // Generate random match status
    List<String> matchStatuses = [
      'Matched',
      'Partially Matched',
      'Not Matched',
      'Only in Source1',
      'Only in Source2',
    ];

    if (!twoWayComparison) {
      matchStatuses.add('Only in Source3');
    }

    String matchStatus = matchStatuses[_random.nextInt(matchStatuses.length)];

    // Generate random values based on match status
    double taxableValueInSource1 = 0;
    double taxableValueInSource2 = 0;
    double? taxableValueInSource3 = twoWayComparison ? null : 0;

    double igstInSource1 = 0;
    double igstInSource2 = 0;
    double? igstInSource3 = twoWayComparison ? null : 0;

    double cgstInSource1 = 0;
    double cgstInSource2 = 0;
    double? cgstInSource3 = twoWayComparison ? null : 0;

    double sgstInSource1 = 0;
    double sgstInSource2 = 0;
    double? sgstInSource3 = twoWayComparison ? null : 0;

    String remarks = '';

    switch (matchStatus) {
      case 'Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 = taxableValueInSource1;
        if (!twoWayComparison) taxableValueInSource3 = taxableValueInSource1;

        // Randomly decide if it's IGST or CGST+SGST
        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
          igstInSource2 = igstInSource1;
          if (!twoWayComparison) igstInSource3 = igstInSource1;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
          cgstInSource2 = cgstInSource1;
          sgstInSource2 = sgstInSource1;
          if (!twoWayComparison) {
            cgstInSource3 = cgstInSource1;
            sgstInSource3 = sgstInSource1;
          }
        }

        remarks = 'Invoice matched across all sources';
        break;

      case 'Partially Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 =
            taxableValueInSource1 * (0.9 + _random.nextDouble() * 0.2);
        if (!twoWayComparison)
          taxableValueInSource3 =
              taxableValueInSource1 * (0.9 + _random.nextDouble() * 0.2);

        // Randomly decide if it's IGST or CGST+SGST
        if (_random.nextBool()) {
          igstInSource1 = taxableValueInSource1 * 0.18;
          igstInSource2 = taxableValueInSource2 * 0.18;
          if (!twoWayComparison) igstInSource3 = taxableValueInSource3! * 0.18;
        } else {
          cgstInSource1 = taxableValueInSource1 * 0.09;
          sgstInSource1 = taxableValueInSource1 * 0.09;
          cgstInSource2 = taxableValueInSource2 * 0.09;
          sgstInSource2 = taxableValueInSource2 * 0.09;
          if (!twoWayComparison) {
            cgstInSource3 = taxableValueInSource3! * 0.09;
            sgstInSource3 = taxableValueInSource3 * 0.09;
          }
        }

        remarks = 'Invoice values differ slightly across sources';
        break;

      case 'Not Matched':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;
        taxableValueInSource2 = 10000 + _random.nextDouble() * 90000;
        if (!twoWayComparison)
          taxableValueInSource3 = 10000 + _random.nextDouble() * 90000;

        // Randomly decide if it's IGST or CGST+SGST for each source
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

        if (!twoWayComparison) {
          if (_random.nextBool()) {
            igstInSource3 = taxableValueInSource3! * 0.18;
          } else {
            cgstInSource3 = taxableValueInSource3! * 0.09;
            sgstInSource3 = taxableValueInSource3 * 0.09;
          }
        }

        remarks = 'Invoice values significantly different across sources';
        break;

      case 'Only in Source1':
        taxableValueInSource1 = 10000 + _random.nextDouble() * 90000;

        // Randomly decide if it's IGST or CGST+SGST
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

        // Randomly decide if it's IGST or CGST+SGST
        if (_random.nextBool()) {
          igstInSource2 = taxableValueInSource2 * 0.18;
        } else {
          cgstInSource2 = taxableValueInSource2 * 0.09;
          sgstInSource2 = taxableValueInSource2 * 0.09;
        }

        remarks = 'Invoice present only in Source2';
        break;

      case 'Only in Source3':
        if (!twoWayComparison) {
          taxableValueInSource3 = 10000 + _random.nextDouble() * 90000;

          // Randomly decide if it's IGST or CGST+SGST
          if (_random.nextBool()) {
            igstInSource3 = taxableValueInSource3 * 0.18;
          } else {
            cgstInSource3 = taxableValueInSource3 * 0.09;
            sgstInSource3 = taxableValueInSource3 * 0.09;
          }

          remarks = 'Invoice present only in Source3';
        }
        break;
    }

    return ComparisonItem(
      invoiceNumber: 'INV${10000 + index}',
      invoiceDate: DateTime.now()
          .subtract(Duration(days: _random.nextInt(90)))
          .toString()
          .substring(0, 10),
      counterpartyGstin: _generateRandomGSTIN(''),
      counterpartyName: 'Supplier $index',
      taxableValueInSource1: taxableValueInSource1,
      taxableValueInSource2: taxableValueInSource2,
      taxableValueInSource3: taxableValueInSource3,
      igstInSource1: igstInSource1,
      igstInSource2: igstInSource2,
      igstInSource3: igstInSource3,
      cgstInSource1: cgstInSource1,
      cgstInSource2: cgstInSource2,
      cgstInSource3: cgstInSource3,
      sgstInSource1: sgstInSource1,
      sgstInSource2: sgstInSource2,
      sgstInSource3: sgstInSource3,
      matchStatus: matchStatus,
      remarks: remarks,
    );
  }

  String _generateRandomGSTIN(String excludeGstin) {
    String gstin;
    do {
      String stateCode = (10 + _random.nextInt(30)).toString().padLeft(2, '0');
      String panNumber = 'ABCDE${_random.nextInt(10000)}'.padRight(10, 'X');
      String entityNumber = (1 + _random.nextInt(9)).toString();
      String checkDigit = 'Z';
      gstin = '$stateCode$panNumber$entityNumber$checkDigit';
    } while (gstin == excludeGstin);

    return gstin;
  }
}
