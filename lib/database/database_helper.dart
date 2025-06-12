import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'gst_invoice.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices(
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL,
        invoice_date TEXT NOT NULL,
        customer_name TEXT,
        customer_gstin TEXT,
        subtotal REAL,
        igst_total REAL,
        cgst_total REAL,
        sgst_total REAL,
        cess_total REAL,
        grand_total REAL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gstr1_data(
        id TEXT PRIMARY KEY,
        gstin TEXT NOT NULL,
        period TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gstr3b_data(
        id TEXT PRIMARY KEY,
        gstin TEXT NOT NULL,
        period TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gstr4_data(
        id TEXT PRIMARY KEY,
        gstin TEXT NOT NULL,
        period TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gst_comparison(
        id TEXT PRIMARY KEY,
        gstin TEXT NOT NULL,
        period TEXT NOT NULL,
        type TEXT NOT NULL,
        reconciliation_date TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    // Mock implementation
  }

  Future<List<Map<String, dynamic>>> queryData(String table) async {
    // Mock implementation
    return [];
  }

  Future<void> updateData(String table, Map<String, dynamic> data, String where) async {
    // Mock implementation
  }

  Future<void> deleteData(String table, String where) async {
    // Mock implementation
  }
}
