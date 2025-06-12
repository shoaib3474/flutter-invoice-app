#!/bin/bash

echo "🔧 Starting comprehensive error fix..."

# Clean everything
echo "🧹 Cleaning project..."
flutter clean
rm -rf .dart_tool
rm -f pubspec.lock

# Clear pub cache
echo "📦 Clearing pub cache..."
flutter pub cache clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Generate missing files
echo "⚙️ Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze for errors
echo "🔍 Analyzing code..."
flutter analyze

# Check for specific issues
echo "🚨 Checking for common issues..."

# Fix import issues
find lib -name "*.dart" -exec sed -i 's/import.*api_response\.g\.dart.*;//g' {} \;

# Fix missing exports
echo "📤 Adding missing exports..."

# Create barrel files for better imports
cat > lib/models/models.dart << 'EOF'
// API Models
export 'api/api_response.dart';

// GST Returns Models
export 'gst_returns/gstr1_model.dart';
export 'gst_returns/gstr3b_model.dart';
export 'gst_returns/gstr4_model.dart';
export 'gst_returns/gstr9_model.dart';
export 'gst_returns/gstr9c_model.dart';
export 'gst_returns/gst_summary_models.dart';

// Other models
export 'invoice/invoice_model.dart';
export 'customer/customer_model.dart';
export 'product/product_model.dart';
EOF

# Create services barrel file
cat > lib/services/services.dart << 'EOF'
// Core Services
export 'error_logger_service.dart';
export 'analytics/analytics_service.dart';

// GST Services
export 'gstr1_service.dart';
export 'gstr3b_service.dart';
export 'gstr4_service.dart';
export 'gstr9_service.dart';
export 'gstr9c_service.dart';

// Other services
export 'auth/auth_service.dart';
export 'invoice/invoice_service.dart';
EOF

echo "✅ Error fix completed!"
echo "🚀 Try building again: flutter build apk --release"
