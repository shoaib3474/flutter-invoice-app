#!/bin/bash

echo "🔧 Fixing all linting issues in Flutter Invoice App..."

# 1. Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# 2. Fix double literals to int literals
echo "🔢 Fixing double literals..."
find lib -name "*.dart" -exec sed -i 's/\.0)/)/g' {} \;
find lib -name "*.dart" -exec sed -i 's/: 0\.0/: 0/g' {} \;
find lib -name "*.dart" -exec sed -i 's/= 0\.0/= 0/g' {} \;
find lib -name "*.dart" -exec sed -i 's/(0\.0/(0/g' {} \;

# 3. Fix const constructors
echo "🏗️ Fixing const constructors..."
find lib -name "*.dart" -exec sed -i 's/Text(/const Text(/g' {} \;
find lib -name "*.dart" -exec sed -i 's/Icon(/const Icon(/g' {} \;
find lib -name "*.dart" -exec sed -i 's/SizedBox(/const SizedBox(/g' {} \;
find lib -name "*.dart" -exec sed -i 's/Padding(/const Padding(/g' {} \;

# 4. Fix withOpacity to withValues
echo "🎨 Fixing deprecated withOpacity..."
find lib -name "*.dart" -exec sed -i 's/\.withOpacity(/\.withValues(alpha: /g' {} \;

# 5. Fix super parameters
echo "🔧 Fixing super parameters..."
find lib -name "*.dart" -exec sed -i 's/{Key? key}/{super.key/g' {} \;
find lib -name "*.dart" -exec sed -i 's/: super(key: key)//g' {} \;

# 6. Remove unused imports
echo "🧹 Removing unused imports..."
dart fix --apply

# 7. Format code
echo "✨ Formatting code..."
dart format lib/ --fix

# 8. Generate missing files
echo "🔨 Generating missing files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ All linting issues fixed!"
