@echo off
echo 🚀 Running comprehensive warning fixer...

REM Run the Dart warning fixer
dart lib\utils\warning_fixer.dart

REM Run the batch script fixer
call scripts\fix_all_warnings.bat

REM Clean and analyze
flutter clean
flutter pub get
flutter analyze

echo 🎉 All warnings should be fixed now!
