#!/bin/bash
echo "Fixing analyzer errors..."

echo "Cleaning project..."
flutter clean

echo "Deleting .dart_tool directory..."
rm -rf .dart_tool

echo "Deleting pubspec.lock..."
rm -f pubspec.lock

echo "Getting dependencies..."
flutter pub get

echo "Creating missing directories..."
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/sample_data
mkdir -p assets/config
mkdir -p fonts

echo "Creating placeholder files..."
touch assets/images/.gitkeep
touch assets/icons/.gitkeep
touch assets/sample_data/.gitkeep
touch assets/config/.gitkeep

echo "Fixing syntax errors in Dart files..."
flutter format .

echo "Running flutter analyze to find errors..."
flutter analyze 2>&1 | tee flutter-errors.txt

echo "Done!"
echo "Check flutter-errors.txt for any remaining issues."
