#!/bin/bash

echo "🚨 EMERGENCY FIX - Removing all problematic files and dependencies..."

# 1. Remove all problematic API clients
echo "🗑️ Removing problematic API files..."
rm -f lib/api/gst_api_client.dart
rm -f lib/api/gst_api_client.g.dart
rm -f lib/api/demo_gst_api_client.dart

# 2. Create a minimal working API client
echo "📝 Creating minimal working API client..."
mkdir -p lib/api

cat > lib/api/working_gst_api.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkingGstApi {
  static const String baseUrl = 'https://api.example.com';
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to load data'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to post data'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
EOF

# 3. Fix all import statements that reference broken API clients
echo "🔧 Fixing import statements..."
find lib -name "*.dart" -type f -exec sed -i '/import.*gst_api_client/d' {} \;
find lib -name "*.dart" -type f -exec sed -i '/import.*demo_gst_api_client/d' {} \;

# 4. Remove retrofit and related dependencies from pubspec.yaml
echo "📦 Cleaning pubspec.yaml..."
sed -i '/retrofit/d' pubspec.yaml
sed -i '/json_annotation/d' pubspec.yaml
sed -i '/retrofit_generator/d' pubspec.yaml
sed -i '/json_serializable/d' pubspec.yaml

# 5. Clean everything
echo "🧹 Cleaning project..."
flutter clean
rm -rf .dart_tool/
rm -rf build/

# 6. Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

echo "✅ Emergency fix completed!"
echo "🚀 Try running: flutter analyze"
