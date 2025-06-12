import 'dart:convert';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/customer/customer_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr9c_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';
import 'package:flutter_invoice_app/services/migration/targets/migration_target.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class SQLiteMigrationTarget implements MigrationTarget {
  final Map<String, dynamic> _config;
  late DatabaseHelper _dbHelper;
  Database? _db;
  final Uuid _uuid = Uuid();
  
  SQLiteMigrationTarget(this._config);
  
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
  Future<void> saveInvoice(Invoice invoice) async {
    // Ensure invoice has an ID
    if (invoice.id.isEmpty) {
      invoice = invoice.copyWith(id: _uuid.v4());
    }
    
    // Prepare invoice data
    final invoiceMap = invoice.toMap();
    invoiceMap['sync_status'] = SyncStatus.synced.toString();
    invoiceMap['last_modified'] = DateTime.now().millisecondsSinceEpoch;
    invoiceMap['is_deleted'] = 0;
    
    // Save invoice
    await _db!.insert(
      'invoices',
      invoiceMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Save invoice items
    for (final item in invoice.items) {
      final itemMap = item.toMap();
      itemMap['invoice_id'] = invoice.id;
      
      await _db!.insert(
        'invoice_items',
        itemMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
  
  @override
  Future<void> saveCustomer(Customer customer) async {
    // Ensure customer has an ID
    if (customer.id.isEmpty) {
      customer = customer.copyWith(id: _uuid.v4());
    }
    
    // Prepare customer data
    final customerMap = customer.toMap();
    customerMap['sync_status'] = SyncStatus.synced.toString();
    customerMap['last_modified'] = DateTime.now().millisecondsSinceEpoch;
    customerMap['is_deleted'] = 0;
    
    // Save customer
    await _db!.insert(
      'customers',
      customerMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> saveGSTR1(GSTR1 gstr1) async {
    final id = _uuid.v4();
    
    // Prepare GSTR1 data
    final gstr1Map = {
      'id': id,
      'gstin': gstr1.gstin,
      'return_period': gstr1.returnPeriod,
      'data': jsonEncode(gstr1.toJson()),
      'status': gstr1.status,
      'filing_date': gstr1.filingDate?.millisecondsSinceEpoch,
      'sync_status': SyncStatus.synced.toString(),
      'last_modified': DateTime.now().millisecondsSinceEpoch,
      'is_deleted': 0,
    };
    
    // Save GSTR1
    await _db!.insert(
      'gstr1',
      gstr1Map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> saveGSTR3B(GSTR3B gstr3b) async {
    final id = _uuid.v4();
    
    // Prepare GSTR3B data
    final gstr3bMap = {
      'id': id,
      'gstin': gstr3b.gstin,
      'return_period': gstr3b.returnPeriod,
      'data': jsonEncode(gstr3b.toJson()),
      'status': gstr3b.status,
      'filing_date': gstr3b.filingDate?.millisecondsSinceEpoch,
      'sync_status': SyncStatus.synced.toString(),
      'last_modified': DateTime.now().millisecondsSinceEpoch,
      'is_deleted': 0,
    };
    
    // Save GSTR3B
    await _db!.insert(
      'gstr3b',
      gstr3bMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> saveGSTR9(GSTR9 gstr9) async {
    final id = _uuid.v4();
    
    // Prepare GSTR9 data
    final gstr9Map = {
      'id': id,
      'gstin': gstr9.gstin,
      'financial_year': gstr9.financialYear,
      'data': jsonEncode(gstr9.toJson()),
      'status': 'draft',
      'sync_status': SyncStatus.synced.toString(),
      'last_modified': DateTime.now().millisecondsSinceEpoch,
      'is_deleted': 0,
    };
    
    // Save GSTR9
    await _db!.insert(
      'gstr9',
      gstr9Map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> saveGSTR9C(GSTR9C gstr9c) async {
    final id = _uuid.v4();
    
    // Prepare GSTR9C data
    final gstr9cMap = {
      'id': id,
      'gstin': gstr9c.gstin,
      'financial_year': gstr9c.financialYear,
      'data': jsonEncode(gstr9c.toJson()),
      'status': 'draft',
      'sync_status': SyncStatus.synced.toString(),
      'last_modified': DateTime.now().millisecondsSinceEpoch,
      'is_deleted': 0,
    };
    
    // Save GSTR9C
    await _db!.insert(
      'gstr9c',
      gstr9cMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> saveSetting(String key, String value) async {
    // Prepare setting data
    final settingMap = {
      'key': key,
      'value': value,
      'last_modified': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Save setting
    await _db!.insert(
      'settings',
      settingMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
  Future<List<Map<String, String>>> getSettings() async {
    final List<Map<String, dynamic>> settingMaps = await _db!.query('settings');
    return settingMaps.map((map) => {
      'key': map['key'],
      'value': map['value'],
    }).toList();
  }
  
  @override
  Future<void> cleanDatabase() async {
    // Delete all data from tables
    await _db!.delete('invoices');
    await _db!.delete('invoice_items');
    await _db!.delete('customers');
    await _db!.delete('gstr1');
    await _db!.delete('gstr3b');
    await _db!.delete('gstr9');
    await _db!.delete('gstr9c');
    // Don't delete settings as they may contain important app configuration
  }
  
  @override
  String getTargetName() {
    return 'SQLite Database';
  }
  
  @override
  Map<String, dynamic> getTargetInfo() {
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
