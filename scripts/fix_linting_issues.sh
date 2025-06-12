#!/bin/bash

echo "🔧 Fixing Flutter Linting Issues..."

# Clean the project
echo "1. Cleaning project..."
flutter clean

# Get dependencies
echo "2. Getting dependencies..."
flutter pub get

# Run dart fix to auto-fix issues
echo "3. Running dart fix..."
dart fix --apply

# Format all Dart files
echo "4. Formatting code..."
dart format lib/ --set-exit-if-changed

# Run custom fixes for common issues
echo "5. Applying custom fixes..."

# Fix double literals
find lib/ -name "*.dart" -exec sed -i 's/\.0)/)/g' {} \;

# Fix import statements
find lib/ -name "*.dart" -exec sed -i 's/package:invoice_app\//package:flutter_invoice_app\//g' {} \;

# Run analysis
echo "6. Running analysis..."
flutter analyze

echo "✅ Linting fixes complete!"
echo "Run 'flutter build apk --release' to test the build."
