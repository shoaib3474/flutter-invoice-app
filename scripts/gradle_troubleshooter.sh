#!/bin/bash

echo "🔧 Android Gradle Troubleshooter"
echo "================================"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in Flutter project root directory"
    exit 1
fi

# Check Android directory
if [ ! -d "android" ]; then
    echo "❌ Error: Android directory not found"
    echo "💡 Run: flutter create --platforms android ."
    exit 1
fi

cd android

# Check for required files
echo "📋 Checking Android project structure..."

if [ ! -f "build.gradle" ]; then
    echo "❌ Missing: android/build.gradle"
    echo "💡 Recreating Android project..."
    cd ..
    flutter create --platforms android .
    cd android
fi

if [ ! -f "settings.gradle" ]; then
    echo "❌ Missing: android/settings.gradle"
    echo "💡 This will be fixed automatically"
fi

if [ ! -f "app/build.gradle" ]; then
    echo "❌ Missing: android/app/build.gradle"
    echo "💡 Recreating Android project..."
    cd ..
    flutter create --platforms android .
    cd android
fi

# Clean and rebuild
echo "🧹 Cleaning Gradle cache..."
./gradlew clean

echo "🔍 Checking available tasks..."
./gradlew tasks --all

echo "✅ Gradle troubleshooting complete!"
echo "🚀 Try building now: flutter build apk"

cd ..
