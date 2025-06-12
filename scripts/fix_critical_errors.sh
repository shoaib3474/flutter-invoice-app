#!/bin/bash

echo "🔧 Fixing Critical Flutter Errors..."

# Fix super parameters
echo "📝 Fixing super parameters..."
find lib -name "*.dart" -type f -exec sed -i 's/Key? key/super.key/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/{Key? key}/{super.key}/g' {} \;

# Fix double literals
echo "📝 Fixing double literals..."
find lib -name "*.dart" -type f -exec sed -i 's/\.0)/)/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0,/,/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0;/;/g' {} \;

# Fix withOpacity to withValues
echo "📝 Fixing deprecated withOpacity..."
find lib -name "*.dart" -type f -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix print statements to debugPrint
echo "📝 Replacing print with debugPrint..."
find lib -name "*.dart" -type f -exec sed -i 's/print(/debugPrint(/g' {} \;

# Add missing imports
echo "📝 Adding missing imports..."
find lib -name "*.dart" -type f -exec sed -i '1i import '\''package:flutter/foundation.dart'\'';' {} \;

# Remove unnecessary imports
echo "📝 Cleaning up imports..."
find lib -name "*.dart" -type f -exec sed -i '/^import.*package:flutter\/services.dart/d' {} \;

echo "✅ Critical errors fixed!"
echo "🔍 Run 'flutter analyze' to check remaining issues"
