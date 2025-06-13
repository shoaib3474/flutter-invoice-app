// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/foundation.dart';
import '../models/hsn_sac/hsn_sac_model.dart';
import '../services/hsn_sac/hsn_sac_service.dart';

class HsnSacProvider with ChangeNotifier {
  HsnSacProvider(this._hsnSacService);
  final HsnSacService _hsnSacService;
  bool _isLoading = false;
  String _errorMessage = '';
  List<HsnSacCode> _searchResults = [];
  HsnSacCode? _selectedCode;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<HsnSacCode> get searchResults => _searchResults;
  HsnSacCode? get selectedCode => _selectedCode;

  Future<List<HsnSacCode>> searchCodes(
      String query, String description, bool isSacMode,
      {String? type}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _hsnSacService.searchCodes(query, type: type);
      _searchResults = results;
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to search codes: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<HsnSacCode?> getCodeDetails(String code, {String? type}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _hsnSacService.getCodeDetails(code, type: type);
      _selectedCode = result;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to get code details: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
