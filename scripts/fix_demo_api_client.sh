#!/bin/bash

echo "🔧 Fixing demo GST API client issues..."

# Generate missing model files
echo "📝 Generating missing model files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix linting issues
echo "🎯 Fixing linting issues..."
dart fix --apply

# Clean and get dependencies
echo "🧹 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run code generation again
echo "🔄 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for remaining issues
echo "🔍 Checking for remaining issues..."
flutter analyze lib/api/demo_gst_api_client.dart

echo "✅ Demo API client fixes completed!"
