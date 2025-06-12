@echo off
echo Fixing analyzer errors...

echo Cleaning project...
flutter clean

echo Deleting .dart_tool directory...
if exist .dart_tool rmdir /s /q .dart_tool

echo Deleting pubspec.lock...
if exist pubspec.lock del pubspec.lock

echo Getting dependencies...
flutter pub get

echo Creating missing directories...
if not exist assets mkdir assets
if not exist assets\images mkdir assets\images
if not exist assets\icons mkdir assets\icons
if not exist assets\sample_data mkdir assets\sample_data
if not exist assets\config mkdir assets\config
if not exist fonts mkdir fonts

echo Creating placeholder files...
echo // Placeholder > assets\images\.gitkeep
echo // Placeholder > assets\icons\.gitkeep
echo // Placeholder > assets\sample_data\.gitkeep
echo // Placeholder > assets\config\.gitkeep

echo Fixing syntax errors in Dart files...
flutter format .

echo Running flutter analyze to find errors...
flutter analyze 2>&1 | Tee-Object -FilePath flutter-errors.txt

echo Done!
echo Check flutter-errors.txt for any remaining issues.
