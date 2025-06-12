#!/bin/bash

echo "🔧 Fixing API errors and warnings..."

# Fix import ordering and unused imports
echo "📦 Cleaning up imports..."

# Remove unused imports from demo_gst_api_client.dart
sed -i '/import.*dio/d' lib/api/demo_gst_api_client.dart
sed -i '/import.*gstr2a_model/d' lib/api/demo_gst_api_client.dart
sed -i '/import.*gstr2b_model/d' lib/api/demo_gst_api_client.dart
sed -i '/import.*gstr4_model/d' lib/api/demo_gst_api_client.dart

# Remove dart:convert from demo_gstr1_api_service.dart
sed -i '/import.*dart:convert/d' lib/api/demo/demo_gstr1_api_service.dart

# Fix nullable operations in demo_gst_api_client.dart
echo "🔧 Fixing nullable operations..."
sed -i 's/sum + (item\.taxableValueInSource3 ?? 0)/sum + (item.taxableValueInSource3 ?? 0.0)/g' lib/api/demo_gst_api_client.dart
sed -i 's/sum + (item\.igstInSource3 ?? 0) + (item\.cgstInSource3 ?? 0) + (item\.sgstInSource3 ?? 0)/sum + (item.igstInSource3 ?? 0.0) + (item.cgstInSource3 ?? 0.0) + (item.sgstInSource3 ?? 0.0)/g' lib/api/demo_gst_api_client.dart

# Remove unnecessary non-null assertions
echo "🔧 Removing unnecessary non-null assertions..."
sed -i 's/taxableValueInSource3!/taxableValueInSource3/g' lib/api/demo_gst_api_client.dart
sed -i 's/igstInSource3!/igstInSource3/g' lib/api/demo_gst_api_client.dart
sed -i 's/cgstInSource3!/cgstInSource3/g' lib/api/demo_gst_api_client.dart
sed -i 's/sgstInSource3!/sgstInSource3/g' lib/api/demo_gst_api_client.dart

echo "✅ API errors fixed!"

# Run flutter analyze to check results
echo "🔍 Running analysis..."
flutter analyze --no-fatal-infos
