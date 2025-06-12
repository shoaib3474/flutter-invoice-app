import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment/gst_challan_model.dart';
import '../../utils/error_handler.dart';
import '../database/database_helper.dart';

class GSTChallanService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();
  
  // Generate a new challan
  Future<GSTChallanModel> generateChallan({
    required String gstin,
    required double cgstAmount,
    required double sgstAmount,
    required double igstAmount,
    required double cessAmount,
    required String bankName,
    required String bankBranch,
    String paymentMode = 'Online',
  }) async {
    try {
      final challanId = 'CH' + DateTime.now().millisecondsSinceEpoch.toString();
      final cpin = 'CP' + DateTime.now().millisecondsSinceEpoch.toString();
      
      final challan = GSTChallanModel(
        challanId: challanId,
        gstin: gstin,
        cpin: cpin,
        challanDate: DateTime.now(),
        paymentMode: paymentMode,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        cessAmount: cessAmount,
        totalAmount: cgstAmount + sgstAmount + igstAmount + cessAmount,
        bankName: bankName,
        bankBranch: bankBranch,
        paymentStatus: 'Pending',
      );
      
      await saveChallan(challan);
      
      return challan;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to generate challan: ${e.toString()}');
    }
  }
  
  // Save challan to database
  Future<void> saveChallan(GSTChallanModel challan) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'gst_challans',
        challan.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save challan: ${e.toString()}');
    }
  }
  
  // Update challan status
  Future<void> updateChallanStatus(
    String challanId, 
    String status, {
    DateTime? paymentDate,
    String? transactionId,
    String? bankReferenceNumber,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      final challan = await getChallanById(challanId);
      if (challan == null) {
        throw Exception('Challan not found');
      }
      
      final updatedChallan = GSTChallanModel(
        challanId: challan.challanId,
        gstin: challan.gstin,
        cpin: challan.cpin,
        challanDate: challan.challanDate,
        paymentMode: challan.paymentMode,
        cgstAmount: challan.cgstAmount,
        sgstAmount: challan.sgstAmount,
        igstAmount: challan.igstAmount,
        cessAmount: challan.cessAmount,
        totalAmount: challan.totalAmount,
        bankName: challan.bankName,
        bankBranch: challan.bankBranch,
        paymentStatus: status,
        paymentDate: paymentDate ?? challan.paymentDate,
        transactionId: transactionId ?? challan.transactionId,
        bankReferenceNumber: bankReferenceNumber ?? challan.bankReferenceNumber,
      );
      
      await db.update(
        'gst_challans',
        updatedChallan.toJson(),
        where: 'challan_id = ?',
        whereArgs: [challanId],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to update challan status: ${e.toString()}');
    }
  }
  
  // Get challan by ID
  Future<GSTChallanModel?> getChallanById(String challanId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gst_challans',
        where: 'challan_id = ?',
        whereArgs: [challanId],
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      return GSTChallanModel.fromJson(maps.first);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get challan: ${e.toString()}');
    }
  }
  
  // Get all challans
  Future<List<GSTChallanModel>> getAllChallans() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gst_challans',
        orderBy: 'challan_date DESC',
      );
      
      return List.generate(maps.length, (i) {
        return GSTChallanModel.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all challans: ${e.toString()}');
    }
  }
  
  // Get challans by GSTIN
  Future<List<GSTChallanModel>> getChallansByGstin(String gstin) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'gst_challans',
        where: 'gstin = ?',
        whereArgs: [gstin],
        orderBy: 'challan_date DESC',
      );
      
      return List.generate(maps.length, (i) {
        return GSTChallanModel.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get challans by GSTIN: ${e.toString()}');
    }
  }
  
  // Export challan to JSON
  Future<String> exportChallanToJson(GSTChallanModel challan) async {
    try {
      return jsonEncode(challan.toJson());
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to export challan to JSON: ${e.toString()}');
    }
  }
}
