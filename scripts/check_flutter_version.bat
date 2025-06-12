@echo off
echo 🔍 Checking Flutter environment...

echo Flutter version:
flutter --version

echo.
echo Flutter doctor:
flutter doctor

echo.
echo Available channels:
flutter channel

echo.
echo Current pubspec.yaml content:
type pubspec.yaml

pause
