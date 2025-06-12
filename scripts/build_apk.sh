#!/bin/bash

# Build script for Flutter Invoice App
echo "Building Flutter Invoice App..."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
cd android && ./gradlew clean && cd ..

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Generate code if needed
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build APK
echo "Building APK..."
flutter build apk --release --split-per-abi

# Build App Bundle
echo "Building App Bundle..."
flutter build appbundle --release

echo "Build completed!"
echo "APK files are located in: build/app/outputs/flutter-apk/"
echo "App Bundle is located in: build/app/outputs/bundle/release/"

# Optional: Install on connected device
read -p "Do you want to install the APK on a connected device? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installing APK..."
    flutter install --release
fi
