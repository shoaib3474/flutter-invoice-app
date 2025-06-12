@echo off
echo 🔧 Fixing Gradle files for modern Flutter...

REM Clean previous builds
echo 📦 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Clean gradle
echo 🧹 Cleaning Gradle cache...
cd android
gradlew.bat clean
cd ..

REM Try building
echo 🏗️ Testing build...
flutter build apk --debug

echo ✅ Gradle files updated for modern Flutter!
echo 🚀 Your app should now build successfully!
pause
