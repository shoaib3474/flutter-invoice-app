// ignore_for_file: always_declare_return_types

import 'dart:convert';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gstr1_model.dart';
import '../utils/error_handler.dart';

class GSTR1Service {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<GSTR1Model?> getLatestGSTR1Data() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr1_data',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return GSTR1Model.fromJson(maps.first);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get latest GSTR-1 data: ${e.toString()}');
    }
  }

  Future<List<GSTR1Model>> getAllGSTR1Data() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr1_data',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return GSTR1Model.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all GSTR-1 data: ${e.toString()}');
    }
  }

  Future<void> saveGSTR1Data(GSTR1Model data) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'gstr1_data',
        data.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save GSTR-1 data: ${e.toString()}');
    }
  }

  Future<void> updateGSTR1Data(GSTR1Model data) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'gstr1_data',
        data.toJson(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to update GSTR-1 data: ${e.toString()}');
    }
  }

  Future<void> deleteGSTR1Data(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'gstr1_data',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to delete GSTR-1 data: ${e.toString()}');
    }
  }

  Future<String> exportToJson(GSTR1Model data) async {
    try {
      final jsonData = jsonEncode(data.toJson());
      return jsonData;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to export GSTR-1 data to JSON: ${e.toString()}');
    }
  }

  Future<GSTR1Model> importFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final gstr1Data = GSTR1Model.fromJson(data);
      await saveGSTR1Data(gstr1Data);
      return gstr1Data;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception(
          'Failed to import GSTR-1 data from JSON: ${e.toString()}');
    }
  }

  Future<void> validateGSTR1Data(GSTR1Model data) async {
    // Implement validation logic for GSTR-1 data
    // Throw exceptions for validation errors
  }

  Future getGSTR1(
      {required String gstin, required String returnPeriod}) async {}

  Future parseGSTR1Json(String jsonString) async {}

  Future<void> validateGSTR1(GSTR1Model gstr1model) async {}

  getAllGSTR1Returns() {}
}
