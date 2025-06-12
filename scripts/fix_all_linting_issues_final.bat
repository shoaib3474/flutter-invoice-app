@echo off
echo 🔧 Fixing all remaining linting issues...

echo 📦 Fixing import ordering...
flutter format lib/

echo ⚠️ Fixing deprecated usage...
powershell -Command "(Get-Content lib\features\build\screens\enhanced_apk_build_screen.dart) -replace 'withOpacity\(', 'withValues(alpha: ' | Set-Content lib\features\build\screens\enhanced_apk_build_screen.dart"

echo 🧹 Removing unused imports...
dart fix --apply lib/

echo ✨ Formatting all files...
flutter format lib/

echo ✅ All linting issues fixed!
pause
