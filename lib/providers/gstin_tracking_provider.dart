import 'package:flutter/foundation.dart';
import '../models/gstin/gstin_filing_history.dart';
import '../models/gstin/jurisdiction_model.dart';
import '../services/gstin/gstin_tracking_service.dart';
import '../utils/api_exception.dart';

class GstinTrackingProvider with ChangeNotifier {
  final GstinTrackingService _trackingService;
  bool _isLoading = false;
  String _errorMessage = '';
  GstinFilingHistory? _filingHistory;
  List<GstinFilingHistory>? _panSearchResults;
  GstJurisdiction? _jurisdiction;

  GstinTrackingProvider(this._trackingService);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  GstinFilingHistory? get filingHistory => _filingHistory;
  List<GstinFilingHistory>? get panSearchResults => _panSearchResults;
  GstJurisdiction? get jurisdiction => _jurisdiction;

  Future<GstinFilingHistory> getFilingHistory(String gstin) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final history = await _trackingService.getFilingHistory(gstin);
      _filingHistory = history;
      _isLoading = false;
      notifyListeners();
      return history;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<List<GstinFilingHistory>> searchByPan(String pan) async {
    _isLoading = true;
    _errorMessage = '';
    _panSearchResults = null;
    notifyListeners();

    try {
      final results = await _trackingService.searchByPan(pan);
      _panSearchResults = results;
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<GstJurisdiction> getJurisdiction(String gstinOrPan) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final jurisdiction = await _trackingService.getJurisdiction(gstinOrPan);
      _jurisdiction = jurisdiction;
      _isLoading = false;
      notifyListeners();
      return jurisdiction;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
