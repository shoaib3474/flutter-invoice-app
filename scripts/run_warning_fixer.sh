#!/bin/bash

echo "🚀 Running comprehensive warning fixer..."

# Run the Dart warning fixer
dart lib/utils/warning_fixer.dart

# Run the shell script fixer
chmod +x scripts/fix_all_warnings.sh
./scripts/fix_all_warnings.sh

# Clean and analyze
flutter clean
flutter pub get
flutter analyze

echo "🎉 All warnings should be fixed now!"
