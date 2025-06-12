import 'dart:convert';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/settings/app_setting.dart';
import 'package:flutter_invoice_app/services/migration/sources/migration_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteMigrationSource implements MigrationSource {
  final Map<String, dynamic> _config;
  late DatabaseHelper _dbHelper;
  Database? _db;
  
  SQLiteMigrationSource(this._config);
  
  @override
  Future<void> initialize() async {
    // Use custom database path if provided
    if (_config.containsKey('path')) {
      final dbPath = _config['path'];
      _db = await openDatabase(dbPath);
    } else {
      // Use default database
      _dbHelper = DatabaseHelper();
      _db = await _dbHelper.database;
    }
  }
  
  @override
  Future<List<Invoice>> getInvoices() async {
    final List<Map<String, dynamic>> invoiceMaps = await _db!.query('invoices', where: 'is_deleted = 0');
    final List<Invoice> invoices = [];
    
    for (final invoiceMap in invoiceMaps) {
      try {
        // Get invoice items
        final List<Map<String, dynamic>> itemMaps = await _db!.query(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoiceMap['id']],
        );
        
        // Create invoice with items
        final invoice = Invoice.fromMap(invoiceMap);
        invoice.items = itemMaps.map((item) => InvoiceItem.fromMap(item)).toList();
        
        invoices.add(invoice);
      } catch (e) {
        print('Error loading invoice ${invoiceMap['id']}: $e');
      }
    }
    
    return invoices;
  }
  
  @override
  Future<List<Customer>> getCustomers() async {
    final List<Map<String, dynamic>> customerMaps = await _db!.query('customers', where: 'is_deleted = 0');
    return customerMaps.map((map) => Customer.fromMap(map)).toList();
  }
  
  @override
  Future<List<GSTR1>> getGSTR1Returns() async {
    final List<Map<String, dynamic>> gstr1Maps = await _db!.query('gstr1', where: 'is_deleted = 0');
    final List<GSTR1> returns = [];
    
    for (final map in gstr1Maps) {
      try {
        final data = jsonDecode(map['data']);
        returns.add(GSTR1.fromJson(data));
      } catch (e) {
        print('Error loading GSTR1 ${map['id']}: $e');
      }
    }
    
    return returns;
  }
  
  @override
  Future<List<GSTR3B>> getGSTR3BReturns() async {
    final List<Map<String, dynamic>> gstr3bMaps = await _db!.query('gstr3b', where: 'is_deleted = 0');
    final List<GSTR3B> returns = [];
    
    for (final map in gstr3bMaps) {
      try {
        final data = jsonDecode(map['data']);
        returns.add(GSTR3B.fromJson(data));
      } catch (e) {
        print('Error loading GSTR3B ${map['id']}: $e');
      }
    }
    
    return returns;
  }
  
  @override
  Future<List<GSTR9>> getGSTR9Returns() async {
    final List<Map<String, dynamic>> gstr9Maps = await _db!.query('gstr9', where: 'is_deleted = 0');
    final List<GSTR9> returns = [];
    
    for (final map in gstr9Maps) {
      try {
        final data = jsonDecode(map['data']);
        returns.add(GSTR9.fromJson(data));
      } catch (e) {
        print('Error loading GSTR9 ${map['id']}: $e');
      }
    }
    
    return returns;
  }
  
  @override
  Future<List<GSTR9C>> getGSTR9CReturns() async {
    final List<Map<String, dynamic>> gstr9cMaps = await _db!.query('gstr9c', where: 'is_deleted = 0');
    final List<GSTR9C> returns = [];
    
    for (final map in gstr9cMaps) {
      try {
        final data = jsonDecode(map['data']);
        returns.add(GSTR9C.fromJson(data));
      } catch (e) {
        print('Error loading GSTR9C ${map['id']}: $e');
      }
    }
    
    return returns;
  }
  
  @override
  Future<List<AppSetting>> getSettings() async {
    final List<Map<String, dynamic>> settingMaps = await _db!.query('settings');
    return settingMaps.map((map) => AppSetting(
      key: map['key'],
      value: map['value'],
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['last_modified']),
    )).toList();
  }
  
  @override
  String getSourceName() {
    return 'SQLite Database';
  }
  
  @override
  Map<String, dynamic> getSourceInfo() {
    return {
      'type': 'sqlite',
      'path': _config['path'] ?? 'Default Database',
      'tables': ['invoices', 'invoice_items', 'customers', 'gstr1', 'gstr3b', 'gstr9', 'gstr9c', 'settings'],
    };
  }
  
  @override
  Future<void> dispose() async {
    // Close database if it was opened directly
    if (_config.containsKey('path') && _db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
