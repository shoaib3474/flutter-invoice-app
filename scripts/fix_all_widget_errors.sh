#!/bin/bash

echo "🔧 Fixing all widget errors..."

# Add missing dependencies to pubspec.yaml
echo "📦 Adding missing dependencies..."
flutter pub add provider
flutter pub add qr_flutter
flutter pub add razorpay_flutter

# Apply automated fixes
echo "🛠️ Applying automated fixes..."
dart fix --apply

# Format all Dart files
echo "📝 Formatting code..."
dart format lib/ --set-exit-if-changed

# Run analysis
echo "🔍 Running analysis..."
flutter analyze

echo "✅ All fixes applied!"
