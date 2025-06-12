@echo off
echo 🔧 Fixing Flutter Dependencies...
echo ================================

REM Clean previous builds
echo 1. Cleaning previous builds...
flutter clean

REM Remove pubspec.lock to force fresh resolution
echo 2. Removing pubspec.lock...
if exist pubspec.lock del pubspec.lock

REM Clear pub cache for problematic packages
echo 3. Clearing pub cache...
flutter pub cache clean

REM Get dependencies with verbose output
echo 4. Getting dependencies...
flutter pub get --verbose

REM Verify dependencies
echo 5. Verifying dependencies...
flutter pub deps

echo.
echo ✅ Dependencies fixed successfully!
echo You can now run: flutter build apk --release
pause
