#!/bin/bash

echo "🔧 Fixing Firebase dependencies..."

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Remove pubspec.lock to force fresh resolution
echo "🗑️ Removing pubspec.lock..."
rm -f pubspec.lock

# Get dependencies with verbose output
echo "📥 Getting dependencies..."
flutter pub get --verbose

# Check for any remaining issues
echo "🔍 Checking for dependency conflicts..."
flutter pub deps

# Run code generation if needed
echo "🏗️ Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Firebase dependencies fixed!"
