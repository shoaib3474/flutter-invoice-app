#!/bin/bash

echo "🔧 Fixing version conflicts and dependencies..."

# Clean everything
echo "🧹 Cleaning project..."
flutter clean
rm -f pubspec.lock
rm -rf .dart_tool/

# Check Flutter version
echo "📱 Checking Flutter version..."
flutter --version

# Get dependencies with verbose output
echo "📦 Getting dependencies..."
flutter pub get --verbose

# If still failing, try with specific Flutter channel
if [ $? -ne 0 ]; then
    echo "⚠️ Switching to stable channel..."
    flutter channel stable
    flutter upgrade
    flutter pub get
fi

# Generate code
echo "🔨 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for issues
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Version conflicts fixed!"
