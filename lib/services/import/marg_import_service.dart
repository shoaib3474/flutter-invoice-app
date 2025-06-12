import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/import/marg_data_model.dart';
import '../../models/gstr1_model.dart';
import '../../utils/error_handler.dart';

class MargImportService {
  // Parse Marg JSON data and convert to MargDataModel
  Future<List<MargDataModel>> parseMargData(String jsonData) async {
    try {
      final List<dynamic> invoices = jsonDecode(jsonData);
      
      return invoices.map((invoice) => MargDataModel.fromJson(invoice)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to parse Marg data: ${e.toString()}');
    }
  }
  
  // Convert Marg data to GSTR1 model
  Future<GSTR1Model> convertToGSTR1(List<MargDataModel> margData, String gstin, String returnPeriod) async {
    try {
      // Convert B2B invoices
      final b2bInvoices = margData
          .where((data) => data.customerGstin.isNotEmpty)
          .map((data) => B2BInvoice(
                customerGstin: data.customerGstin,
                customerName: data.customerName,
                invoiceNumber: data.invoiceNumber,
                invoiceDate: data.invoiceDate,
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
      final b2clInvoices = margData
          .where((data) => data.customerGstin.isEmpty && data.totalAmount > 250000)
          .map((data) => B2CLInvoice(
                invoiceNumber: data.invoiceNumber,
                invoiceDate: data.invoiceDate,
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
      
      for (var data in margData) {
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
      return GSTR1Model(
        gstin: gstin,
        returnPeriod: returnPeriod,
        filingDate: DateTime.now(),
        b2bInvoices: b2bInvoices,
        b2clInvoices: b2clInvoices,
        b2csInvoices: [], // B2C small invoices would be aggregated
        hsnSummary: hsnMap.values.toList(),
        docsIssued: [], // Document series would be extracted from invoice numbers
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to convert Marg data to GSTR1: ${e.toString()}');
    }
  }
  
  // Import Marg data from file
  Future<GSTR1Model> importFromFile(File file, String gstin, String returnPeriod) async {
    try {
      final jsonData = await file.readAsString();
      final margData = await parseMargData(jsonData);
      return await convertToGSTR1(margData, gstin, returnPeriod);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to import Marg data from file: ${e.toString()}');
    }
  }
}
