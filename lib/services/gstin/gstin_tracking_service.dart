import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gstin/gstin_filing_history.dart';
import '../../models/gstin/jurisdiction_model.dart';
import '../../utils/api_exception.dart';

class GstinTrackingService {
  final String baseUrl;
  final String apiKey;
  final http.Client _httpClient;

  GstinTrackingService({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
  };

  /// Fetches the filing history for a given GSTIN
  Future<GstinFilingHistory> getFilingHistory(String gstin) async {
    final uri = Uri.parse('$baseUrl/gstin/track/$gstin');

    try {
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return GstinFilingHistory.fromJson(data);
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (_) {
          errorData = {'message': 'Unknown error occurred'};
        }

        throw ApiException(
          statusCode: response.statusCode,
          message: errorData['message'] ?? 'API Error: ${response.statusCode}',
          errors: errorData['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }
  
  /// Search for GSTIN details by PAN
  Future<List<GstinFilingHistory>> searchByPan(String pan) async {
    final uri = Uri.parse('$baseUrl/pan/search/$pan');

    try {
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => GstinFilingHistory.fromJson(item)).toList();
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (_) {
          errorData = {'message': 'Unknown error occurred'};
        }

        throw ApiException(
          statusCode: response.statusCode,
          message: errorData['message'] ?? 'API Error: ${response.statusCode}',
          errors: errorData['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }
  
  /// Get jurisdiction details for a GSTIN or PAN
  Future<GstJurisdiction> getJurisdiction(String gstinOrPan) async {
    final uri = Uri.parse('$baseUrl/jurisdiction/$gstinOrPan');

    try {
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return GstJurisdiction.fromMap(data);
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (_) {
          errorData = {'message': 'Unknown error occurred'};
        }

        throw ApiException(
          statusCode: response.statusCode,
          message: errorData['message'] ?? 'API Error: ${response.statusCode}',
          errors: errorData['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  /// Dispose the HTTP client when done
  void dispose() {
    _httpClient.close();
  }
}
