@echo off
echo 🔧 Fixing Flutter dependencies and build issues...

REM 1. Clean everything
echo 📦 Cleaning project...
flutter clean
del /f /q pubspec.lock 2>nul
rmdir /s /q android\.gradle 2>nul
rmdir /s /q android\app\build 2>nul
rmdir /s /q build 2>nul

REM 2. Create missing asset directories
echo 📁 Creating asset directories...
mkdir assets\images 2>nul
mkdir assets\icons 2>nul
mkdir assets\config 2>nul
mkdir assets\sample_data 2>nul

REM 3. Add placeholder files to prevent asset errors
echo. > assets\images\.gitkeep
echo. > assets\icons\.gitkeep
echo. > assets\config\.gitkeep
echo. > assets\sample_data\.gitkeep

REM 4. Get dependencies with major version upgrades
echo 📦 Getting dependencies...
flutter pub get
flutter pub upgrade --major-versions

REM 5. Generate code
echo 🔨 Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM 6. Clean and rebuild Android
echo 🏗️ Cleaning Android build...
cd android
call gradlew clean
cd ..

REM 7. Analyze for remaining issues
echo 🔍 Analyzing code...
flutter analyze --no-fatal-infos

REM 8. Try building
echo 🚀 Building APK...
flutter build apk --release --verbose

echo ✅ Build process completed!
pause
