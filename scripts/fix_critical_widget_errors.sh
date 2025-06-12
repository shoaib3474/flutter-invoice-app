#!/bin/bash

echo "🔧 Fixing critical widget errors..."

# Fix constructor ordering issues
echo "📝 Fixing constructor ordering..."
find lib/widgets -name "*.dart" -exec sed -i 's/const $$[A-Z][a-zA-Z]*$$({/const \1({/g' {} \;

# Fix deprecated withOpacity usage
echo "🔄 Fixing deprecated withOpacity usage..."
find lib -name "*.dart" -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix print statements
echo "🖨️ Replacing print statements..."
find lib -name "*.dart" -exec sed -i 's/print(/debugPrint(/g' {} \;

# Fix const constructor issues
echo "⚡ Adding const constructors..."
find lib/widgets -name "*.dart" -exec sed -i 's/SizedBox(height: $$[0-9.]*$$)/const SizedBox(height: \1)/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/SizedBox(width: $$[0-9.]*$$)/const SizedBox(width: \1)/g' {} \;

# Fix parameter ordering
echo "📋 Fixing parameter ordering..."
find lib/widgets -name "*.dart" -exec sed -i 's/required this\.$$[^,]*$$,\s*this\.$$[^,]*$$,/this.\2, required this.\1,/g' {} \;

echo "✅ Critical widget errors fixed!"
