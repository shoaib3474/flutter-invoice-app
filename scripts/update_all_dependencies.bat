@echo off
echo 🔄 Updating all dependencies to latest versions...

REM Backup current pubspec.yaml
copy pubspec.yaml pubspec.yaml.backup

REM Update dependencies
echo 📦 Updating dependencies...
flutter pub upgrade

REM Check outdated packages
echo 📊 Checking for outdated packages...
flutter pub outdated

REM Fix any version conflicts
echo 🔧 Resolving version conflicts...
flutter pub get

echo ✅ All dependencies updated!
pause
