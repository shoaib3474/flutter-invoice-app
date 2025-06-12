@echo off
echo 🔧 Fixing remaining API errors...

REM Fix all remaining missing success parameters in gst_api_client.dart
powershell -Command "(Get-Content lib\api\gst_api_client.dart) -replace 'statusCode: 500,', 'success: false,`n        statusCode: 500,' | Set-Content lib\api\gst_api_client.dart"
powershell -Command "(Get-Content lib\api\gst_api_client.dart) -replace 'statusCode: response\.statusCode,', 'success: false,`n        statusCode: response.statusCode,' | Set-Content lib\api\gst_api_client.dart"

REM Remove redundant statusCode: 500 arguments
powershell -Command "(Get-Content lib\api\gst_api_client.dart) -replace 'success: false,`n        statusCode: 500,', 'success: false,' | Set-Content lib\api\gst_api_client.dart"

REM Add success: true to successful responses
powershell -Command "(Get-Content lib\api\gst_api_client.dart) -replace 'message: ''Success'',', 'message: ''Success'',`n          success: true,' | Set-Content lib\api\gst_api_client.dart"

echo ✅ API errors fixed!

REM Run flutter analyze to check for remaining issues
echo 🔍 Running flutter analyze...
flutter analyze --no-fatal-infos

pause
