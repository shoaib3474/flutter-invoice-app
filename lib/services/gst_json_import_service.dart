import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/repositories/supabase/supabase_gst_returns_repository.dart';

enum GstReturnType {
  gstr1,
  gstr3b,
  gstr9,
  gstr9c
}

class GstJsonImportService {
  final SupabaseGstReturnsRepository _repository = SupabaseGstReturnsRepository();
  
  /// Import GST return from JSON file
  Future<dynamic> importFromJsonFile(GstReturnType returnType) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }
      
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      return importFromJsonString(returnType, jsonString);
    } catch (e) {
      debugPrint('Error importing from JSON file: $e');
      rethrow;
    }
  }
  
  /// Import GST return from JSON string
  Future<dynamic> importFromJsonString(GstReturnType returnType, String jsonString) async {
    try {
      final jsonData = json.decode(jsonString);
      
      switch (returnType) {
        case GstReturnType.gstr1:
          final gstr1 = GSTR1.fromJson(jsonData);
          await _repository.saveGSTR1(gstr1);
          return gstr1;
          
        case GstReturnType.gstr3b:
          final gstr3b = GSTR3B.fromJson(jsonData);
          await _repository.saveGSTR3B(gstr3b);
          return gstr3b;
          
        case GstReturnType.gstr9:
          final gstr9 = GSTR9.fromJson(jsonData);
          await _repository.saveGSTR9(gstr9);
          return gstr9;
          
        case GstReturnType.gstr9c:
          final gstr9c = GSTR9C.fromJson(jsonData);
          await _repository.saveGSTR9C(gstr9c);
          return gstr9c;
      }
    } catch (e) {
      debugPrint('Error importing from JSON string: $e');
      rethrow;
    }
  }
  
  /// Export GST return to JSON file
  Future<String> exportToJsonFile(GstReturnType returnType, dynamic data) async {
    try {
      final jsonData = _convertToJson(returnType, data);
      final jsonString = json.encode(jsonData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _getFileName(returnType, data);
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      debugPrint('Error exporting to JSON file: $e');
      rethrow;
    }
  }
  
  /// Export GST return to JSON string
  String exportToJsonString(GstReturnType returnType, dynamic data) {
    try {
      final jsonData = _convertToJson(returnType, data);
      return json.encode(jsonData);
    } catch (e) {
      debugPrint('Error exporting to JSON string: $e');
      rethrow;
    }
  }
  
  /// Validate JSON data for GST return
  bool validateJsonData(GstReturnType returnType, String jsonString) {
    try {
      final jsonData = json.decode(jsonString);
      
      switch (returnType) {
        case GstReturnType.gstr1:
          // Basic validation for GSTR1
          return jsonData['gstin'] != null && 
                 jsonData['returnPeriod'] != null &&
                 jsonData['b2bInvoices'] != null;
          
        case GstReturnType.gstr3b:
          // Basic validation for GSTR3B
          return jsonData['gstin'] != null && 
                 jsonData['returnPeriod'] != null &&
                 jsonData['outwardSupplies'] != null;
          
        case GstReturnType.gstr9:
          // Basic validation for GSTR9
          return jsonData['gstin'] != null && 
                 jsonData['financialYear'] != null &&
                 jsonData['part1'] != null;
          
        case GstReturnType.gstr9c:
          // Basic validation for GSTR9C
          return jsonData['gstin'] != null && 
                 jsonData['financialYear'] != null &&
                 jsonData['reconciliation'] != null;
      }
    } catch (e) {
      debugPrint('Error validating JSON data: $e');
      return false;
    }
  }
  
  /// Helper method to convert GST return to JSON
  Map<String, dynamic> _convertToJson(GstReturnType returnType, dynamic data) {
    switch (returnType) {
      case GstReturnType.gstr1:
        return (data as GSTR1).toJson();
      case GstReturnType.gstr3b:
        return (data as GSTR3B).toJson();
      case GstReturnType.gstr9:
        return (data as GSTR9).toJson();
      case GstReturnType.gstr9c:
        return (data as GSTR9C).toJson();
    }
  }
  
  /// Helper method to generate file name
  String _getFileName(GstReturnType returnType, dynamic data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    switch (returnType) {
      case GstReturnType.gstr1:
        final gstr1 = data as GSTR1;
        return 'GSTR1_${gstr1.gstin}_${gstr1.returnPeriod}_$timestamp.json';
      case GstReturnType.gstr3b:
        final gstr3b = data as GSTR3B;
        return 'GSTR3B_${gstr3b.gstin}_${gstr3b.returnPeriod}_$timestamp.json';
      case GstReturnType.gstr9:
        final gstr9 = data as GSTR9;
        return 'GSTR9_${gstr9.gstin}_${gstr9.financialYear}_$timestamp.json';
      case GstReturnType.gstr9c:
        final gstr9c = data as GSTR9C;
        return 'GSTR9C_${gstr9c.gstin}_${gstr9c.financialYear}_$timestamp.json';
    }
  }
}
