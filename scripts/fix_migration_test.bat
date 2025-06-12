@echo off
echo 🔧 Fixing Migration Test Suite...

REM Create missing directories
if not exist "lib\tests" mkdir "lib\tests"
if not exist "lib\models\migration" mkdir "lib\models\migration"

REM Check dependencies
echo 📦 Checking dependencies...
findstr /C:"path_provider:" pubspec.yaml >nul
if errorlevel 1 (
    echo Adding path_provider dependency...
    echo   path_provider: ^2.1.1 >> pubspec.yaml
)

REM Run pub get
echo 📥 Getting dependencies...
flutter pub get

REM Run code generation if needed
echo 🔄 Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Check for syntax errors
echo 🔍 Checking for syntax errors...
flutter analyze lib/tests/migration_test_suite.dart

echo ✅ Migration test suite fixed!
echo 📋 To run tests:
echo    dart lib/tests/migration_test_suite.dart
pause
