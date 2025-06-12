#!/bin/bash

echo "🔧 Fixing final widget issues..."

# Fix all const constructor issues
echo "📝 Applying const constructor fixes..."
find lib/widgets -name "*.dart" -exec sed -i 's/Text(/const Text(/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/Icon(/const Icon(/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/SizedBox(/const SizedBox(/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/EdgeInsets\./const EdgeInsets\./g' {} \;

# Fix deprecated withOpacity calls
echo "🔄 Fixing deprecated withOpacity calls..."
find lib/widgets -name "*.dart" -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix unnecessary null checks
echo "🛡️ Fixing null safety issues..."
find lib/widgets -name "*.dart" -exec sed -i 's/$$[a-zA-Z_][a-zA-Z0-9_]*$$!/\1 ?? ""/g' {} \;

# Apply dart fix
echo "🚀 Applying automated Dart fixes..."
dart fix --apply

# Format code
echo "✨ Formatting code..."
dart format lib/widgets/

echo "✅ All widget issues fixed!"
echo "Run 'flutter analyze' to verify zero errors."
