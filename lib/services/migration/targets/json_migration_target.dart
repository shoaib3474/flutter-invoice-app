import 'dart:convert';
import 'dart:io';
import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/services/migration/targets/migration_target.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class JsonMigrationTarget implements MigrationTarget {
  final Map<String, dynamic> _config;
  late String _basePath;
  final Uuid _uuid = Uuid();
  
  // In-memory storage for validation
  final List<Invoice> _invoices = [];
  final List<Customer> _customers = [];
  final List<GSTR1> _gstr1Returns = [];
  final List<GSTR3B> _gstr3bReturns = [];
  final List<GSTR9> _gstr9Returns = [];
  final List<GSTR9C> _gstr9cReturns = [];
  final Map<String, String> _settings = {};
  
  JsonMigrationTarget(this._config);
  
  @override
  Future<void> initialize() async {
    // Get base path for JSON files
    _basePath = _config['path'] ?? '';
    
    // Ensure directory exists
    final directory = Directory(_basePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
  
  @override
  Future<void> saveInvoice(Invoice invoice) async {
    // Ensure invoice has an ID
    if (invoice.id.isEmpty) {
      invoice = invoice.copyWith(id: _uuid.v4());
    }
    
    // Add to in-memory storage
    _invoices.add(invoice);
    
    // Save to file
    await _saveToFile('invoices.json', _invoices.map((i) => i.toMap()).toList());
  }
  
  @override
  Future<void> saveCustomer(Customer customer) async {
    // Ensure customer has an ID
    if (customer.id.isEmpty) {
      customer = customer.copyWith(id: _uuid.v4());
    }
    
    // Add to in-memory storage
    _customers.add(customer);
    
    // Save to file
    await _saveToFile('customers.json', _customers.map((c) => c.toMap()).toList());
  }
  
  @override
  Future<void> saveGSTR1(GSTR1 gstr1) async {
    // Add to in-memory storage
    _gstr1Returns.add(gstr1);
    
    // Save to file
    await _saveToFile('gstr1.json', _gstr1Returns.map((g) => g.toJson()).toList());
  }
  
  @override
  Future<void> saveGSTR3B(GSTR3B gstr3b) async {
    // Add to in-memory storage
    _gstr3bReturns.add(gstr3b);
    
    // Save to file
    await _saveToFile('gstr3b.json', _gstr3bReturns.map((g) => g.toJson()).toList());
  }
  
  @override
  Future<void> saveGSTR9(GSTR9 gstr9) async {
    // Add to in-memory storage
    _gstr9Returns.add(gstr9);
    
    // Save to file
    await _saveToFile('gstr9.json', _gstr9Returns.map((g) => g.toJson()).toList());
  }
  
  @override
  Future<void> saveGSTR9C(GSTR9C gstr9c) async {
    // Add to in-memory storage
    _gstr9cReturns.add(gstr9c);
    
    // Save to file
    await _saveToFile('gstr9c.json', _gstr9cReturns.map((g) => g.toJson()).toList());
  }
  
  @override
  Future<void> saveSetting(String key, String value) async {
    // Add to in-memory storage
    _settings[key] = value;
    
    // Save to file
    final settingsList = _settings.entries.map((e) => {
      'key': e.key,
      'value': e.value,
      'lastModified': DateTime.now().toIso8601String(),
    }).toList();
    
    await _saveToFile('settings.json', settingsList);
  }
  
  // Helper method to save data to file
  Future<void> _saveToFile(String fileName, List<dynamic> data) async {
    final file = File(path.join(_basePath, fileName));
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString, flush: true);
  }
  
  @override
  Future<List<Invoice>> getInvoices() async {
    return _invoices;
  }
  
  @override
  Future<List<Customer>> getCustomers() async {
    return _customers;
  }
  
  @override
  Future<List<GSTR1>> getGSTR1Returns() async {
    return _gstr1Returns;
  }
  
  @override
  Future<List<GSTR3B>> getGSTR3BReturns() async {
    return _gstr3bReturns;
  }
  
  @override
  Future<List<GSTR9>> getGSTR9Returns() async {
    return _gstr9Returns;
  }
  
  @override
  Future<List<GSTR9C>> getGSTR9CReturns() async {
    return _gstr9cReturns;
  }
  
  @override
  Future<List<Map<String, String>>> getSettings() async {
    return _settings.entries.map((e) => {
      'key': e.key,
      'value': e.value,
    }).toList();
  }
  
  @override
  Future<void> cleanDatabase() async {
    // Clear in-memory storage
    _invoices.clear();
    _customers.clear();
    _gstr1Returns.clear();
    _gstr3bReturns.clear();
    _gstr9Returns.clear();
    _gstr9cReturns.clear();
    _settings.clear();
    
    // Delete all files
    final directory = Directory(_basePath);
    if (await directory.exists()) {
      final files = [
        'invoices.json',
        'customers.json',
        'gstr1.json',
        'gstr3b.json',
        'gstr9.json',
        'gstr9c.json',
        'settings.json',
      ];
      
      for (final fileName in files) {
        final file = File(path.join(_basePath, fileName));
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }
  
  @override
  String getTargetName() {
    return 'JSON Files';
  }
  
  @override
  Map<String, dynamic> getTargetInfo() {
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
