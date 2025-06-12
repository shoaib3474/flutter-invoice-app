import 'dart:convert';
import '../models/gstr4_model.dart';
import '../services/database/database_helper.dart';
import '../utils/error_handler.dart';

class GSTR4Service {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  Future<GSTR4Model?> getLatestGSTR4Data() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr4_data',
        orderBy: 'created_at DESC',
        limit: 1,
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      return GSTR4Model.fromJson(maps.first);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get latest GSTR-4 data: ${e.toString()}');
    }
  }
  
  Future<List<GSTR4Model>> getAllGSTR4Data() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gstr4_data',
        orderBy: 'created_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        return GSTR4Model.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all GSTR-4 data: ${e.toString()}');
    }
  }
  
  Future<void> saveGSTR4Data(GSTR4Model data) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'gstr4_data',
        data.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save GSTR-4 data: ${e.toString()}');
    }
  }
  
  Future<void> updateGSTR4Data(GSTR4Model data) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'gstr4_data',
        data.toJson(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to update GSTR-4 data: ${e.toString()}');
    }
  }
  
  Future<void> deleteGSTR4Data(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'gstr4_data',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to delete GSTR-4 data: ${e.toString()}');
    }
  }
  
  Future<String> exportToJson(GSTR4Model data) async {
    try {
      final jsonData = jsonEncode(data.toJson());
      return jsonData;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to export GSTR-4 data to JSON: ${e.toString()}');
    }
  }
  
  Future<GSTR4Model> importFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final gstr4Data = GSTR4Model.fromJson(data);
      await saveGSTR4Data(gstr4Data);
      return gstr4Data;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to import GSTR-4 data from JSON: ${e.toString()}');
    }
  }
  
  Future<void> validateGSTR4Data(GSTR4Model data) async {
    // Implement validation logic for GSTR-4 data
    // Throw exceptions for validation errors
  }
}
