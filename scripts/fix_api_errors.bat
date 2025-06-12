@echo off
echo 🔧 Fixing API errors and warnings...

echo 📦 Cleaning up imports...

REM Remove unused imports from demo_gst_api_client.dart
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) | Where-Object { $_ -notmatch 'import.*dio' } | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) | Where-Object { $_ -notmatch 'import.*gstr2a_model' } | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) | Where-Object { $_ -notmatch 'import.*gstr2b_model' } | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) | Where-Object { $_ -notmatch 'import.*gstr4_model' } | Set-Content lib\api\demo_gst_api_client.dart"

REM Remove dart:convert from demo_gstr1_api_service.dart
powershell -Command "(Get-Content lib\api\demo\demo_gstr1_api_service.dart) | Where-Object { $_ -notmatch 'import.*dart:convert' } | Set-Content lib\api\demo\demo_gstr1_api_service.dart"

echo 🔧 Fixing nullable operations...
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'sum \+ $$item\.taxableValueInSource3 \?\? 0$$', 'sum + (item.taxableValueInSource3 ?? 0.0)' | Set-Content lib\api\demo_gst_api_client.dart"

echo 🔧 Removing unnecessary non-null assertions...
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'taxableValueInSource3!', 'taxableValueInSource3' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'igstInSource3!', 'igstInSource3' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'cgstInSource3!', 'cgstInSource3' | Set-Content lib\api\demo_gst_api_client.dart"
powershell -Command "(Get-Content lib\api\demo_gst_api_client.dart) -replace 'sgstInSource3!', 'sgstInSource3' | Set-Content lib\api\demo_gst_api_client.dart"

echo ✅ API errors fixed!

echo 🔍 Running analysis...
flutter analyze --no-fatal-infos
