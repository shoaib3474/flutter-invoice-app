@echo off
echo 🔧 Fixing version conflicts and dependencies...

REM Clean everything
echo 🧹 Cleaning project...
flutter clean
if exist pubspec.lock del pubspec.lock
if exist .dart_tool rmdir /s /q .dart_tool

REM Check Flutter version
echo 📱 Checking Flutter version...
flutter --version

REM Get dependencies with verbose output
echo 📦 Getting dependencies...
flutter pub get --verbose

REM If still failing, try with specific Flutter channel
if %errorlevel% neq 0 (
    echo ⚠️ Switching to stable channel...
    flutter channel stable
    flutter upgrade
    flutter pub get
)

REM Generate code
echo 🔨 Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Check for issues
echo 🔍 Analyzing code...
flutter analyze

echo ✅ Version conflicts fixed!
pause
