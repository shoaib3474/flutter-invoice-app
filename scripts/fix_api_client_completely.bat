@echo off
echo 🔧 Fixing API Client Issues Completely...

REM Remove the problematic retrofit-based API client
if exist "lib\api\gst_api_client.dart" (
    echo 📁 Backing up original gst_api_client.dart...
    move "lib\api\gst_api_client.dart" "lib\api\gst_api_client.dart.backup"
)

echo 🔄 Updating import statements...

REM Update imports in all Dart files (Windows version)
for /r lib %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'import.*gst_api_client\.dart.*', 'import ''../api/simple_gst_api_client.dart'';' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'GstApiClient', 'SimpleGstApiClient' | Set-Content '%%f'"
)

echo 📦 Cleaning and getting dependencies...
flutter clean
flutter pub get

echo 🔨 Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ✅ API Client fix completed!
echo 📝 The old gst_api_client.dart has been backed up as gst_api_client.dart.backup
echo 🚀 You can now run: flutter analyze
