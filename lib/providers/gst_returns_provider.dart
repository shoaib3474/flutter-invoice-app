import 'package:flutter/foundation.dart';
import '../models/api/api_response.dart';
import '../services/demo_gst_api_service.dart';
import '../services/gst_api_service.dart';
import '../utils/api_exception.dart';

class GstReturnsProvider with ChangeNotifier {
  final GstApiService? apiService;
  final DemoGstApiService _demoApiService = DemoGstApiService();
  
  bool _useDemo = true; // Set to false to use real API
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _lastResponse = {};
  
  GstReturnsProvider({this.apiService}) {
    // If apiService is provided, use real API
    if (apiService != null) {
      _useDemo = false;
    }
  }
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get lastResponse => _lastResponse;
  bool get useDemo => _useDemo;
  
  // Toggle between demo and real API
  void toggleDemoMode(bool useDemo) {
    _useDemo = useDemo;
    notifyListeners();
  }
  
  // Reset error message
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  // Generic method to fetch return data
  Future<ApiResponse> fetchReturnData({
    required String returnType,
    String? period,
    required String financialYear,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      ApiResponse response;
      
      if (_useDemo) {
        response = await _fetchDemoData(returnType, period, financialYear);
      } else {
        if (apiService == null) {
          throw ApiException(message: 'API Service not initialized');
        }
        response = await _fetchRealData(returnType, period, financialYear);
      }
      
      _lastResponse = response.data;
      return response;
    } catch (e) {
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Generic method to prepare return
  Future<ApiResponse> prepareReturn({
    required String returnType,
    String? period,
    required String financialYear,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      ApiResponse response;
      
      if (_useDemo) {
        response = await _prepareDemoReturn(returnType, period, financialYear);
      } else {
        if (apiService == null) {
          throw ApiException(message: 'API Service not initialized');
        }
        response = await _prepareRealReturn(returnType, period, financialYear);
      }
      
      _lastResponse = response.data;
      return response;
    } catch (e) {
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Generic method to file return
  Future<ApiResponse> fileReturn({
    required String returnType,
    String? period,
    required String financialYear,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      ApiResponse response;
      
      if (_useDemo) {
        response = await _fileDemoReturn(returnType, period, financialYear);
      } else {
        if (apiService == null) {
          throw ApiException(message: 'API Service not initialized');
        }
        response = await _fileRealReturn(returnType, period, financialYear);
      }
      
      _lastResponse = response.data;
      return response;
    } catch (e) {
      _errorMessage = e is ApiException 
          ? e.message 
          : 'An unexpected error occurred: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper methods for demo API
  Future<ApiResponse> _fetchDemoData(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return _demoApiService.fetchGstr1Data(period!, financialYear);
      case 'GSTR3B':
        return _demoApiService.fetchGstr3bData(period!, financialYear);
      case 'GSTR9':
        return _demoApiService.fetchGstr9Data(financialYear);
      case 'GSTR9C':
        return _demoApiService.fetchGstr9cData(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
  
  Future<ApiResponse> _prepareDemoReturn(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return _demoApiService.prepareGstr1(period!, financialYear);
      case 'GSTR3B':
        return _demoApiService.prepareGstr3b(period!, financialYear);
      case 'GSTR9':
        return _demoApiService.prepareGstr9(financialYear);
      case 'GSTR9C':
        return _demoApiService.prepareGstr9c(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
  
  Future<ApiResponse> _fileDemoReturn(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return _demoApiService.fileGstr1(period!, financialYear);
      case 'GSTR3B':
        return _demoApiService.fileGstr3b(period!, financialYear);
      case 'GSTR9':
        return _demoApiService.fileGstr9(financialYear);
      case 'GSTR9C':
        return _demoApiService.fileGstr9c(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
  
  // Helper methods for real API
  Future<ApiResponse> _fetchRealData(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return apiService!.fetchGstr1Data(period!, financialYear);
      case 'GSTR3B':
        return apiService!.fetchGstr3bData(period!, financialYear);
      case 'GSTR9':
        return apiService!.fetchGstr9Data(financialYear);
      case 'GSTR9C':
        return apiService!.fetchGstr9cData(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
  
  Future<ApiResponse> _prepareRealReturn(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return apiService!.prepareGstr1(period!, financialYear);
      case 'GSTR3B':
        return apiService!.prepareGstr3b(period!, financialYear);
      case 'GSTR9':
        return apiService!.prepareGstr9(financialYear);
      case 'GSTR9C':
        return apiService!.prepareGstr9c(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
  
  Future<ApiResponse> _fileRealReturn(
    String returnType, 
    String? period, 
    String financialYear
  ) async {
    switch (returnType) {
      case 'GSTR1':
        return apiService!.fileGstr1(period!, financialYear);
      case 'GSTR3B':
        return apiService!.fileGstr3b(period!, financialYear);
      case 'GSTR9':
        return apiService!.fileGstr9(financialYear);
      case 'GSTR9C':
        return apiService!.fileGstr9c(financialYear);
      default:
        throw ApiException(message: 'Unsupported return type: $returnType');
    }
  }
}
