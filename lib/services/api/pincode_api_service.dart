import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/address/pincode_model.dart';

class PincodeApiService {
  static const String _baseUrl = 'https://api.postalpincode.in';
  
  /// Get address details by PIN code
  /// API: https://api.postalpincode.in/pincode/{pincode}
  static Future<List<PostOffice>> getAddressByPincode(String pincode) async {
    try {
      if (pincode.length != 6) {
        throw Exception('PIN code must be 6 digits');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/pincode/$pincode'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List<dynamic> postOffices = data[0]['PostOffice'];
          return postOffices.map((office) => PostOffice.fromJson(office)).toList();
        } else {
          throw Exception('No data found for PIN code: $pincode');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching PIN code data: $e');
    }
  }
  
  /// Get PIN codes by post office name
  /// API: https://api.postalpincode.in/postoffice/{postoffice_name}
  static Future<List<PostOffice>> getPincodesByPostOffice(String postOfficeName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/postoffice/$postOfficeName'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List<dynamic> postOffices = data[0]['PostOffice'];
          return postOffices.map((office) => PostOffice.fromJson(office)).toList();
        } else {
          throw Exception('No data found for post office: $postOfficeName');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching post office data: $e');
    }
  }
}
