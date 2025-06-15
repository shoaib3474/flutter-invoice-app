// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api/api_response.dart';
import '../models/gst_returns/gstr1_model.dart';
import '../models/gst_returns/gstr2a_model.dart';
import '../models/gst_returns/gstr2b_model.dart';
import '../models/gst_returns/gstr3b_model.dart';
import '../models/gst_returns/gstr4_model.dart';

class GstApiClient {
  GstApiClient({
    this.baseUrl = 'https://demo-gst-api.example.com/api/v1',
    http.Client? client,
  }) : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;

  // GSTR-1 endpoints
  Future<ApiResponse<GSTR1Summary>> getGSTR1Summary(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr1/summary?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR1Summary>(
          data: GSTR1Summary.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR1Summary>(
          data: null,
          message: 'Failed to fetch GSTR1 summary',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR1Summary>(
        data: null,
        message: 'Error: $e',
        success: false,
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<GSTR1>> getGSTR1Details(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr1/details?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR1>(
          data: GSTR1.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR1>(
          data: null,
          message: 'Failed to fetch GSTR1 details',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR1>(
        data: null,
        message: 'Error: $e',
        success: false,
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<String>> saveGSTR1(GSTR1 gstr1) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr1/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr1.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR1 saved successfully'
            : 'Failed to save GSTR1',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<String>> submitGSTR1(GSTR1 gstr1) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr1/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr1.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR1 submitted successfully'
            : 'Failed to submit GSTR1',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  // GSTR-2A endpoints
  Future<ApiResponse<GSTR2ASummary>> getGSTR2ASummary(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr2a/summary?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR2ASummary>(
          data: GSTR2ASummary.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR2ASummary>(
          data: null,
          message: 'Failed to fetch GSTR2A summary',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR2ASummary>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<GSTR2A>> getGSTR2ADetails(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr2a/details?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR2A>(
          data: GSTR2A.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR2A>(
          data: null,
          message: 'Failed to fetch GSTR2A details',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR2A>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  // GSTR-2B endpoints
  Future<ApiResponse<GSTR2BSummary>> getGSTR2BSummary(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr2b/summary?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR2BSummary>(
          data: GSTR2BSummary.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR2BSummary>(
          data: null,
          message: 'Failed to fetch GSTR2B summary',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR2BSummary>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<GSTR2B>> getGSTR2BDetails(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr2b/details?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR2B>(
          data: GSTR2B.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR2B>(
          data: null,
          message: 'Failed to fetch GSTR2B details',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR2B>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  // GSTR-3B endpoints
  Future<ApiResponse<GSTR3BSummary>> getGSTR3BSummary(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr3b/summary?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR3BSummary>(
          data: GSTR3BSummary.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR3BSummary>(
          data: null,
          message: 'Failed to fetch GSTR3B summary',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR3BSummary>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<GSTR3B>> getGSTR3BDetails(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr3b/details?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR3B>(
          data: GSTR3B.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR3B>(
          data: null,
          message: 'Failed to fetch GSTR3B details',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR3B>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<String>> saveGSTR3B(GSTR3B gstr3b) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr3b/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr3b.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR3B saved successfully'
            : 'Failed to save GSTR3B',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<String>> submitGSTR3B(GSTR3B gstr3b) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr3b/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr3b.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR3B submitted successfully'
            : 'Failed to submit GSTR3B',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  // GSTR-4 endpoints
  Future<ApiResponse<GSTR4Model>> getGSTR4Summary(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr4/summary?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR4Model>(
          data: GSTR4Model.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR4Model>(
          data: null,
          message: 'Failed to fetch GSTR4 summary',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR4Model>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<GSTR4Model>> getGSTR4Details(
    String gstin,
    String returnPeriod,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/gstr4/details?gstin=$gstin&return_period=$returnPeriod'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<GSTR4Model>(
          data: GSTR4Model.fromJson(data),
          message: 'Success',
          success: true,
        );
      } else {
        return ApiResponse<GSTR4Model>(
          data: null,
          message: 'Failed to fetch GSTR4 details',
          success: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<GSTR4Model>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<String>> saveGSTR4(GSTR4Model gstr4) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr4/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr4.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR4 saved successfully'
            : 'Failed to save GSTR4',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  Future<ApiResponse<String>> submitGSTR4(GSTR4Model gstr4) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/gstr4/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gstr4.toJson()),
      );

      return ApiResponse<String>(
        data: response.body,
        message: response.statusCode == 200
            ? 'GSTR4 submitted successfully'
            : 'Failed to submit GSTR4',
        statusCode: response.statusCode,
        success: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Error: $e',
        success: false,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
