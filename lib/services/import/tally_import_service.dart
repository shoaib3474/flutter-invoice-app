import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/import/tally_data_model.dart';
import '../../models/gstr1_model.dart';
import '../../utils/error_handler.dart';
import '../../models/validation/invoice_validation_result.dart';
import '../validation/invoice_validation_service.dart';

class TallyImportService {
  final InvoiceValidationService _validationService;
  
  TallyImportService({
    required InvoiceValidationService validationService,
  }) : _validationService = validationService;
  
  // Parse Tally XML data and convert to TallyDataModel
  Future<List<TallyDataModel>> parseTallyData(String xmlData) async {
    try {
      // This is a simplified implementation
      // In a real app, you would use an XML parser library
      // For now, we'll assume the XML is already converted to JSON
      final jsonData = jsonDecode(xmlData);
      
      final List<dynamic> vouchers = jsonData['ENVELOPE']['BODY']['DATA']['TALLYMESSAGE'] ?? [];
      
      return vouchers.map((voucher) {
        final voucherData = voucher['VOUCHER'] ?? {};
        return TallyDataModel.fromJson(voucherData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to parse Tally data: ${e.toString()}');
    }
  }
  
  // Convert Tally data to GSTR1 model
  Future<GSTR1Model> convertToGSTR1(List<TallyDataModel> tallyData, String gstin, String returnPeriod) async {
    try {
      // Convert B2B invoices
      final b2bInvoices = tallyData
          .where((data) => data.partyGstin.isNotEmpty)
          .map((data) => B2BInvoice(
                customerGstin: data.partyGstin,
                customerName: data.partyName,
                invoiceNumber: data.voucherNumber,
                invoiceDate: data.voucherDate,
                invoiceValue: data.totalAmount,
                placeOfSupply: data.placeOfSupply,
                reverseCharge: data.isReverseCharge,
                invoiceType: 'Regular',
                eCommerceGstin: '',
                taxableValue: data.totalAmount - data.cgstAmount - data.sgstAmount - data.igstAmount - data.cessAmount,
                cgstAmount: data.cgstAmount,
                sgstAmount: data.sgstAmount,
                igstAmount: data.igstAmount,
                cessAmount: data.cessAmount,
              ))
          .toList();
      
      // Convert B2C Large invoices (value > 250000)
      final b2clInvoices = tallyData
          .where((data) => data.partyGstin.isEmpty && data.totalAmount > 250000)
          .map((data) => B2CLInvoice(
                invoiceNumber: data.voucherNumber,
                invoiceDate: data.voucherDate,
                invoiceValue: data.totalAmount,
                placeOfSupply: data.placeOfSupply,
                taxableValue: data.totalAmount - data.cgstAmount - data.sgstAmount - data.igstAmount - data.cessAmount,
                cgstAmount: data.cgstAmount,
                sgstAmount: data.sgstAmount,
                igstAmount: data.igstAmount,
                cessAmount: data.cessAmount,
                eCommerceGstin: '',
              ))
          .toList();
      
      // Convert HSN summary
      final hsnMap = <String, HSNSummary>{};
      
      for (var data in tallyData) {
        for (var item in data.items) {
          if (hsnMap.containsKey(item.hsnCode)) {
            final existing = hsnMap[item.hsnCode]!;
            hsnMap[item.hsnCode] = HSNSummary(
              hsnCode: item.hsnCode,
              description: existing.description,
              uqc: item.unit,
              totalQuantity: existing.totalQuantity + item.quantity,
              totalValue: existing.totalValue + item.amount,
              taxableValue: existing.taxableValue + item.amount,
              cgstAmount: existing.cgstAmount + (item.amount * item.cgstRate / 100),
              sgstAmount: existing.sgstAmount + (item.amount * item.sgstRate / 100),
              igstAmount: existing.igstAmount + (item.amount * item.igstRate / 100),
              cessAmount: existing.cessAmount + (item.amount * item.cessRate / 100),
            );
          } else {
            hsnMap[item.hsnCode] = HSNSummary(
              hsnCode: item.hsnCode,
              description: item.itemName,
              uqc: item.unit,
              totalQuantity: item.quantity,
              totalValue: item.amount,
              taxableValue: item.amount,
              cgstAmount: item.amount * item.cgstRate / 100,
              sgstAmount: item.amount * item.sgstRate / 100,
              igstAmount: item.amount * item.igstRate / 100,
              cessAmount: item.amount * item.cessRate / 100,
            );
          }
        }
      }
      
      // Create GSTR1 model
      final gstr1Model = GSTR1Model(
        gstin: gstin,
        returnPeriod: returnPeriod,
        filingDate: DateTime.now(),
        b2bInvoices: b2bInvoices,
        b2clInvoices: b2clInvoices,
        b2csInvoices: [], // B2C small invoices would be aggregated
        hsnSummary: hsnMap.values.toList(),
        docsIssued: [], // Document series would be extracted from invoice numbers
      );
      
      // Validate the converted data
      final validationResult = await _validationService.validateGSTR1(gstr1Model);
      
      if (!validationResult.isValid) {
        throw ValidationException(
          'Validation failed for imported Tally data',
          validationResult,
        );
      }
      
      return gstr1Model;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      if (e is ValidationException) {
        rethrow;
      }
      throw Exception('Failed to convert Tally data to GSTR1: ${e.toString()}');
    }
  }
  
  // Import Tally data from file
  Future<GSTR1Model> importFromFile(File file, String gstin, String returnPeriod) async {
    try {
      final xmlData = await file.readAsString();
      final tallyData = await parseTallyData(xmlData);
      
      // Validate the raw Tally data
      final validationResult = await _validationService.validateTallyData(tallyData);
      
      if (!validationResult.isValid) {
        throw ValidationException(
          'Validation failed for Tally data',
          validationResult,
        );
      }
      
      return await convertToGSTR1(tallyData, gstin, returnPeriod);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      if (e is ValidationException) {
        rethrow;
      }
      throw Exception('Failed to import Tally data from file: ${e.toString()}');
    }
  }
}

class ValidationException implements Exception {
  final String message;
  final InvoiceValidationResult validationResult;
  
  ValidationException(this.message, this.validationResult);
  
  @override
  String toString() {
    return message;
  }
}
