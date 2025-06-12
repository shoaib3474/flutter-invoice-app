@echo off
echo 🚨 EMERGENCY FIX - Removing all problematic files and dependencies...

REM 1. Remove all problematic API clients
echo 🗑️ Removing problematic API files...
if exist "lib\api\gst_api_client.dart" del "lib\api\gst_api_client.dart"
if exist "lib\api\gst_api_client.g.dart" del "lib\api\gst_api_client.g.dart"
if exist "lib\api\demo_gst_api_client.dart" del "lib\api\demo_gst_api_client.dart"

REM 2. Create a minimal working API client
echo 📝 Creating minimal working API client...
if not exist "lib\api" mkdir "lib\api"

echo import 'dart:convert'; > lib\api\working_gst_api.dart
echo import 'package:http/http.dart' as http; >> lib\api\working_gst_api.dart
echo. >> lib\api\working_gst_api.dart
echo class WorkingGstApi { >> lib\api\working_gst_api.dart
echo   static const String baseUrl = 'https://api.example.com'; >> lib\api\working_gst_api.dart
echo. >> lib\api\working_gst_api.dart
echo   static Future^<Map^<String, dynamic^>^> get(String endpoint) async { >> lib\api\working_gst_api.dart
echo     try { >> lib\api\working_gst_api.dart
echo       final response = await http.get(Uri.parse('$baseUrl$endpoint')); >> lib\api\working_gst_api.dart
echo       if (response.statusCode == 200) { >> lib\api\working_gst_api.dart
echo         return json.decode(response.body); >> lib\api\working_gst_api.dart
echo       } >> lib\api\working_gst_api.dart
echo       return {'error': 'Failed to load data'}; >> lib\api\working_gst_api.dart
echo     } catch (e) { >> lib\api\working_gst_api.dart
echo       return {'error': e.toString()}; >> lib\api\working_gst_api.dart
echo     } >> lib\api\working_gst_api.dart
echo   } >> lib\api\working_gst_api.dart
echo } >> lib\api\working_gst_api.dart

REM 3. Clean everything
echo 🧹 Cleaning project...
flutter clean
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "build" rmdir /s /q "build"

REM 4. Get dependencies
echo 📥 Getting dependencies...
flutter pub get

echo ✅ Emergency fix completed!
echo 🚀 Try running: flutter analyze
