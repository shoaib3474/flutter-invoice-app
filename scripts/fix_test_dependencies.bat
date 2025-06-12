@echo off
echo 🔧 Fixing test dependencies and configurations...

REM Create missing directories
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\icons" mkdir "assets\icons"
if not exist "assets\config" mkdir "assets\config"
if not exist "assets\sample_data" mkdir "assets\sample_data"
if not exist "fonts" mkdir "fonts"
if not exist "test\unit" mkdir "test\unit"
if not exist "test\widget" mkdir "test\widget"
if not exist "test\integration" mkdir "test\integration"

REM Create placeholder font files
echo. > fonts\Roboto-Regular.ttf
echo. > fonts\Roboto-Bold.ttf

REM Create placeholder asset files
echo # Placeholder > assets\images\.gitkeep
echo # Placeholder > assets\icons\.gitkeep
echo # Placeholder > assets\config\.gitkeep
echo # Placeholder > assets\sample_data\.gitkeep

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Generate code if needed
echo 🔨 Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Run dart fix
echo 🔧 Running dart fix...
dart fix --apply

REM Analyze code
echo 🔍 Analyzing code...
flutter analyze

echo ✅ Test dependencies and configurations fixed!
pause
