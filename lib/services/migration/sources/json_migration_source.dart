import 'dart:convert';
import 'dart:io';
import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/settings/app_setting.dart';
import 'package:flutter_invoice_app/services/migration/sources/migration_source.dart';
import 'package:path/path.dart' as path;

class JsonMigrationSource implements MigrationSource {
  final Map<String, dynamic> _config;
  late String _basePath;
  
  JsonMigrationSource(this._config);
  
  @override
  Future<void> initialize() async {
    // Get base path for JSON files
    _basePath = _config['path'] ?? '';
    
    // Ensure directory exists
    final directory = Directory(_basePath);
    if (!await directory.exists()) {
      throw Exception('Directory does not exist: $_basePath');
    }
  }
  
  @override
  Future<List<Invoice>> getInvoices() async {
    final file = File(path.join(_basePath, 'invoices.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<Invoice>((json) => Invoice.fromMap(json)).toList();
  }
  
  @override
  Future<List<Customer>> getCustomers() async {
    final file = File(path.join(_basePath, 'customers.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<Customer>((json) => Customer.fromMap(json)).toList();
  }
  
  @override
  Future<List<GSTR1>> getGSTR1Returns() async {
    final file = File(path.join(_basePath, 'gstr1.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<GSTR1>((json) => GSTR1.fromJson(json)).toList();
  }
  
  @override
  Future<List<GSTR3B>> getGSTR3BReturns() async {
    final file = File(path.join(_basePath, 'gstr3b.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<GSTR3B>((json) => GSTR3B.fromJson(json)).toList();
  }
  
  @override
  Future<List<GSTR9>> getGSTR9Returns() async {
    final file = File(path.join(_basePath, 'gstr9.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<GSTR9>((json) => GSTR9.fromJson(json)).toList();
  }
  
  @override
  Future<List<GSTR9C>> getGSTR9CReturns() async {
    final file = File(path.join(_basePath, 'gstr9c.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<GSTR9C>((json) => GSTR9C.fromJson(json)).toList();
  }
  
  @override
  Future<List<AppSetting>> getSettings() async {
    final file = File(path.join(_basePath, 'settings.json'));
    if (!await file.exists()) {
      return [];
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList.map<AppSetting>((json) => AppSetting(
      key: json['key'],
      value: json['value'],
      lastModified: DateTime.parse(json['lastModified']),
    )).toList();
  }
  
  @override
  String getSourceName() {
    return 'JSON Files';
  }
  
  @override
  Map<String, dynamic> getSourceInfo() {
    return {
      'type': 'json',
      'path': _basePath,
      'files': [
        'invoices.json',
        'customers.json',
        'gstr1.json',
        'gstr3b.json',
        'gstr9.json',
        'gstr9c.json',
        'settings.json',
      ],
    };
  }
  
  @override
  Future<void> dispose() async {
    // No resources to dispose
  }
}
