#!/bin/bash

echo "🔧 Starting Comprehensive Const & Null Safety Fix..."
echo "=================================================="

# Create backup
echo "📦 Creating backup..."
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# Fix const constructors in all files
echo "✨ Fixing const constructors..."

# Fix Text widgets
find lib -name "*.dart" -type f -exec sed -i 's/Text(/const Text(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/const const Text(/const Text(/g' {} \;

# Fix SizedBox widgets
find lib -name "*.dart" -type f -exec sed -i 's/SizedBox(/const SizedBox(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/const const SizedBox(/const SizedBox(/g' {} \;

# Fix Icon widgets
find lib -name "*.dart" -type f -exec sed -i 's/Icon(/const Icon(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/const const Icon(/const Icon(/g' {} \;

# Fix Divider widgets
find lib -name "*.dart" -type f -exec sed -i 's/Divider(/const Divider(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/const const Divider(/const Divider(/g' {} \;

# Fix EdgeInsets
find lib -name "*.dart" -type f -exec sed -i 's/EdgeInsets\./const EdgeInsets\./g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/const const EdgeInsets\./const EdgeInsets\./g' {} \;

echo "🛡️ Fixing null safety issues..."

# Run dart fix for automated fixes
flutter pub get
dart fix --apply

echo "🧹 Cleaning up formatting..."
dart format lib/

echo "🔍 Running analysis..."
flutter analyze

echo "✅ Const & Null Safety Fix Complete!"
echo "Run 'flutter build apk --release' to test the build."
