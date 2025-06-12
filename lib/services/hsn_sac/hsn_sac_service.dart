import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/hsn_sac/hsn_sac_model.dart';
import 'package:http/http.dart' as http;
import '../../utils/api_exception.dart';

class HsnSacService {
  static const String _cacheKey = 'hsn_sac_cache';
  final String? baseUrl;
  final String? apiKey;
  
  HsnSacService({
    this.baseUrl,
    this.apiKey,
  });
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': apiKey != null ? 'Bearer $apiKey' : '',
    'Accept': 'application/json',
  };
  
  /// Search for HSN/SAC codes
  Future<List<HsnSacCode>> searchCodes(String query, {String? type}) async {
    // First try to get from cache
    final cachedResults = await _getFromCache(query, type);
    if (cachedResults.isNotEmpty) {
      return cachedResults;
    }
    
    // If no cache or empty results, fetch from API if available
    if (baseUrl != null && baseUrl!.isNotEmpty) {
      try {
        final queryParams = {
          'q': query,
          if (type != null) 'type': type,
        };
        
        final uri = Uri.parse('$baseUrl/hsn-sac/search').replace(
          queryParameters: queryParams,
        );
        
        final response = await http.get(uri, headers: _headers);
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final List<dynamic> data = json.decode(response.body);
          final results = data.map((item) => HsnSacCode.fromMap(item)).toList();
          
          // Cache the results
          await _saveToCache(query, type, results);
          
          return results;
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to fetch HSN/SAC codes',
          );
        }
      } catch (e) {
        debugPrint('Error searching HSN/SAC codes: $e');
        // Return fallback data or empty list
        return _getFallbackData(query, type);
      }
    } else {
      // If no API URL, use fallback data
      return _getFallbackData(query, type);
    }
  }
  
  /// Get details for a specific HSN/SAC code
  Future<HsnSacCode?> getCodeDetails(String code, {String? type}) async {
    // First try to get from cache
    final cachedResults = await _getFromCache(code, type);
    if (cachedResults.isNotEmpty) {
      return cachedResults.first;
    }
    
    // If no cache, fetch from API if available
    if (baseUrl != null && baseUrl!.isNotEmpty) {
      try {
        final queryParams = {
          if (type != null) 'type': type,
        };
        
        final uri = Uri.parse('$baseUrl/hsn-sac/code/$code').replace(
          queryParameters: queryParams,
        );
        
        final response = await http.get(uri, headers: _headers);
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          final result = HsnSacCode.fromMap(data);
          
          // Cache the result
          await _saveToCache(code, type, [result]);
          
          return result;
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to fetch HSN/SAC code details',
          );
        }
      } catch (e) {
        debugPrint('Error getting HSN/SAC code details: $e');
        // Return fallback data or null
        final fallbackData = _getFallbackData(code, type);
        return fallbackData.isNotEmpty ? fallbackData.first : null;
      }
    } else {
      // If no API URL, use fallback data
      final fallbackData = _getFallbackData(code, type);
      return fallbackData.isNotEmpty ? fallbackData.first : null;
    }
  }
  
  /// Get from cache
  Future<List<HsnSacCode>> _getFromCache(String query, String? type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) {
        return [];
      }
      
      final Map<String, dynamic> cache = json.decode(cacheJson);
      final String cacheKey = _generateCacheKey(query, type);
      
      if (!cache.containsKey(cacheKey)) {
        return [];
      }
      
      final List<dynamic> cachedData = cache[cacheKey];
      return cachedData.map((item) => HsnSacCode.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting from cache: $e');
      return [];
    }
  }
  
  /// Save to cache
  Future<void> _saveToCache(String query, String? type, List<HsnSacCode> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      Map<String, dynamic> cache = {};
      if (cacheJson != null) {
        cache = json.decode(cacheJson);
      }
      
      final String cacheKey = _generateCacheKey(query, type);
      cache[cacheKey] = results.map((item) => item.toMap()).toList();
      
      await prefs.setString(_cacheKey, json.encode(cache));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }
  
  /// Generate cache key
  String _generateCacheKey(String query, String? type) {
    return '${query.toLowerCase()}_${type ?? 'all'}';
  }
  
  /// Get fallback data for offline use
  List<HsnSacCode> _getFallbackData(String query, String? type) {
    // Common HSN codes
    final commonHsnCodes = [
      HsnSacCode(
        code: '1001',
        description: 'Wheat and meslin',
        type: 'HSN',
        gstRate: 0.0,
        category: 'Food',
      ),
      HsnSacCode(
        code: '8471',
        description: 'Automatic data processing machines and units thereof',
        type: 'HSN',
        gstRate: 18.0,
        category: 'Electronics',
      ),
      HsnSacCode(
        code: '8517',
        description: 'Telephone sets, including smartphones',
        type: 'HSN',
        gstRate: 18.0,
        category: 'Electronics',
      ),
      HsnSacCode(
        code: '9403',
        description: 'Other furniture and parts thereof',
        type: 'HSN',
        gstRate: 18.0,
        category: 'Furniture',
      ),
      HsnSacCode(
        code: '6201',
        description: 'Men\'s or boys\' overcoats, car-coats, capes, cloaks, anoraks',
        type: 'HSN',
        gstRate: 12.0,
        category: 'Textiles',
      ),
    ];
    
    // Common SAC codes
    final commonSacCodes = [
      HsnSacCode(
        code: '9983',
        description: 'Professional, technical and business services',
        type: 'SAC',
        gstRate: 18.0,
        category: 'Services',
      ),
      HsnSacCode(
        code: '9954',
        description: 'Construction services',
        type: 'SAC',
        gstRate: 18.0,
        category: 'Services',
      ),
      HsnSacCode(
        code: '9964',
        description: 'Passenger transport services',
        type: 'SAC',
        gstRate: 5.0,
        category: 'Transport',
      ),
      HsnSacCode(
        code: '9981',
        description: 'Research and development services',
        type: 'SAC',
        gstRate: 18.0,
        category: 'Services',
      ),
      HsnSacCode(
        code: '9985',
        description: 'Support services',
        type: 'SAC',
        gstRate: 18.0,
        category: 'Services',
      ),
    ];
    
    // Filter based on type and query
    List<HsnSacCode> allCodes = [];
    
    if (type == null || type.toLowerCase() == 'hsn') {
      allCodes.addAll(commonHsnCodes);
    }
    
    if (type == null || type.toLowerCase() == 'sac') {
      allCodes.addAll(commonSacCodes);
    }
    
    // Filter by query
    final lowercaseQuery = query.toLowerCase();
    return allCodes.where((code) {
      return code.code.toLowerCase().contains(lowercaseQuery) ||
             code.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
