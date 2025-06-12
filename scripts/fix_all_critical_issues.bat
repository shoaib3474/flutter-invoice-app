@echo off
echo 🔧 Fixing all critical issues in Flutter Invoice App...

REM Clean previous builds
echo 📦 Cleaning previous builds...
flutter clean
rmdir /s /q .dart_tool 2>nul
rmdir /s /q build 2>nul

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Generate missing files
echo 🔨 Generating missing files...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Fix linting issues
echo 🧹 Fixing linting issues...
dart fix --apply

REM Format code
echo ✨ Formatting code...
dart format lib\ --fix

REM Analyze code
echo 🔍 Analyzing code...
flutter analyze --no-fatal-infos

echo ✅ Critical issues fixed! Try running 'flutter run' now.
pause
