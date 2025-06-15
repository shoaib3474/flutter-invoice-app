import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice_app/models/gstr3b_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gst_returns/gstr1_model.dart';
import '../models/gst_returns/gstr3b_model.dart';
import '../models/gst_returns/gstr4_model.dart';
import '../services/firebase/firebase_service.dart';
import '../services/logger_service.dart';

class FirebaseGstRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final LoggerService _logger = LoggerService();

  // GSTR1 Operations

  Future<void> saveGSTR1(GSTR1Model gstr1, String id) async {
    try {
      await _firebaseService.setDocument(
        'gstr1',
        id,
        {
          'gstin': gstr1.gstin,
          'return_period': gstr1.fp,
          // 'data': gstr1.toJson(),
          'status': 'draft',
          'created_at': FieldValue.serverTimestamp(),
        },
      );
      _logger.info('GSTR1 saved with ID: $id');
    } catch (e) {
      _logger.error('Error saving GSTR1: $e');
      rethrow;
    }
  }

  Future<GSTR1Model?> getGSTR1(String id) async {
    try {
      Map<String, dynamic>? data = (await _firebaseService.getDocument(
          'gstr1', id)) as Map<String, dynamic>?;
      if (data != null && data.containsKey('data')) {
        return GSTR1Model.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      _logger.error('Error getting GSTR1: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR1List(
      String gstin, String? returnPeriod) async {
    try {
      List<List<dynamic>> whereConditions = [
        ['gstin', '==', gstin],
      ];

      if (returnPeriod != null) {
        whereConditions.add(['return_period', '==', returnPeriod]);
      }

      return await _firebaseService.queryDocuments(
        'gstr1',
        whereConditions: whereConditions,
        orderBy: 'created_at',
        descending: true,
      );
    } catch (e) {
      _logger.error('Error getting GSTR1 list: $e');
      rethrow;
    }
  }

  Future<void> deleteGSTR1(String id) async {
    try {
      await _firebaseService.deleteDocument('gstr1', id);
      _logger.info('GSTR1 deleted with ID: $id');
    } catch (e) {
      _logger.error('Error deleting GSTR1: $e');
      rethrow;
    }
  }

  // GSTR3B Operations

  Future<void> saveGSTR3B(GSTR3BModel gstr3b, String id) async {
    try {
      await _firebaseService.setDocument(
        'gstr3b',
        id,
        {
          'gstin': gstr3b.gstin,
          'return_period': gstr3b.ret_period,
          'data': gstr3b.toJson(),
          'status': 'draft',
          'created_at': FieldValue.serverTimestamp(),
        },
      );
      _logger.info('GSTR3B saved with ID: $id');
    } catch (e) {
      _logger.error('Error saving GSTR3B: $e');
      rethrow;
    }
  }

  Future<GSTR3BModel?> getGSTR3B(String id) async {
    try {
      Map<String, dynamic>? data = (await _firebaseService.getDocument(
          'gstr3b', id)) as Map<String, dynamic>?;
      if (data != null && data.containsKey('data')) {
        return GSTR3BModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      _logger.error('Error getting GSTR3B: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR3BList(
      String gstin, String? returnPeriod) async {
    try {
      List<List<dynamic>> whereConditions = [
        ['gstin', '==', gstin],
      ];

      if (returnPeriod != null) {
        whereConditions.add(['return_period', '==', returnPeriod]);
      }

      return await _firebaseService.queryDocuments(
        'gstr3b',
        whereConditions: whereConditions,
        orderBy: 'created_at',
        descending: true,
      );
    } catch (e) {
      _logger.error('Error getting GSTR3B list: $e');
      rethrow;
    }
  }

  Future<void> deleteGSTR3B(String id) async {
    try {
      await _firebaseService.deleteDocument('gstr3b', id);
      _logger.info('GSTR3B deleted with ID: $id');
    } catch (e) {
      _logger.error('Error deleting GSTR3B: $e');
      rethrow;
    }
  }

  // GSTR4 Operations

  Future<void> saveGSTR4(GSTR4Model gstr4, String id) async {
    try {
      await _firebaseService.setDocument(
        'gstr4',
        id,
        {
          'gstin': gstr4.gstin,
          'return_period': gstr4.ret_period,
          'data': gstr4.toJson(),
          'status': 'draft',
          'created_at': FieldValue.serverTimestamp(),
        },
      );
      _logger.info('GSTR4 saved with ID: $id');
    } catch (e) {
      _logger.error('Error saving GSTR4: $e');
      rethrow;
    }
  }

  Future<GSTR4Model?> getGSTR4(String id) async {
    try {
      Map<String, dynamic>? data = (await _firebaseService.getDocument(
          'gstr4', id)) as Map<String, dynamic>?;
      if (data != null && data.containsKey('data')) {
        return GSTR4Model.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      _logger.error('Error getting GSTR4: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR4List(
      String gstin, String? returnPeriod) async {
    try {
      List<List<dynamic>> whereConditions = [
        ['gstin', '==', gstin],
      ];

      if (returnPeriod != null) {
        whereConditions.add(['return_period', '==', returnPeriod]);
      }

      return await _firebaseService.queryDocuments(
        'gstr4',
        whereConditions: whereConditions,
        orderBy: 'created_at',
        descending: true,
      );
    } catch (e) {
      _logger.error('Error getting GSTR4 list: $e');
      rethrow;
    }
  }

  Future<void> deleteGSTR4(String id) async {
    try {
      await _firebaseService.deleteDocument('gstr4', id);
      _logger.info('GSTR4 deleted with ID: $id');
    } catch (e) {
      _logger.error('Error deleting GSTR4: $e');
      rethrow;
    }
  }
}
