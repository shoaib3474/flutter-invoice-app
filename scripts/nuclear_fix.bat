@echo off
echo ☢️ NUCLEAR FIX - Starting complete cleanup...

REM 1. Remove ALL generated files
echo 🗑️ Removing all generated and problematic files...
for /r . %%f in (*.g.dart) do del "%%f"
for /r . %%f in (*.freezed.dart) do del "%%f"
for /r . %%f in (*.mocks.dart) do del "%%f"

REM 2. Remove problematic API files
if exist "lib\api\gst_api_client.dart" del "lib\api\gst_api_client.dart"
if exist "lib\api\demo_gst_api_client.dart" del "lib\api\demo_gst_api_client.dart"
if exist "lib\api\simple_gst_api_client.dart" del "lib\api\simple_gst_api_client.dart"

REM 3. Nuclear clean
echo ☢️ Nuclear cleaning...
flutter clean
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "build" rmdir /s /q "build"
if exist "pubspec.lock" del "pubspec.lock"

REM 4. Get fresh dependencies
echo 📥 Getting fresh dependencies...
flutter pub get

echo ✅ Nuclear fix completed!
echo 🚀 Now run: flutter analyze
