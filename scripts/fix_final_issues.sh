#!/bin/bash

echo "🔧 Fixing final Flutter project issues..."

# Fix all print statements
echo "📝 Replacing print statements with debugPrint..."
find lib -name "*.dart" -type f -exec sed -i 's/print(/debugPrint(/g' {} \;

# Fix double literals
echo "🔢 Fixing unnecessary double literals..."
find lib -name "*.dart" -type f -exec sed -i 's/\.0)/)/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0,/,/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0;/;/g' {} \;

# Fix const constructors
echo "🏗️ Adding const to constructors where possible..."
find lib -name "*.dart" -type f -exec sed -i 's/EdgeInsets\.all(/const EdgeInsets.all(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/EdgeInsets\.symmetric(/const EdgeInsets.symmetric(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/BorderRadius\.circular(/const BorderRadius.circular(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/TextStyle(/const TextStyle(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/Icon(/const Icon(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/SizedBox(/const SizedBox(/g' {} \;

# Fix withOpacity deprecation
echo "🎨 Fixing withOpacity deprecation..."
find lib -name "*.dart" -type f -exec sed -i 's/\.withOpacity(/.withValues(alpha: /g' {} \;

# Run flutter pub get
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔄 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs || true

echo "✅ Final fixes completed!"
echo "🔍 Run 'flutter analyze' to check for remaining issues"
