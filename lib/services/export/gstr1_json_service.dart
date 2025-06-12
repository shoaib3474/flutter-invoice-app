import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/gstr1_model.dart';
import '../../utils/error_handler.dart';

class GSTR1JsonService {
  // Convert GSTR1 model to GST portal compatible JSON
  Future<String> convertToGstPortalJson(GSTR1Model gstr1) async {
    try {
      // Format according to GST portal requirements
      final Map<String, dynamic> gstJson = {
        'gstin': gstr1.gstin,
        'fp': gstr1.returnPeriod,
        'b2b': _formatB2BInvoices(gstr1.b2bInvoices),
        'b2cl': _formatB2CLInvoices(gstr1.b2clInvoices),
        'b2cs': _formatB2CSInvoices(gstr1.b2csInvoices),
        'hsn': {
          'data': _formatHSNSummary(gstr1.hsnSummary),
        },
        'doc_issue': {
          'doc_det': _formatDocsIssued(gstr1.docsIssued),
        },
      };
      
      return jsonEncode(gstJson);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to convert GSTR1 to GST portal JSON: ${e.toString()}');
    }
  }
  
  // Format B2B invoices
  List<Map<String, dynamic>> _formatB2BInvoices(List<B2BInvoice> invoices) {
    final Map<String, List<Map<String, dynamic>>> groupedByGstin = {};
    
    // Group invoices by GSTIN
    for (var invoice in invoices) {
      if (!groupedByGstin.containsKey(invoice.customerGstin)) {
        groupedByGstin[invoice.customerGstin] = [];
      }
      
      groupedByGstin[invoice.customerGstin]!.add({
        'inv_typ': invoice.invoiceType,
        'pos': invoice.placeOfSupply,
        'inum': invoice.invoiceNumber,
        'idt': _formatDate(invoice.invoiceDate),
        'val': invoice.invoiceValue.toStringAsFixed(2),
        'rchrg': invoice.reverseCharge ? 'Y' : 'N',
        'etin': invoice.eCommerceGstin,
        'itms': [
          {
            'num': 1,
            'itm_det': {
              'txval': invoice.taxableValue.toStringAsFixed(2),
              'rt': _calculateTaxRate(invoice),
              'camt': invoice.cgstAmount.toStringAsFixed(2),
              'samt': invoice.sgstAmount.toStringAsFixed(2),
              'iamt': invoice.igstAmount.toStringAsFixed(2),
              'csamt': invoice.cessAmount.toStringAsFixed(2),
            },
          },
        ],
      });
    }
    
    // Format for GST portal
    final List<Map<String, dynamic>> result = [];
    
    groupedByGstin.forEach((gstin, invoices) {
      result.add({
        'ctin': gstin,
        'inv': invoices,
      });
    });
    
    return result;
  }
  
  // Format B2CL invoices
  List<Map<String, dynamic>> _formatB2CLInvoices(List<B2CLInvoice> invoices) {
    final Map<String, List<Map<String, dynamic>>> groupedByPos = {};
    
    // Group invoices by Place of Supply
    for (var invoice in invoices) {
      if (!groupedByPos.containsKey(invoice.placeOfSupply)) {
        groupedByPos[invoice.placeOfSupply] = [];
      }
      
      groupedByPos[invoice.placeOfSupply]!.add({
        'inum': invoice.invoiceNumber,
        'idt': _formatDate(invoice.invoiceDate),
        'val': invoice.invoiceValue.toStringAsFixed(2),
        'etin': invoice.eCommerceGstin,
        'itms': [
          {
            'num': 1,
            'itm_det': {
              'txval': invoice.taxableValue.toStringAsFixed(2),
              'rt': _calculateTaxRateB2CL(invoice),
              'iamt': invoice.igstAmount.toStringAsFixed(2),
              'csamt': invoice.cessAmount.toStringAsFixed(2),
            },
          },
        ],
      });
    }
    
    // Format for GST portal
    final List<Map<String, dynamic>> result = [];
    
    groupedByPos.forEach((pos, invoices) {
      result.add({
        'pos': pos,
        'inv': invoices,
      });
    });
    
    return result;
  }
  
