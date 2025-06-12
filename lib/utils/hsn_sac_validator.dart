import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class HsnSacValidator {
  // Check if HSN/SAC code is valid
  static bool isValid(String hsnSac) {
    // HSN codes are typically 4-8 digits
    // SAC codes are typically 6 digits
    
    // Remove any non-digit characters
    final cleanCode = hsnSac.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Check if the code has a valid length
    if (cleanCode.length < 4 || cleanCode.length > 8) {
      return false;
    }
    
    // All digits
    return RegExp(r'^\d+$').hasMatch(cleanCode);
  }
  
  // Get HSN/SAC code description (simplified)
  static String? getDescription(String hsnSac) {
    // In a real app, this would query a database or API
    // This is a simplified implementation
    return null;
  }
  
  // Get GST rate for HSN/SAC code (simplified)
  static double? getGstRate(String hsnSac) {
    // In a real app, this would query a database or API
    // This is a simplified implementation
    return null;
  }
  // In-memory cache of HSN codes and their tax rates
  final Map<String, double?> _hsnTaxRates = {};
  
  // Validate HSN code
  Future<HsnValidationResult> validateHsnCode(String hsnCode) async {
    if (hsnCode.isEmpty) {
      return HsnValidationResult(
        isValid: false,
        message: 'HSN code cannot be empty',
      );
    }
    
    // Basic format validation
    final RegExp regex = RegExp(r'^[0-9]{4,8}$');
    if (!regex.hasMatch(hsnCode)) {
      return HsnValidationResult(
        isValid: false,
        message: 'HSN code must be 4-8 digits',
      );
    }
    
    // Check if HSN code exists in our database
    // This is a simplified implementation
    // In a real app, you would check against a comprehensive HSN database
    try {
      final exists = await _checkHsnExists(hsnCode);
      if (!exists) {
        return HsnValidationResult(
          isValid: false,
          message: 'HSN code not found in database',
        );
      }
      
      return HsnValidationResult(
        isValid: true,
        message: 'Valid HSN code',
      );
    } catch (e) {
      // If we can't check, assume it's valid but warn
      return HsnValidationResult(
        isValid: true,
        message: 'HSN code format is valid, but could not verify in database',
      );
    }
  }
  
  // Validate SAC code
  Future<HsnValidationResult> validateSacCode(String sacCode) async {
    if (sacCode.isEmpty) {
      return HsnValidationResult(
        isValid: false,
        message: 'SAC code cannot be empty',
      );
    }
    
    // Basic format validation
    final RegExp regex = RegExp(r'^[0-9]{6}$');
    if (!regex.hasMatch(sacCode)) {
      return HsnValidationResult(
        isValid: false,
        message: 'SAC code must be 6 digits',
      );
    }
    
    // Check if SAC code exists in our database
    // This is a simplified implementation
    // In a real app, you would check against a comprehensive SAC database
    try {
      final exists = await _checkSacExists(sacCode);
      if (!exists) {
        return HsnValidationResult(
          isValid: false,
          message: 'SAC code not found in database',
        );
      }
      
      return HsnValidationResult(
        isValid: true,
        message: 'Valid SAC code',
      );
    } catch (e) {
      // If we can't check, assume it's valid but warn
      return HsnValidationResult(
        isValid: true,
        message: 'SAC code format is valid, but could not verify in database',
      );
    }
  }
  
  // Get tax rate for HSN code
  Future<double?> getTaxRateForHsn(String hsnCode) async {
    // Check cache first
    if (_hsnTaxRates.containsKey(hsnCode)) {
      return _hsnTaxRates[hsnCode];
    }
    
    // This is a simplified implementation
    // In a real app, you would fetch this from a comprehensive HSN database
    try {
      final taxRate = await _fetchTaxRateForHsn(hsnCode);
      _hsnTaxRates[hsnCode] = taxRate;
      return taxRate;
    } catch (e) {
      return null;
    }
  }
  
  // Check if HSN code exists in database
  Future<bool> _checkHsnExists(String hsnCode) async {
    // This is a simplified implementation
    // In a real app, you would check against a comprehensive HSN database
    try {
      // First try to load from local assets
      final String data = await rootBundle.loadString('assets/data/hsn_codes.json');
      final List<dynamic> hsnCodes = jsonDecode(data);
      
      return hsnCodes.contains(hsnCode);
    } catch (e) {
      // If local check fails, try online API
      try {
        final response = await http.get(
          Uri.parse('https://example.com/api/hsn/validate?code=$hsnCode'),
          headers: {'Accept': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['exists'] == true;
        }
        
        return false;
      } catch (e) {
        // If all checks fail, assume it exists
        return true;
      }
    }
  }
  
  // Check if SAC code exists in database
  Future<bool> _checkSacExists(String sacCode) async {
    // This is a simplified implementation
    // In a real app, you would check against a comprehensive SAC database
    try {
      // First try to load from local assets
      final String data = await rootBundle.loadString('assets/data/sac_codes.json');
      final List<dynamic> sacCodes = jsonDecode(data);
      
      return sacCodes.contains(sacCode);
    } catch (e) {
      // If local check fails, try online API
      try {
        final response = await http.get(
          Uri.parse('https://example.com/api/sac/validate?code=$sacCode'),
          headers: {'Accept': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['exists'] == true;
        }
        
        return false;
      } catch (e) {
        // If all checks fail, assume it exists
        return true;
      }
    }
  }
  
  // Fetch tax rate for HSN code
  Future<double?> _fetchTaxRateForHsn(String hsnCode) async {
    // This is a simplified implementation
    // In a real app, you would fetch this from a comprehensive HSN database
    try {
      // First try to load from local assets
      final String data = await rootBundle.loadString('assets/data/hsn_tax_rates.json');
      final Map<String, dynamic> taxRates = jsonDecode(data);
      
      if (taxRates.containsKey(hsnCode)) {
        return taxRates[hsnCode]?.toDouble();
      }
      
      return null;
    } catch (e) {
      // If local check fails, try online API
      try {
        final response = await http.get(
          Uri.parse('https://example.com/api/hsn/tax-rate?code=$hsnCode'),
          headers: {'Accept': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['taxRate']?.toDouble();
        }
        
        return null;
      } catch (e) {
        return null;
      }
    }
  }
}

class HsnValidationResult {
  final bool isValid;
  final String message;
  
  HsnValidationResult({
    required this.isValid,
    required this.message,
  });
}
