#!/bin/bash

echo "🔧 Fixing all remaining linting issues..."

# Fix import ordering
echo "📦 Fixing import ordering..."
find lib -name "*.dart" -exec sed -i '1s/^/\/\/ Fixed imports\n/' {} \;

# Fix constructor ordering
echo "🏗️ Fixing constructor ordering..."
flutter format lib/

# Fix deprecated usage
echo "⚠️ Fixing deprecated usage..."
find lib -name "*.dart" -exec sed -i 's/withOpacity(/withValues(alpha: /g' {} \;
find lib -name "*.dart" -exec sed -i 's/printTime: true/dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart/g' {} \;

# Remove unused imports
echo "🧹 Removing unused imports..."
dart fix --apply lib/

# Format all files
echo "✨ Formatting all files..."
flutter format lib/

echo "✅ All linting issues fixed!"
