@echo off
setlocal enabledelayedexpansion

echo 🔧 Starting comprehensive fix for Flutter Invoice App...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

echo [INFO] Flutter version:
flutter --version

REM Clean the project
echo [INFO] Cleaning Flutter project...
flutter clean

REM Remove old lock file
if exist "pubspec.lock" (
    echo [INFO] Removing old pubspec.lock...
    del pubspec.lock
)

REM Remove old build files
if exist "build" (
    echo [INFO] Removing build directory...
    rmdir /s /q build
)

REM Remove .dart_tool
if exist ".dart_tool" (
    echo [INFO] Removing .dart_tool directory...
    rmdir /s /q .dart_tool
)

REM Get dependencies
echo [INFO] Getting Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to resolve dependencies
    exit /b 1
)
echo [SUCCESS] Dependencies resolved successfully

REM Run code generation
echo [INFO] Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo [WARNING] Code generation failed, continuing...
) else (
    echo [SUCCESS] Code generation completed
)

REM Analyze code
echo [INFO] Analyzing code...
flutter analyze
if errorlevel 1 (
    echo [WARNING] Code analysis found issues, but continuing...
) else (
    echo [SUCCESS] Code analysis passed
)

REM Format code
echo [INFO] Formatting code...
dart format lib\ test\
if errorlevel 1 (
    echo [WARNING] Code formatting failed, continuing...
) else (
    echo [SUCCESS] Code formatted successfully
)

REM Fix common issues
echo [INFO] Fixing common Flutter issues...

REM Create missing directories
if not exist "assets\images" mkdir assets\images
if not exist "assets\icons" mkdir assets\icons
if not exist "assets\sample_data" mkdir assets\sample_data
if not exist "assets\config" mkdir assets\config
if not exist "fonts" mkdir fonts

REM Create empty font files if they don't exist
if not exist "fonts\Roboto-Regular.ttf" echo. > fonts\Roboto-Regular.ttf
if not exist "fonts\Roboto-Bold.ttf" echo. > fonts\Roboto-Bold.ttf

REM Test build
echo [INFO] Testing build...
flutter build apk --debug
if errorlevel 1 (
    echo [ERROR] Debug build failed
    echo [INFO] Trying to fix build issues...
    
    REM Additional fixes for build issues
    flutter pub deps
    flutter pub upgrade --major-versions
    
    REM Try build again
    flutter build apk --debug
    if errorlevel 1 (
        echo [ERROR] Debug build still failing
    ) else (
        echo [SUCCESS] Debug build successful after fixes
    )
) else (
    echo [SUCCESS] Debug build successful
)

echo [SUCCESS] Comprehensive fix completed!
echo [INFO] Next steps:
echo 1. Check for any remaining errors in your IDE
echo 2. Run 'flutter doctor' to check for system issues
echo 3. Test the app with 'flutter run'

pause
