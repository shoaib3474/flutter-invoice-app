#!/bin/bash

echo "🔧 Fixing Migration Test Suite..."

# Create missing directories
mkdir -p lib/tests
mkdir -p lib/models/migration

# Fix imports and dependencies
echo "📦 Checking dependencies..."

# Check if path_provider is in pubspec.yaml
if ! grep -q "path_provider:" pubspec.yaml; then
    echo "Adding path_provider dependency..."
    # Add to dependencies section
    sed -i '/dependencies:/a\  path_provider: ^2.1.1' pubspec.yaml
fi

# Run pub get
echo "📥 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔄 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for syntax errors
echo "🔍 Checking for syntax errors..."
flutter analyze lib/tests/migration_test_suite.dart

echo "✅ Migration test suite fixed!"
echo "📋 To run tests:"
echo "   dart lib/tests/migration_test_suite.dart"
