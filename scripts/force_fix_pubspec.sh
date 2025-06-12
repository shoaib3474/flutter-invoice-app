#!/bin/bash

echo "🚨 Force fixing pubspec.yaml..."

# Backup current pubspec
if [ -f pubspec.yaml ]; then
    cp pubspec.yaml pubspec.yaml.backup
fi

# Delete problematic files
rm -f pubspec.lock
rm -rf .dart_tool/
rm -rf build/

# Create new working pubspec.yaml
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
  flutter_localizations:
    sdk: flutter

  # Core dependencies
  cupertino_icons: ^1.0.6
  intl: ^0.19.0

  # State management
  provider: ^6.1.1

  # Navigation
  go_router: ^12.1.3

  # HTTP and API
  http: ^1.1.0
  dio: ^5.4.0

  # Database
  sqflite: ^2.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Storage and files
  path_provider: ^2.1.1
  path: ^1.8.3
  shared_preferences: ^2.2.2

  # Device info and permissions
  device_info_plus: ^10.1.0
  package_info_plus: ^8.0.0
  permission_handler: ^11.3.0

  # Firebase - Working versions
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8

  # UI and styling
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0

  # PDF and documents
  pdf: ^3.10.7
  printing: ^5.11.1

  # File handling
  file_picker: ^6.1.1
  share_plus: ^7.2.1

  # Utilities
  uuid: ^4.2.1
  crypto: ^3.0.3

  # Logging and debugging
  logger: ^2.0.2+1

  # Charts and graphs
  fl_chart: ^0.66.0

  # Date and time
  table_calendar: ^3.0.9

  # Connectivity
  connectivity_plus: ^5.0.2

  # Image handling
  image: ^4.1.3

  # QR codes
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1

  # Excel files
  excel: ^4.0.2

  # CSV files
  csv: ^6.0.0

  # Equatable for state management
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/sample_data/
    - assets/config/

  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
EOF

echo "✅ New pubspec.yaml created!"
echo "📦 Getting dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies resolved successfully!"
else
    echo "❌ Still having issues. Trying minimal version..."
    
    # Create minimal pubspec
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
    
    echo "📦 Trying with minimal dependencies..."
    flutter pub get
fi
