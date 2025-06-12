#!/bin/bash

echo "🚨 Emergency dependency fix..."

# Remove problematic files
rm -f pubspec.lock
rm -rf .dart_tool/
rm -rf build/

# Use minimal working pubspec
cat > pubspec.yaml << 'EOF'
name: flutter_invoice_app
description: A comprehensive GST invoice management application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  provider: ^6.1.1
  http: ^1.1.0
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  pdf: ^3.10.7
  file_picker: ^6.1.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
EOF

echo "📦 Getting minimal dependencies..."
flutter pub get

echo "✅ Emergency fix complete! Now you can gradually add more dependencies."
