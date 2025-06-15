// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/models/gstr3b_model.dart';
import 'package:uuid/uuid.dart';

import '../models/gst_returns/gstr1_model.dart';
import '../models/gst_returns/gstr4_model.dart';
import '../repositories/firebase_gst_repository.dart';
import '../services/logger_service.dart';

class FirebaseGstProvider with ChangeNotifier {
  final FirebaseGstRepository _repository = FirebaseGstRepository();
  final LoggerService _logger = LoggerService();
  final Uuid _uuid = Uuid();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // GSTR1 Operations

  Future<String?> saveGSTR1(GSTR1Model gstr1) async {
    _setLoading(true);
    try {
      final id = _uuid.v4();
      await _repository.saveGSTR1(gstr1, id);
      _setLoading(false);
      return id;
    } catch (e) {
      _setError('Failed to save GSTR1: ${e.toString()}');
      return null;
    }
  }

  Future<GSTR1Model?> getGSTR1(String id) async {
    _setLoading(true);
    try {
      final gstr1 = await _repository.getGSTR1(id);
      _setLoading(false);
      return gstr1;
    } catch (e) {
      _setError('Failed to get GSTR1: ${e.toString()}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR1List(String gstin,
      {String? returnPeriod}) async {
    _setLoading(true);
    try {
      final list = await _repository.getGSTR1List(gstin, returnPeriod);
      _setLoading(false);
      return list;
    } catch (e) {
      _setError('Failed to get GSTR1 list: ${e.toString()}');
      return [];
    }
  }

  Future<bool> deleteGSTR1(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteGSTR1(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete GSTR1: ${e.toString()}');
      return false;
    }
  }

  // GSTR3B Operations

  Future<String?> saveGSTR3B(GSTR3BModel gstr3b) async {
    _setLoading(true);
    try {
      final id = _uuid.v4();
      await _repository.saveGSTR3B(gstr3b, id);
      _setLoading(false);
      return id;
    } catch (e) {
      _setError('Failed to save GSTR3B: ${e.toString()}');
      return null;
    }
  }

  Future<GSTR3BModel?> getGSTR3B(String id) async {
    _setLoading(true);
    try {
      final gstr3b = await _repository.getGSTR3B(id);
      _setLoading(false);
      return gstr3b;
    } catch (e) {
      _setError('Failed to get GSTR3B: ${e.toString()}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR3BList(String gstin,
      {String? returnPeriod}) async {
    _setLoading(true);
    try {
      final list = await _repository.getGSTR3BList(gstin, returnPeriod);
      _setLoading(false);
      return list;
    } catch (e) {
      _setError('Failed to get GSTR3B list: ${e.toString()}');
      return [];
    }
  }

  Future<bool> deleteGSTR3B(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteGSTR3B(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete GSTR3B: ${e.toString()}');
      return false;
    }
  }

  // GSTR4 Operations

  Future<String?> saveGSTR4(GSTR4Model gstr4) async {
    _setLoading(true);
    try {
      final id = _uuid.v4();
      await _repository.saveGSTR4(gstr4, id);
      _setLoading(false);
      return id;
    } catch (e) {
      _setError('Failed to save GSTR4: ${e.toString()}');
      return null;
    }
  }

  Future<GSTR4Model?> getGSTR4(String id) async {
    _setLoading(true);
    try {
      final gstr4 = await _repository.getGSTR4(id);
      _setLoading(false);
      return gstr4;
    } catch (e) {
      _setError('Failed to get GSTR4: ${e.toString()}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getGSTR4List(String gstin,
      {String? returnPeriod}) async {
    _setLoading(true);
    try {
      final list = await _repository.getGSTR4List(gstin, returnPeriod);
      _setLoading(false);
      return list;
    } catch (e) {
      _setError('Failed to get GSTR4 list: ${e.toString()}');
      return [];
    }
  }

  Future<bool> deleteGSTR4(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteGSTR4(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete GSTR4: ${e.toString()}');
      return false;
    }
  }

  // Helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _error = error;
    _logger.error(error);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
