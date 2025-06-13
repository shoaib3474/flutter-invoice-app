import 'dart:convert';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gstr3b_model.dart';
import '../utils/error_handler.dart';

class GSTR3BService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<GSTR3BModel?> getLatestGSTR3BData() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr3b_data',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return GSTR3BModel.fromJson(maps.first);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get latest GSTR-3B data: ${e.toString()}');
    }
  }

  Future<List<GSTR3BModel>> getAllGSTR3BData() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr3b_data',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return GSTR3BModel.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all GSTR-3B data: ${e.toString()}');
    }
  }

  Future<void> saveGSTR3BData(GSTR3BModel data) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'gstr3b_data',
        data.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save GSTR-3B data: ${e.toString()}');
    }
  }

  Future<void> updateGSTR3BData(GSTR3BModel data) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'gstr3b_data',
        data.toJson(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to update GSTR-3B data: ${e.toString()}');
    }
  }

  Future<void> deleteGSTR3BData(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'gstr3b_data',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to delete GSTR-3B data: ${e.toString()}');
    }
  }

  Future<String> exportToJson(GSTR3BModel data) async {
    try {
      final jsonData = jsonEncode(data.toJson());
      return jsonData;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to export GSTR-3B data to JSON: ${e.toString()}');
    }
  }

  Future<GSTR3BModel> importFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final gstr3bData = GSTR3BModel.fromJson(data);
      await saveGSTR3BData(gstr3bData);
      return gstr3bData;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception(
          'Failed to import GSTR-3B data from JSON: ${e.toString()}');
    }
  }

  Future<void> validateGSTR3BData(GSTR3BModel data) async {
    // Implement validation logic for GSTR-3B data
    // Throw exceptions for validation errors
  }

  Future<void> validateGSTR3B(GSTR3BModel formData) async {}

  getFinancialYears() {}

  getTaxPeriods() {}
}
