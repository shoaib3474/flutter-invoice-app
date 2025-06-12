#!/bin/bash

echo "🚀 Quick dependency fix..."

# Update pubspec.yaml dependencies to latest compatible versions
echo "📦 Updating dependencies..."

# Clean everything
flutter clean
rm -rf .dart_tool/
rm -rf build/

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Run code generation
echo "🏗️ Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix and format
dart fix --apply
dart format lib/ --fix

# Quick analysis
flutter analyze --no-fatal-infos

echo "✅ Quick fix completed!"
