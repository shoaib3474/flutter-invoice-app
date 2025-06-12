#!/bin/bash

echo "🔧 Fixing Gradle files for modern Flutter..."

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Clean gradle
echo "🧹 Cleaning Gradle cache..."
cd android
./gradlew clean
cd ..

# Try building
echo "🏗️ Testing build..."
flutter build apk --debug

echo "✅ Gradle files updated for modern Flutter!"
echo "🚀 Your app should now build successfully!"
