#!/bin/bash

echo "🔧 Fixing Flutter Dependencies..."
echo "================================"

# Clean previous builds
echo "1. Cleaning previous builds..."
flutter clean

# Remove pubspec.lock to force fresh resolution
echo "2. Removing pubspec.lock..."
rm -f pubspec.lock

# Clear pub cache for problematic packages
echo "3. Clearing pub cache..."
flutter pub cache clean

# Get dependencies with verbose output
echo "4. Getting dependencies..."
flutter pub get --verbose

# Verify dependencies
echo "5. Verifying dependencies..."
flutter pub deps

echo ""
echo "✅ Dependencies fixed successfully!"
echo "You can now run: flutter build apk --release"