  // Format B2CS invoices
  List<Map<String, dynamic>> _formatB2CSInvoices(List<B2CSInvoice> invoices) {
    final List<Map<String, dynamic>> result = [];
    
    // Group by type, place of supply, and tax rate
    final Map<String, Map<String, Map<double, B2CSInvoice>>> grouped = {};
    
    for (var invoice in invoices) {
      final type = invoice.type;
      final pos = invoice.placeOfSupply;
      final rate = _calculateTaxRateB2CS(invoice);
      
      if (!grouped.containsKey(type)) {
        grouped[type] = {};
      }
      
      if (!grouped[type]!.containsKey(pos)) {
        grouped[type]![pos] = {};
      }
      
      if (!grouped[type]![pos]!.containsKey(rate)) {
        grouped[type]![pos]![rate] = invoice;
      } else {
        // Aggregate values
        final existing = grouped[type]![pos]![rate]!;
        grouped[type]![pos]![rate] = B2CSInvoice(
          type: existing.type,
          placeOfSupply: existing.placeOfSupply,
          taxableValue: existing.taxableValue + invoice.taxableValue,
          cgstAmount: existing.cgstAmount + invoice.cgstAmount,
          sgstAmount: existing.sgstAmount + invoice.sgstAmount,
          igstAmount: existing.igstAmount + invoice.igstAmount,
          cessAmount: existing.cessAmount + invoice.cessAmount,
          eCommerceGstin: invoice.eCommerceGstin,
        );
      }
    }
    
    // Format for GST portal
    grouped.forEach((type, posList) {
      posList.forEach((pos, rateList) {
        rateList.forEach((rate, invoice) {
          result.add({
            'sply_ty': type,
            'pos': pos,
            'typ': 'OE', // Regular B2CS
            'txval': invoice.taxableValue.toStringAsFixed(2),
            'rt': rate.toStringAsFixed(2),
            'iamt': invoice.igstAmount.toStringAsFixed(2),
            'camt': invoice.cgstAmount.toStringAsFixed(2),
            'samt': invoice.sgstAmount.toStringAsFixed(2),
            'csamt': invoice.cessAmount.toStringAsFixed(2),
            'etin': invoice.eCommerceGstin,
          });
        });
      });
    });
    
    return result;
  }
  
  // Format HSN summary
  List<Map<String, dynamic>> _formatHSNSummary(List<HSNSummary> hsnSummary) {
    return hsnSummary.map((hsn) {
      return {
        'num': 1,
        'hsn_sc': hsn.hsnCode,
        'desc': hsn.description,
        'uqc': hsn.uqc,
        'qty': hsn.totalQuantity.toStringAsFixed(2),
        'val': hsn.totalValue.toStringAsFixed(2),
        'txval': hsn.taxableValue.toStringAsFixed(2),
        'iamt': hsn.igstAmount.toStringAsFixed(2),
        'camt': hsn.cgstAmount.toStringAsFixed(2),
        'samt': hsn.sgstAmount.toStringAsFixed(2),
        'csamt': hsn.cessAmount.toStringAsFixed(2),
      };
    }).toList();
  }
  
  // Format documents issued
  List<Map<String, dynamic>> _formatDocsIssued(List<DocIssued> docsIssued) {
    return docsIssued.map((doc) {
      return {
        'doc_num': 1,
        'doc_typ': doc.docType,
        'doc_from': doc.docFromNumber.toString(),
        'doc_to': doc.docToNumber.toString(),
        'doc_totl': doc.totalDocsIssued,
        'cancel': doc.cancelledDocuments,
        'net_issue': doc.netDocumentsIssued,
      };
    }).toList();
  }
  
  // Format date to DD-MM-YYYY
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
  
  // Calculate tax rate for B2B invoice
  double _calculateTaxRate(B2BInvoice invoice) {
    if (invoice.igstAmount > 0) {
      return (invoice.igstAmount / invoice.taxableValue) * 100;
    } else {
      return ((invoice.cgstAmount + invoice.sgstAmount) / invoice.taxableValue) * 100;
    }
  }
  
  // Calculate tax rate for B2CL invoice
  double _calculateTaxRateB2CL(B2CLInvoice invoice) {
    return (invoice.igstAmount / invoice.taxableValue) * 100;
  }
  
  // Calculate tax rate for B2CS invoice
  double _calculateTaxRateB2CS(B2CSInvoice invoice) {
    if (invoice.igstAmount > 0) {
      return (invoice.igstAmount / invoice.taxableValue) * 100;
    } else {
      return ((invoice.cgstAmount + invoice.sgstAmount) / invoice.taxableValue) * 100;
    }
  }
  
  // Save JSON to file
  Future<File> saveJsonToFile(String jsonData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.json';
      final file = File(filePath);
      
      await file.writeAsString(jsonData);
      
      return file;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save JSON to file: ${e.toString()}');
    }
  }
}
