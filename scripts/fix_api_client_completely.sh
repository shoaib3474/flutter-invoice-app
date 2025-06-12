#!/bin/bash

echo "🔧 Fixing API Client Issues Completely..."

# Remove the problematic retrofit-based API client
if [ -f "lib/api/gst_api_client.dart" ]; then
    echo "📁 Backing up original gst_api_client.dart..."
    mv lib/api/gst_api_client.dart lib/api/gst_api_client.dart.backup
fi

# Update all files that import the old API client to use the new one
echo "🔄 Updating import statements..."

# Find and replace imports in all Dart files
find lib -name "*.dart" -type f -exec sed -i 's|import.*gst_api_client\.dart.*|import '\''../api/simple_gst_api_client.dart'\'';|g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's|GstApiClient|SimpleGstApiClient|g' {} \;

# Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run code generation for other files that might need it
echo "🔨 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ API Client fix completed!"
echo "📝 The old gst_api_client.dart has been backed up as gst_api_client.dart.backup"
echo "🚀 You can now run: flutter analyze"
