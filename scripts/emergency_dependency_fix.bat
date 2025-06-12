@echo off
echo 🚨 Emergency dependency fix...

REM Remove problematic files
if exist pubspec.lock del pubspec.lock
if exist .dart_tool rmdir /s /q .dart_tool
if exist build rmdir /s /q build

REM Create minimal working pubspec
(
echo name: flutter_invoice_app
echo description: A comprehensive GST invoice management application
echo publish_to: 'none'
echo version: 1.0.0+1
echo.
echo environment:
echo   sdk: '>=3.0.0 ^<4.0.0'
echo.
echo dependencies:
echo   flutter:
echo     sdk: flutter
echo   cupertino_icons: ^1.0.6
echo   provider: ^6.1.1
echo   http: ^1.1.0
echo   sqflite: ^2.3.0
echo   path_provider: ^2.1.1
echo   shared_preferences: ^2.2.2
echo   pdf: ^3.10.7
echo   file_picker: ^6.1.1
echo   uuid: ^4.2.1
echo.
echo dev_dependencies:
echo   flutter_test:
echo     sdk: flutter
echo   flutter_lints: ^3.0.0
echo.
echo flutter:
echo   uses-material-design: true
echo   assets:
echo     - assets/images/
echo     - assets/icons/
) > pubspec.yaml

echo 📦 Getting minimal dependencies...
flutter pub get

echo ✅ Emergency fix complete! Now you can gradually add more dependencies.
pause
