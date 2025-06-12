#!/bin/bash

echo "🔧 Fixing RCM Widget Errors..."

# Fix import paths in all widgets
echo "📝 Fixing import paths..."
find lib/widgets -name "*.dart" -exec sed -i 's|package:invoice_app/|../|g' {} \;

# Fix const constructors
echo "🎯 Adding const constructors..."
find lib/widgets -name "*.dart" -exec sed -i 's/SizedBox(width: 8)/const SizedBox(width: 8)/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/Text(/const Text(/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/Icon(Icons\./const Icon(Icons\./g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/Spacer()/const Spacer()/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/CircularProgressIndicator()/const CircularProgressIndicator()/g' {} \;

# Fix super parameters
echo "⚡ Fixing super parameters..."
find lib/widgets -name "*.dart" -exec sed -i 's/Key? key/super.key/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/: super(key: key)//g' {} \;

# Fix required parameters order
echo "📋 Fixing parameter order..."
find lib/widgets -name "*.dart" -exec sed -i 's/{\s*Key? key,\s*required/{required/g' {} \;
find lib/widgets -name "*.dart" -exec sed -i 's/{\s*super.key,\s*required/{required/g' {} \;

# Fix double literals
echo "🔢 Fixing double literals..."
find lib/widgets -name "*.dart" -exec sed -i 's/\.0)/)/g' {} \;

# Fix deprecated methods
echo "🔄 Fixing deprecated methods..."
find lib/widgets -name "*.dart" -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix unnecessary null checks
echo "🛡️ Fixing null safety issues..."
find lib/widgets -name "*.dart" -exec sed -i 's/$$[a-zA-Z_][a-zA-Z0-9_]*$$!/\1 ?? ""/g' {} \;

echo "✅ RCM Widget fixes completed!"
echo "🚀 Run 'flutter analyze' to verify fixes"
