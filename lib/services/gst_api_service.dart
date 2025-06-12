import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api/api_response.dart';
import '../utils/api_exception.dart';

class GstApiService {
  final String baseUrl;
  final String apiKey;
  final http.Client _httpClient;

  GstApiService({
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

  // Generic GET request
  Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _httpClient.get(uri, headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // Generic POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await _httpClient.post(
        uri,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await _httpClient.put(
        uri,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // Process HTTP response
  ApiResponse _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode &lt; 300) {
      return ApiResponse(
        success: true,
        statusCode: response.statusCode,
        data: json.decode(response.body),
      );
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
  }

  // GSTR1 specific endpoints
  Future<ApiResponse> fetchGstr1Data(String period, String financialYear) async {
    return get('gstr1/fetch', queryParams: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> prepareGstr1(String period, String financialYear) async {
    return post('gstr1/prepare', data: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> fileGstr1(String period, String financialYear) async {
    return post('gstr1/file', data: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  // GSTR3B specific endpoints
  Future<ApiResponse> fetchGstr3bData(String period, String financialYear) async {
    return get('gstr3b/fetch', queryParams: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> prepareGstr3b(String period, String financialYear) async {
    return post('gstr3b/prepare', data: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> fileGstr3b(String period, String financialYear) async {
    return post('gstr3b/file', data: {
      'period': period,
      'financial_year': financialYear,
    });
  }

  // GSTR9 specific endpoints
  Future<ApiResponse> fetchGstr9Data(String financialYear) async {
    return get('gstr9/fetch', queryParams: {
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> prepareGstr9(String financialYear) async {
    return post('gstr9/prepare', data: {
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> fileGstr9(String financialYear) async {
    return post('gstr9/file', data: {
      'financial_year': financialYear,
    });
  }

  // GSTR9C specific endpoints
  Future<ApiResponse> fetchGstr9cData(String financialYear) async {
    return get('gstr9c/fetch', queryParams: {
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> prepareGstr9c(String financialYear) async {
    return post('gstr9c/prepare', data: {
      'financial_year': financialYear,
    });
  }

  Future<ApiResponse> fileGstr9c(String financialYear) async {
    return post('gstr9c/file', data: {
      'financial_year': financialYear,
    });
  }

  // Close the HTTP client when done
  void dispose() {
    _httpClient.close();
  }
}
