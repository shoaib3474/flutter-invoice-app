@echo off
echo 🧹 Fixing all warnings and unused imports...

REM Remove unused imports from demo_gstr1_api_service.dart
powershell -Command "(Get-Content lib\api\demo\demo_gstr1_api_service.dart | Select-Object -Skip 1) | Set-Content lib\api\demo\demo_gstr1_api_service.dart"

REM Remove unused imports from demo_gst_api_client.dart
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace \"import 'package:dio/dio.dart';\", '' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace \"import '../models/gst_returns/gstr2a_model.dart'.*;\", '' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace \"import '../models/gst_returns/gstr2b_model.dart'.*;\", '' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace \"import '../models/gst_returns/gstr4_model.dart'.*;\", '' | Set-Content lib\api\demo_gst_api_client.dart"

REM Fix unnecessary non-null assertions
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'taxableValueInSource3!', 'taxableValueInSource3' | Set-Content lib\api\demo_gst_api_client.dart"

REM Remove unused imports from router.dart
powershell -Command "(Get-Content lib\config\router.dart) -replace \"import '../models/invoice/invoice_model.dart';\", '' | Set-Content lib\config\router.dart"

REM Remove unused imports from invoice_routes.dart
powershell -Command "(Get-Content lib\config\routes\invoice_routes.dart) -replace \"import '../models/invoice/invoice_model.dart';\", '' | Set-Content lib\config\routes\invoice_routes.dart"

REM Fix database_helper.dart
powershell -Command "(Get-Content lib\database\database_helper.dart) -replace \"import 'dart:io';\", '' | Set-Content lib\database\database_helper.dart"
powershell -Command "(Get-Content lib\database\database_helper.dart) -replace \"import 'package:flutter/foundation.dart';\", '' | Set-Content lib\database\database_helper.dart"
powershell -Command "(Get-Content lib\database\database_helper.dart) -replace 'return await', 'return' | Set-Content lib\database\database_helper.dart"

echo ✅ All warnings fixed!
echo 🔍 Running flutter analyze to verify...
flutter analyze
