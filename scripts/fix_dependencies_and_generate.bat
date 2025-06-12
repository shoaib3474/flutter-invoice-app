@echo off
echo 🔧 Fixing Flutter Invoice App Dependencies and Code Generation...

REM Clean previous builds
echo 📦 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Generate missing files
echo 🔨 Generating code files...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Check for any remaining issues
echo 🔍 Checking for issues...
flutter analyze --no-fatal-infos

echo ✅ Dependencies and code generation completed!
echo.
echo 📋 Next steps:
echo 1. Run 'flutter run' to test the app
echo 2. Fix any remaining linting issues if needed
echo 3. Set up Firebase if you want to use Firebase features

pause
