#!/bin/bash

echo "🔧 Fixing remaining linting issues..."

# Fix super parameters
echo "📝 Fixing super parameters..."
find lib -name "*.dart" -type f -exec sed -i 's/const $$[A-Za-z_][A-Za-z0-9_]*$$({Key? key/const \1({super.key/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/$$[A-Za-z_][A-Za-z0-9_]*$$({Key? key/\1({super.key/g' {} \;

# Fix double literals
echo "📝 Fixing double literals..."
find lib -name "*.dart" -type f -exec sed -i 's/\.0)/)/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0,/,/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0;/;/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/\.0 /\ /g' {} \;

# Fix withOpacity to withValues
echo "📝 Fixing deprecated withOpacity..."
find lib -name "*.dart" -type f -exec sed -i 's/\.withOpacity($$[^)]*$$)/\.withValues(alpha: \1)/g' {} \;

# Fix const constructors
echo "📝 Adding const to constructors..."
find lib -name "*.dart" -type f -exec sed -i 's/SizedBox(height:/const SizedBox(height:/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/SizedBox(width:/const SizedBox(width:/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/Text(/const Text(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/Icon(/const Icon(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/CircularProgressIndicator()/const CircularProgressIndicator()/g' {} \;

echo "✅ Basic linting fixes applied!"
