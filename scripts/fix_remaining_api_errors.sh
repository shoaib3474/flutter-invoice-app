#!/bin/bash

echo "🔧 Fixing remaining API errors..."

# Fix all remaining missing success parameters in gst_api_client.dart
sed -i 's/statusCode: 500,$/success: false,\n        statusCode: 500,/g' lib/api/gst_api_client.dart
sed -i 's/statusCode: response\.statusCode,$/success: false,\n        statusCode: response.statusCode,/g' lib/api/gst_api_client.dart

# Remove redundant statusCode: 500 arguments (keep only success: false)
sed -i 's/success: false,\n        statusCode: 500,$/success: false,/g' lib/api/gst_api_client.dart

# Add success: true to all successful responses that are missing it
sed -i '/message: '\''Success'\'',$/a\          success: true,' lib/api/gst_api_client.dart

# Fix save and submit methods
sed -i 's/statusCode: response\.statusCode,\n        success: response\.statusCode == 200,$/success: response.statusCode == 200,\n        statusCode: response.statusCode,/g' lib/api/gst_api_client.dart

echo "✅ API errors fixed!"

# Run flutter analyze to check for remaining issues
echo "🔍 Running flutter analyze..."
flutter analyze --no-fatal-infos
