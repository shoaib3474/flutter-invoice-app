@echo off
echo Building Flutter Invoice App...

echo Cleaning previous builds...
flutter clean
cd android
call gradlew clean
cd ..

echo Getting dependencies...
flutter pub get

echo Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo Building APK...
flutter build apk --release --split-per-abi

echo Building App Bundle...
flutter build appbundle --release

echo Build completed!
echo APK files are located in: build\app\outputs\flutter-apk\
echo App Bundle is located in: build\app\outputs\bundle\release\

set /p install="Do you want to install the APK on a connected device? (y/n): "
if /i "%install%"=="y" (
    echo Installing APK...
    flutter install --release
)

pause
