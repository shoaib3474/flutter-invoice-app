import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../converter/invoice_converter_service.dart';

class FileFormatDetector {
  // Detect the format of a file
  static Future<InvoiceFormat?> detectFormat(String filePath) async {
    try {
      final File file = File(filePath);
      final String extension = path.extension(filePath).toLowerCase();
      
      // First try to detect by extension
      switch (extension) {
        case '.json':
          return await _detectJsonFormat(file);
        case '.xml':
          return await _detectXmlFormat(file);
        case '.csv':
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

  // Detect JSON format
  static Future<InvoiceFormat> _detectJsonFormat(File file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      
      // Check for Bill-Shill format
      if (json.containsKey('invoice_number') && 
          json.containsKey('customer_name') && 
          json.containsKey('items')) {
        return InvoiceFormat.billShill;
      }
      
      // Check for Zoho format
      if (json.containsKey('invoice_number') && 
          json.containsKey('customer_name') && 
          json.containsKey('customer_email')) {
        return InvoiceFormat.zoho;
      }
      
      // Check for QuickBooks format
      if (json.containsKey('doc_number') && 
          json.containsKey('customer_ref') && 
          json.containsKey('line')) {
        return InvoiceFormat.quickbooks;
      }
      
      // Default to generic JSON
      return InvoiceFormat.json;
    } catch (e) {
      // If we can't parse as JSON, default to generic JSON
      return InvoiceFormat.json;
    }
  }

  // Detect XML format
  static Future<InvoiceFormat> _detectXmlFormat(File file) async {
    try {
      final content = await file.readAsString();
      final document = XmlDocument.parse(content);
      
      // Check for Tally format
      if (document.findAllElements('TALLYMESSAGE').isNotEmpty ||
          document.findAllElements('VOUCHER').isNotEmpty) {
        return InvoiceFormat.tally;
      }
      
      // Default to generic XML
      return InvoiceFormat.xml;
    } catch (e) {
      // If we can't parse as XML, default to generic XML
      return InvoiceFormat.xml;
    }
  }

  // Detect by content
  static Future<InvoiceFormat?> _detectByContent(File file) async {
    try {
      final content = await file.readAsString();
      
      // Try to parse as JSON
      try {
        jsonDecode(content);
        return await _detectJsonFormat(file);
      } catch (e) {
        // Not JSON
      }
      
      // Try to parse as XML
      try {
        XmlDocument.parse(content);
        return await _detectXmlFormat(file);
      } catch (e) {
        // Not XML
      }
      
      // Check if it looks like CSV
      if (content.contains(',') && 
          content.split('\n').length > 1 && 
          content.split('\n')[0].split(',').length > 1) {
        return InvoiceFormat.csv;
      }
      
      // Can't determine format
      return null;
    } catch (e) {
      return null;
    }
  }
}
