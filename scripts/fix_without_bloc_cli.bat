@echo off
echo 🔧 Fixing Flutter project without external CLI dependencies...

REM Clean and get dependencies
echo 📦 Cleaning and getting dependencies...
flutter clean
flutter pub get

REM Generate code without using bloc CLI
echo 🏗️ Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Run dart fix
echo 🛠️ Running dart fix...
dart fix --apply

REM Format code
echo 💅 Formatting code...
dart format lib/ --fix

REM Analyze for remaining issues
echo 🔍 Analyzing code...
flutter analyze

echo ✅ Fix completed! Check the analysis results above.
pause
