@echo off
echo 🔧 Fixing Firebase dependencies...

REM Clean previous builds
echo 📦 Cleaning previous builds...
flutter clean

REM Remove pubspec.lock to force fresh resolution
echo 🗑️ Removing pubspec.lock...
if exist pubspec.lock del pubspec.lock

REM Get dependencies with verbose output
echo 📥 Getting dependencies...
flutter pub get --verbose

REM Check for any remaining issues
echo 🔍 Checking for dependency conflicts...
flutter pub deps

REM Run code generation if needed
echo 🏗️ Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ✅ Firebase dependencies fixed!
pause
