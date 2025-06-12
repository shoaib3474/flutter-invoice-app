import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/gstr9_model.dart';
import '../models/gstr1_model.dart';
import '../models/gstr3b_model.dart';

class GSTR9Service {
  // Singleton pattern
  static final GSTR9Service _instance = GSTR9Service._internal();
  factory GSTR9Service() => _instance;
  GSTR9Service._internal();

  // Generate GSTR9 from GSTR1 and GSTR3B data
  Future<GSTR9> generateGSTR9FromReturns(
      List<GSTR1> gstr1Returns, List<GSTR3B> gstr3bReturns, String financialYear) async {
    // Extract basic information from the first return
    final String gstin = gstr1Returns.first.gstin;
    final String legalName = gstr1Returns.first.legalName;
    final String tradeName = gstr1Returns.first.tradeName;

    // Calculate Part 1 - Details of outward supplies
    double totalOutwardSupplies = 0;
    double zeroRatedSupplies = 0;
    double nilRatedSupplies = 0;
    double exemptedSupplies = 0;
    double nonGSTSupplies = 0;

    for (var gstr1 in gstr1Returns) {
      // Sum up all outward supplies
      totalOutwardSupplies += gstr1.b2bInvoices.fold(0, (sum, invoice) => sum + invoice.totalValue);
      totalOutwardSupplies += gstr1.b2clInvoices.fold(0, (sum, invoice) => sum + invoice.totalValue);
      totalOutwardSupplies += gstr1.b2csInvoices.fold(0, (sum, invoice) => sum + invoice.totalValue);
      totalOutwardSupplies += gstr1.exportInvoices.fold(0, (sum, invoice) => sum + invoice.totalValue);

      // Calculate zero-rated supplies (exports)
      zeroRatedSupplies += gstr1.exportInvoices.fold(0, (sum, invoice) => sum + invoice.totalValue);

      // Calculate nil-rated, exempted, and non-GST supplies
      // This is a simplified approach; in a real app, you would need more detailed data
      nilRatedSupplies += gstr1.nilRatedSupplies.fold(0, (sum, supply) => sum + supply.totalValue);
      exemptedSupplies += gstr1.exemptedSupplies.fold(0, (sum, supply) => sum + supply.totalValue);
      nonGSTSupplies += gstr1.nonGSTSupplies.fold(0, (sum, supply) => sum + supply.totalValue);
    }

    // Calculate Part 2 - Details of inward supplies
    double inwardSuppliesAttractingReverseCharge = 0;
    double importsOfGoodsAndServices = 0;
    double inwardSuppliesLiableToReverseCharge = 0;

    for (var gstr3b in gstr3bReturns) {
      // Calculate inward supplies attracting reverse charge
      inwardSuppliesAttractingReverseCharge += gstr3b.inwardSuppliesAttractingReverseCharge;
      
      // Calculate imports of goods and services
      importsOfGoodsAndServices += gstr3b.importsOfGoodsAndServices;
      
      // Calculate inward supplies liable to reverse charge
      inwardSuppliesLiableToReverseCharge += gstr3b.inwardSuppliesLiableToReverseCharge;
    }

    // Calculate Part 3 - Details of tax paid
    double taxPayableOnOutwardSupplies = 0;
    double taxPayableOnReverseCharge = 0;
    double interestPayable = 0;
    double lateFeePayable = 0;
    double penaltyPayable = 0;

    for (var gstr3b in gstr3bReturns) {
      // Calculate tax payable on outward supplies
      taxPayableOnOutwardSupplies += gstr3b.taxPayableOnOutwardSupplies;
      
      // Calculate tax payable on reverse charge
      taxPayableOnReverseCharge += gstr3b.taxPayableOnReverseCharge;
      
      // Calculate interest, late fee, and penalty
      interestPayable += gstr3b.interestPayable;
      lateFeePayable += gstr3b.lateFeePayable;
      penaltyPayable += gstr3b.penaltyPayable;
    }

    // Create Part 4, 5, and 6 with default values (to be filled by the user)
    final part4 = GSTR9Part4(
      itcAvailedOnInvoices: 0,
      itcReversedAndReclaimed: 0,
      itcAvailedButIneligible: 0,
    );

    final part5 = GSTR9Part5(
      refundClaimed: 0,
      refundSanctioned: 0,
      refundRejected: 0,
      refundPending: 0,
    );

    final part6 = GSTR9Part6(
      taxPayableAsPerSection73Or74: 0,
      taxPaidAsPerSection73Or74: 0,
      interestPayableAsPerSection73Or74: 0,
      interestPaidAsPerSection73Or74: 0,
    );

    // Create the GSTR9 object
    return GSTR9(
      gstin: gstin,
      financialYear: financialYear,
      legalName: legalName,
      tradeName: tradeName,
      part1: GSTR9Part1(
        totalOutwardSupplies: totalOutwardSupplies,
        zeroRatedSupplies: zeroRatedSupplies,
        nilRatedSupplies: nilRatedSupplies,
        exemptedSupplies: exemptedSupplies,
        nonGSTSupplies: nonGSTSupplies,
      ),
      part2: GSTR9Part2(
        inwardSuppliesAttractingReverseCharge: inwardSuppliesAttractingReverseCharge,
        importsOfGoodsAndServices: importsOfGoodsAndServices,
        inwardSuppliesLiableToReverseCharge: inwardSuppliesLiableToReverseCharge,
      ),
      part3: GSTR9Part3(
        taxPayableOnOutwardSupplies: taxPayableOnOutwardSupplies,
        taxPayableOnReverseCharge: taxPayableOnReverseCharge,
        interestPayable: interestPayable,
        lateFeePayable: lateFeePayable,
        penaltyPayable: penaltyPayable,
      ),
      part4: part4,
      part5: part5,
      part6: part6,
    );
  }

  // Save GSTR9 to a JSON file
  Future<String> saveGSTR9ToJson(GSTR9 gstr9) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'GSTR9_${gstr9.gstin}_${gstr9.financialYear}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonEncode(gstr9.toJson()));
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save GSTR9: $e');
    }
  }

  // Load GSTR9 from a JSON file
  Future<GSTR9> loadGSTR9FromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      return GSTR9.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load GSTR9: $e');
    }
  }

  // Update GSTR9 with user-provided data
  Future<GSTR9> updateGSTR9(GSTR9 gstr9, {
    GSTR9Part4? part4,
    GSTR9Part5? part5,
    GSTR9Part6? part6,
  }) async {
    return GSTR9(
      gstin: gstr9.gstin,
      financialYear: gstr9.financialYear,
      legalName: gstr9.legalName,
      tradeName: gstr9.tradeName,
      part1: gstr9.part1,
      part2: gstr9.part2,
      part3: gstr9.part3,
      part4: part4 ?? gstr9.part4,
      part5: part5 ?? gstr9.part5,
      part6: part6 ?? gstr9.part6,
    );
  }

  // Generate a PDF report for GSTR9
  Future<String> generatePDFReport(GSTR9 gstr9) async {
    // This is a placeholder for PDF generation functionality
    // In a real app, you would use a PDF generation library
    throw UnimplementedError('PDF generation not implemented yet');
  }
}
