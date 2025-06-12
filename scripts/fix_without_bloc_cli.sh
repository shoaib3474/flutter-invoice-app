... shell ...
#!/bin/bash

echo "🔧 Fixing Flutter project without external CLI dependencies..."

# Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Generate code without using bloc CLI
echo "🏗️ Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix common linting issues
echo "🔍 Fixing linting issues..."

# Fix const constructors
find lib -name "*.dart" -type f -exec sed -i 's/class $$[A-Za-z]*$$($$[^)]*$$) {/class \1(\2) {/g' {} \;

# Fix missing const keywords for simple constructors
find lib -name "*.dart" -type f -exec sed -i 's/^$$[[:space:]]*$$$$[A-Za-z]*$$($$[^)]*$$);$/\1const \2(\3);/g' {} \;

# Fix trailing commas
find lib -name "*.dart" -type f -exec sed -i 's/,$$[[:space:]]*$$)/\1)/g' {} \;

# Run dart fix
echo "🛠️ Running dart fix..."
dart fix --apply

# Format code
echo "💅 Formatting code..."
dart format lib/ --fix

# Analyze for remaining issues
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Fix completed! Check the analysis results above."
