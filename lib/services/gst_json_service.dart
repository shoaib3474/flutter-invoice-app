import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr2a_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr2b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr4_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/qrmp_model.dart';
import 'package:flutter_invoice_app/utils/gstin_validator.dart';

class GstJsonService {
  /// Export GST return data to JSON file
  Future<String> exportToJson<T>(T gstReturn, String gstin, String period) async {
    try {
      // Validate GSTIN
      final validationResult = GstinValidator.validate(gstin);
      if (!validationResult.isValid) {
        throw Exception('Invalid GSTIN: ${validationResult.message}');
      }

      final directory = await getApplicationDocumentsDirectory();
      String fileName;
      Map<String, dynamic> jsonData;

      if (gstReturn is GSTR1) {
        fileName = 'GSTR1_${gstin}_${period}.json';
        jsonData = gstReturn.toJson();
      } else if (gstReturn is GSTR3B) {
        fileName = 'GSTR3B_${gstin}_${period}.json';
        jsonData = gstReturn.toJson();
      } else if (gstReturn is GSTR9) {
        fileName = 'GSTR9_${gstin}_${period}.json';
        jsonData = gstReturn.toJson();
      } else if (gstReturn is GSTR9C) {
        fileName = 'GSTR9C_${gstin}_${period}.json';
        jsonData = gstReturn.toJson();
      } else if (gstReturn is QRMPScheme) {
        fileName = 'QRMP_${gstin}_${period}.json';
        jsonData = gstReturn.toJson();
      } else {
        throw Exception('Unsupported GST return type');
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(json.encode(jsonData));
      return file.path;
    } catch (e) {
      throw Exception('Failed to export GST data: ${e.toString()}');
    }
  }

  /// Import GST return data from JSON file
  Future<T> importFromJson<T>(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
      
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      
      // Determine the type of GST return based on file name
      final fileName = file.path.split('/').last;
      
      if (fileName.startsWith('GSTR1_')) {
        return GSTR1.fromJson(jsonData) as T;
      } else if (fileName.startsWith('GSTR3B_')) {
        return GSTR3B.fromJson(jsonData) as T;
      } else if (fileName.startsWith('GSTR9_')) {
        return GSTR9.fromJson(jsonData) as T;
      } else if (fileName.startsWith('GSTR9C_')) {
        return GSTR9C.fromJson(jsonData) as T;
      } else if (fileName.startsWith('QRMP_')) {
        return QRMPScheme.fromJson(jsonData) as T;
      } else {
        throw Exception('Unsupported GST return type');
      }
    } catch (e) {
      throw Exception('Failed to import GST data: ${e.toString()}');
    }
  }

  /// Validate JSON data against expected schema
  Future<bool> validateJsonSchema(String jsonString, String returnType) async {
    try {
      final jsonData = json.decode(jsonString);
      
      // Basic validation based on return type
      switch (returnType) {
        case 'GSTR1':
          return _validateGSTR1Schema(jsonData);
        case 'GSTR3B':
          return _validateGSTR3BSchema(jsonData);
        case 'GSTR9':
          return _validateGSTR9Schema(jsonData);
        case 'GSTR9C':
          return _validateGSTR9CSchema(jsonData);
        case 'QRMP':
          return _validateQRMPSchema(jsonData);
        default:
          throw Exception('Unsupported GST return type');
      }
    } catch (e) {
      throw Exception('JSON validation failed: ${e.toString()}');
    }
  }

  /// Validate GSTR1 JSON schema
  bool _validateGSTR1Schema(Map<String, dynamic> jsonData) {
    // Check for required fields
    if (!jsonData.containsKey('gstin') ||
        !jsonData.containsKey('returnPeriod') ||
        !jsonData.containsKey('b2bInvoices')) {
      return false;
    }
    
    // Validate GSTIN
    final validationResult = GstinValidator.validate(jsonData['gstin']);
    if (!validationResult.isValid) {
      return false;
    }
    
    return true;
  }

  /// Validate GSTR3B JSON schema
  bool _validateGSTR3BSchema(Map<String, dynamic> jsonData) {
    // Check for required fields
    if (!jsonData.containsKey('gstin') ||
        !jsonData.containsKey('returnPeriod') ||
        !jsonData.containsKey('outwardSupplies')) {
      return false;
    }
    
    // Validate GSTIN
    final validationResult = GstinValidator.validate(jsonData['gstin']);
    if (!validationResult.isValid) {
      return false;
    }
    
    return true;
  }

  /// Validate GSTR9 JSON schema
  bool _validateGSTR9Schema(Map<String, dynamic> jsonData) {
    // Check for required fields
    if (!jsonData.containsKey('gstin') ||
        !jsonData.containsKey('financialYear') ||
        !jsonData.containsKey('part1')) {
      return false;
    }
    
    // Validate GSTIN
    final validationResult = GstinValidator.validate(jsonData['gstin']);
    if (!validationResult.isValid) {
      return false;
    }
    
    return true;
  }

  /// Validate GSTR9C JSON schema
  bool _validateGSTR9CSchema(Map<String, dynamic> jsonData) {
    // Check for required fields
    if (!jsonData.containsKey('gstin') ||
        !jsonData.containsKey('financialYear') ||
        !jsonData.containsKey('reconciliation')) {
      return false;
    }
    
    // Validate GSTIN
    final validationResult = GstinValidator.validate(jsonData['gstin']);
    if (!validationResult.isValid) {
      return false;
    }
    
    return true;
  }

  /// Validate QRMP JSON schema
  bool _validateQRMPSchema(Map<String, dynamic> jsonData) {
    // Check for required fields
    if (!jsonData.containsKey('gstin') ||
        !jsonData.containsKey('financialYear') ||
        !jsonData.containsKey('quarter') ||
        !jsonData.containsKey('monthlyPayments') ||
        !jsonData.containsKey('quarterlyReturn')) {
      return false;
    }
    
    // Validate GSTIN
    final validationResult = GstinValidator.validate(jsonData['gstin']);
    if (!validationResult.isValid) {
      return false;
    }
    
    return true;
  }
}
