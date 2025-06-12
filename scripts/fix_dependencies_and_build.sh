#!/bin/bash

echo "🔧 Fixing Flutter dependencies and build issues..."

# 1. Clean everything
echo "📦 Cleaning project..."
flutter clean
rm -rf pubspec.lock
rm -rf android/.gradle
rm -rf android/app/build
rm -rf build/

# 2. Create missing asset directories
echo "📁 Creating asset directories..."
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/config
mkdir -p assets/sample_data

# 3. Add placeholder files to prevent asset errors
touch assets/images/.gitkeep
touch assets/icons/.gitkeep
touch assets/config/.gitkeep
touch assets/sample_data/.gitkeep

# 4. Get dependencies with major version upgrades
echo "📦 Getting dependencies..."
flutter pub get
flutter pub upgrade --major-versions

# 5. Generate code
echo "🔨 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 6. Fix Gradle wrapper permissions
echo "🔧 Fixing Gradle permissions..."
chmod +x android/gradlew

# 7. Clean and rebuild Android
echo "🏗️ Cleaning Android build..."
cd android
./gradlew clean
cd ..

# 8. Analyze for remaining issues
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos

# 9. Try building
echo "🚀 Building APK..."
flutter build apk --release --verbose

echo "✅ Build process completed!"
