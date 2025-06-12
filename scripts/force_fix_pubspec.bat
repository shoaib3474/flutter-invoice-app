@echo off
echo 🚨 Force fixing pubspec.yaml...

REM Backup current pubspec
if exist pubspec.yaml copy pubspec.yaml pubspec.yaml.backup

REM Delete problematic files
if exist pubspec.lock del pubspec.lock
if exist .dart_tool rmdir /s /q .dart_tool
if exist build rmdir /s /q build

REM Create new working pubspec.yaml
(
echo name: flutter_invoice_app
echo description: A comprehensive GST invoice management application
echo publish_to: 'none'
echo version: 1.0.0+1
echo.
echo environment:
echo   sdk: '>=3.0.0 ^<4.0.0'
echo.
echo dependencies:
echo   flutter:
echo     sdk: flutter
echo   flutter_localizations:
echo     sdk: flutter
echo.
echo   # Core dependencies
echo   cupertino_icons: ^1.0.6
echo   intl: ^0.19.0
echo.
echo   # State management
echo   provider: ^6.1.1
echo.
echo   # Navigation
echo   go_router: ^12.1.3
echo.
echo   # HTTP and API
echo   http: ^1.1.0
echo   dio: ^5.4.0
echo.
echo   # Database
echo   sqflite: ^2.3.0
echo   hive: ^2.2.3
echo   hive_flutter: ^1.1.0
echo.
echo   # Storage and files
echo   path_provider: ^2.1.1
echo   path: ^1.8.3
echo   shared_preferences: ^2.2.2
echo.
echo   # Device info and permissions
echo   device_info_plus: ^10.1.0
echo   package_info_plus: ^8.0.0
echo   permission_handler: ^11.3.0
echo.
echo   # Firebase - Working versions
echo   firebase_core: ^2.24.2
echo   firebase_auth: ^4.15.3
echo   firebase_firestore: ^4.13.6
echo   firebase_storage: ^11.5.6
echo   firebase_analytics: ^10.7.4
echo   firebase_crashlytics: ^3.4.8
echo.
echo   # UI and styling
echo   flutter_svg: ^2.0.9
echo   cached_network_image: ^3.3.0
echo.
echo   # PDF and documents
echo   pdf: ^3.10.7
echo   printing: ^5.11.1
echo.
echo   # File handling
echo   file_picker: ^6.1.1
echo   share_plus: ^7.2.1
echo.
echo   # Utilities
echo   uuid: ^4.2.1
echo   crypto: ^3.0.3
echo.
echo   # Logging and debugging
echo   logger: ^2.0.2+1
echo.
echo   # Charts and graphs
echo   fl_chart: ^0.66.0
echo.
echo   # Date and time
echo   table_calendar: ^3.0.9
echo.
echo   # Connectivity
echo   connectivity_plus: ^5.0.2
echo.
echo   # Image handling
echo   image: ^4.1.3
echo.
echo   # QR codes
echo   qr_flutter: ^4.1.0
echo   qr_code_scanner: ^1.0.1
echo.
echo   # Excel files
echo   excel: ^4.0.2
echo.
echo   # CSV files
echo   csv: ^6.0.0
echo.
echo   # Equatable for state management
echo   equatable: ^2.0.5
echo.
echo dev_dependencies:
echo   flutter_test:
echo     sdk: flutter
echo   flutter_lints: ^3.0.0
echo   build_runner: ^2.4.7
echo   hive_generator: ^2.0.1
echo   json_annotation: ^4.8.1
echo   json_serializable: ^6.7.1
echo.
echo flutter:
echo   uses-material-design: true
echo   generate: true
echo.
echo   assets:
echo     - assets/images/
echo     - assets/icons/
echo     - assets/sample_data/
echo     - assets/config/
echo.
echo   fonts:
echo     - family: Roboto
echo       fonts:
echo         - asset: fonts/Roboto-Regular.ttf
echo         - asset: fonts/Roboto-Bold.ttf
echo           weight: 700
) > pubspec.yaml

echo ✅ New pubspec.yaml created!
echo 📦 Getting dependencies...
flutter pub get

if %errorlevel% equ 0 (
    echo ✅ Dependencies resolved successfully!
) else (
    echo ❌ Still having issues. Trying minimal version...
    
    REM Create minimal pubspec
    (
    echo name: flutter_invoice_app
    echo description: A comprehensive GST invoice management application
    echo publish_to: 'none'
    echo version: 1.0.0+1
    echo.
    echo environment:
    echo   sdk: '>=3.0.0 ^<4.0.0'
    echo.
    echo dependencies:
    echo   flutter:
    echo     sdk: flutter
    echo   cupertino_icons: ^1.0.6
    echo   provider: ^6.1.1
    echo   http: ^1.1.0
    echo   sqflite: ^2.3.0
    echo   path_provider: ^2.1.1
    echo   shared_preferences: ^2.2.2
    echo   pdf: ^3.10.7
    echo   file_picker: ^6.1.1
    echo   uuid: ^4.2.1
    echo.
    echo dev_dependencies:
    echo   flutter_test:
    echo     sdk: flutter
    echo   flutter_lints: ^3.0.0
    echo.
    echo flutter:
    echo   uses-material-design: true
    echo   assets:
    echo     - assets/images/
    echo     - assets/icons/
    ) > pubspec.yaml
    
    echo 📦 Trying with minimal dependencies...
    flutter pub get
)

pause
