import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';
import 'package:csv/csv.dart';

import '../services/converter/invoice_converter_service.dart';

class FileFormatDetector {
  static Future<InvoiceFormat?> detectFormat(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final String extension = filePath.split('.').last.toLowerCase();
      
      // First check by extension
      switch (extension) {
        case 'json':
          return InvoiceFormat.json;
        case 'xml':
          return await _detectXmlFormat(file);
        case 'csv':
          return InvoiceFormat.csv;
        default:
          // Try to detect by content
          return await _detectByContent(file);
      }
    } catch (e) {
      print('Error detecting file format: $e');
      return null;
    }
  }

  static Future<InvoiceFormat?> _detectXmlFormat(File file) async {
    try {
      final String content = await file.readAsString();
      final document = XmlDocument.parse(content);
      
      // Check for Tally XML
      if (document.findAllElements('TALLYMESSAGE').isNotEmpty ||
          document.findAllElements('VOUCHER').isNotEmpty) {
        return InvoiceFormat.tally;
      }
      
      // Generic XML
      return InvoiceFormat.xml;
    } catch (e) {
      print('Error detecting XML format: $e');
      return InvoiceFormat.xml;
    }
  }

  static Future<InvoiceFormat?> _detectByContent(File file) async {
    try {
      final String content = await file.readAsString();
      
      // Try to parse as JSON
      try {
        final json = jsonDecode(content);
        
        // Check for specific keys to identify the format
        if (json is Map<String, dynamic>) {
          if (json.containsKey('DocNumber') || json.containsKey('Line')) {
            return InvoiceFormat.quickbooks;
          } else if (json.containsKey('invoice_number') && json.containsKey('customer_name')) {
            return InvoiceFormat.billShill;
          } else if (json.containsKey('customer_email') && json.containsKey('customer_phone')) {
            return InvoiceFormat.zoho;
          }
        }
        
        return InvoiceFormat.json;
      } catch (_) {
        // Not JSON, try XML
        try {
          XmlDocument.parse(content);
          return InvoiceFormat.xml;
        } catch (_) {
          // Try CSV
          try {
            const CsvToListConverter().convert(content);
            return InvoiceFormat.csv;
          } catch (_) {
            // Unknown format
            return null;
          }
        }
      }
    } catch (e) {
      print('Error detecting content format: $e');
      return null;
    }
  }
}
