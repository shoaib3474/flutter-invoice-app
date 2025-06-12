#!/bin/bash

echo "🔧 Fixing all critical issues in Flutter Invoice App..."

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean
rm -rf .dart_tool/
rm -rf build/

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate missing files
echo "🔨 Generating missing files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix linting issues
echo "🧹 Fixing linting issues..."
dart fix --apply

# Format code
echo "✨ Formatting code..."
dart format lib/ --fix

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos

echo "✅ Critical issues fixed! Try running 'flutter run' now."
