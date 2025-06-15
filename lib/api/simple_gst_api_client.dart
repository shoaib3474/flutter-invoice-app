import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api/api_response.dart';
import '../models/gst_returns/gstr1_model.dart';
import '../models/gst_returns/gstr2a_model.dart';
import '../models/gst_returns/gstr2b_model.dart';
import '../models/gst_returns/gstr3b_model.dart';
import '../models/gst_returns/gstr4_model.dart';
import '../models/gst_returns/gstr9_model.dart';
import '../models/gst_returns/gstr9c_model.dart';
import '../models/reconciliation/reconciliation_result_model.dart'
    as reconciliation;

class SimpleGstApiClient {
  final String baseUrl;
  final http.Client _client;

  SimpleGstApiClient({
    this.baseUrl = 'https://demo-gst-api.example.com/api/v1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper method to make GET requests
  Future<ApiResponse<T>> _get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse<T>(
          data: fromJson(data),
          success: true,
          message: 'Success',
        );
      } else {
        return ApiResponse<T>(
          data: null,
          success: false,
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Helper method to make POST requests
  Future<ApiResponse<T>> _post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse<T>(
          data: fromJson(data),
          success: true,
          message: 'Success',
        );
      } else {
        return ApiResponse<T>(
          data: null,
          success: false,
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // GSTR-1 endpoints
  Future<ApiResponse<GSTR1Summary>> getGSTR1Summary(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR1Summary>(
      '/gstr1/summary',
      GSTR1Summary.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<GSTR1>> getGSTR1Details(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR1>(
      '/gstr1/details',
      GSTR1.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<String>> saveGSTR1(GSTR1 gstr1) async {
    return _post<String>(
      '/gstr1/save',
      gstr1.toJson(),
      (data) => data['message'] as String,
    );
  }

  Future<ApiResponse<String>> submitGSTR1(GSTR1 gstr1) async {
    return _post<String>(
      '/gstr1/submit',
      gstr1.toJson(),
      (data) => data['message'] as String,
    );
  }

  // GSTR-2A endpoints
  Future<ApiResponse<GSTR2ASummary>> getGSTR2ASummary(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR2ASummary>(
      '/gstr2a/summary',
      GSTR2ASummary.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<GSTR2A>> getGSTR2ADetails(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR2A>(
      '/gstr2a/details',
      GSTR2A.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  // GSTR-2B endpoints
  Future<ApiResponse<GSTR2BSummary>> getGSTR2BSummary(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR2BSummary>(
      '/gstr2b/summary',
      GSTR2BSummary.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<GSTR2B>> getGSTR2BDetails(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR2B>(
      '/gstr2b/details',
      GSTR2B.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  // GSTR-3B endpoints
  Future<ApiResponse<GSTR3BSummary>> getGSTR3BSummary(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR3BSummary>(
      '/gstr3b/summary',
      GSTR3BSummary.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<GSTR3B>> getGSTR3BDetails(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR3B>(
      '/gstr3b/details',
      GSTR3B.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<String>> saveGSTR3B(GSTR3B gstr3b) async {
    return _post<String>(
      '/gstr3b/save',
      gstr3b.toJson(),
      (data) => data['message'] as String,
    );
  }

  Future<ApiResponse<String>> submitGSTR3B(GSTR3B gstr3b) async {
    return _post<String>(
      '/gstr3b/submit',
      gstr3b.toJson(),
      (data) => data['message'] as String,
    );
  }

  // GSTR-4 endpoints
  Future<ApiResponse<GSTR4Model>> getGSTR4Summary(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR4Model>(
      '/gstr4/summary',
      GSTR4Model.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<GSTR4Model>> getGSTR4Details(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<GSTR4Model>(
      '/gstr4/details',
      GSTR4Model.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<String>> saveGSTR4(GSTR4Model gstr4) async {
    return _post<String>(
      '/gstr4/save',
      gstr4.toJson(),
      (data) => data['message'] as String,
    );
  }

  Future<ApiResponse<String>> submitGSTR4(GSTR4Model gstr4) async {
    return _post<String>(
      '/gstr4/submit',
      gstr4.toJson(),
      (data) => data['message'] as String,
    );
  }

  // GSTR-9 endpoints
  Future<ApiResponse<GSTR9>> autoPopulateGSTR9(
    String gstin,
    String financialYear,
  ) async {
    return _get<GSTR9>(
      '/gstr9/auto-populate',
      GSTR9.fromJson,
      {'gstin': gstin, 'financial_year': financialYear},
    );
  }

  Future<ApiResponse<GSTR9>> getGSTR9Details(
    String gstin,
    String financialYear,
  ) async {
    return _get<GSTR9>(
      '/gstr9/details',
      GSTR9.fromJson,
      {'gstin': gstin, 'financial_year': financialYear},
    );
  }

  Future<ApiResponse<String>> saveGSTR9(GSTR9 gstr9) async {
    return _post<String>(
      '/gstr9/save',
      gstr9.toJson(),
      (data) => data['message'] as String,
    );
  }

  Future<ApiResponse<String>> submitGSTR9(GSTR9 gstr9) async {
    return _post<String>(
      '/gstr9/submit',
      gstr9.toJson(),
      (data) => data['message'] as String,
    );
  }

  // GSTR-9C endpoints
  Future<ApiResponse<GSTR9C>> autoPopulateGSTR9C(
    String gstin,
    String financialYear,
  ) async {
    return _get<GSTR9C>(
      '/gstr9c/auto-populate',
      GSTR9C.fromJson,
      {'gstin': gstin, 'financial_year': financialYear},
    );
  }

  Future<ApiResponse<GSTR9C>> getGSTR9CDetails(
    String gstin,
    String financialYear,
  ) async {
    return _get<GSTR9C>(
      '/gstr9c/details',
      GSTR9C.fromJson,
      {'gstin': gstin, 'financial_year': financialYear},
    );
  }

  Future<ApiResponse<String>> saveGSTR9C(GSTR9C gstr9c) async {
    return _post<String>(
      '/gstr9c/save',
      gstr9c.toJson(),
      (data) => data['message'] as String,
    );
  }

  Future<ApiResponse<String>> submitGSTR9C(GSTR9C gstr9c) async {
    return _post<String>(
      '/gstr9c/submit',
      gstr9c.toJson(),
      (data) => data['message'] as String,
    );
  }

  // Comparison endpoints
  Future<ApiResponse<reconciliation.ComparisonResult>> compareGSTR2AGSTR2B(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<reconciliation.ComparisonResult>(
      '/comparison/2a-2b',
      reconciliation.ComparisonResult.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<reconciliation.ComparisonResult>> compareGSTR2AGSTR1(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<reconciliation.ComparisonResult>(
      '/comparison/2a-1',
      reconciliation.ComparisonResult.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<reconciliation.ComparisonResult>> compareGSTR1GSTR3B(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<reconciliation.ComparisonResult>(
      '/comparison/1-3b',
      reconciliation.ComparisonResult.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  Future<ApiResponse<reconciliation.ComparisonResult>> compareGSTR1GSTR2BGSTR3B(
    String gstin,
    String returnPeriod,
  ) async {
    return _get<reconciliation.ComparisonResult>(
      '/comparison/1-2b-3b',
      reconciliation.ComparisonResult.fromJson,
      {'gstin': gstin, 'return_period': returnPeriod},
    );
  }

  void dispose() {
    _client.close();
  }
}
