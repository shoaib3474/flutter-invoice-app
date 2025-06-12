@echo off
echo 🚀 Quick dependency fix...

REM Update pubspec.yaml dependencies to latest compatible versions
echo 📦 Updating dependencies...

REM Clean everything
flutter clean
rmdir /s /q .dart_tool 2>nul
rmdir /s /q build 2>nul

REM Get dependencies
flutter pub get

REM Update dependencies
flutter pub upgrade

REM Run code generation
echo 🏗️ Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Fix and format
dart fix --apply
dart format lib/ --fix

REM Quick analysis
flutter analyze --no-fatal-infos

echo ✅ Quick fix completed!
pause
