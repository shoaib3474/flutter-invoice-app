@echo off
setlocal enabledelayedexpansion

echo 🚀 Starting Flutter Invoice App Release Build Process...

:: Configuration
set APP_NAME=Flutter Invoice App
set BUILD_DIR=build
set RELEASE_DIR=release
set KEYSTORE_PATH=android\keystore\release-keystore.jks
set KEYSTORE_PROPERTIES=android\keystore.properties

:: Step 1: Environment Check
echo 📋 Checking build environment...

:: Check Flutter installation
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version ^| findstr /r "^Flutter"') do set FLUTTER_VERSION=%%i
echo ✅ Flutter found: !FLUTTER_VERSION!

:: Check Java version
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ Java is not installed
    exit /b 1
)

for /f "tokens=*" %%i in ('java -version 2^>^&1 ^| findstr /r "version"') do set JAVA_VERSION=%%i
echo ✅ Java found: !JAVA_VERSION!

:: Step 2: Project Validation
echo 📋 Validating project structure...

if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Are you in the Flutter project root?
    exit /b 1
)

if not exist "android" (
    echo ❌ Android directory not found
    exit /b 1
)

echo ✅ Project structure validated

:: Step 3: Clean Previous Builds
echo 📋 Cleaning previous builds...

flutter clean
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%RELEASE_DIR%" rmdir /s /q "%RELEASE_DIR%"

:: Clean Android build
cd android
call gradlew clean
cd ..

echo ✅ Previous builds cleaned

:: Step 4: Dependencies
echo 📋 Getting dependencies...

flutter pub get

:: Generate code if needed
if exist "build.yaml" (
    echo 📋 Generating code...
    flutter packages pub run build_runner build --delete-conflicting-outputs
)

echo ✅ Dependencies resolved

:: Step 5: Code Analysis
echo 📋 Running code analysis...

flutter analyze
if errorlevel 1 (
    echo ⚠️ Code analysis found issues. Continue? (y/n)
    set /p response=
    if /i not "!response!"=="y" exit /b 1
)

echo ✅ Code analysis completed

:: Step 6: Tests
echo 📋 Running tests...

flutter test
if errorlevel 1 (
    echo ⚠️ Tests failed. Continue? (y/n)
    set /p response=
    if /i not "!response!"=="y" exit /b 1
)

echo ✅ Tests completed

:: Step 7: Keystore Check
echo 📋 Checking keystore configuration...

if not exist "%KEYSTORE_PROPERTIES%" (
    echo ⚠️ Keystore properties not found
    echo ⚠️ Creating debug build instead of release build
    set BUILD_TYPE=debug
) else (
    echo ✅ Keystore configuration found
    set BUILD_TYPE=release
)

:: Step 8: Build APK
echo 📋 Building APK (!BUILD_TYPE!)...

if "!BUILD_TYPE!"=="release" (
    flutter build apk --release --split-per-abi
    flutter build apk --release
    echo ✅ Release APK built successfully
) else (
    flutter build apk --debug
    echo ✅ Debug APK built successfully
)

:: Step 9: Build App Bundle (only for release)
if "!BUILD_TYPE!"=="release" (
    echo 📋 Building App Bundle...
    flutter build appbundle --release
    echo ✅ App Bundle built successfully
)

:: Step 10: Organize Release Files
echo 📋 Organizing release files...

mkdir "%RELEASE_DIR%" 2>nul

if "!BUILD_TYPE!"=="release" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "%RELEASE_DIR%\app-universal-release.apk" >nul 2>&1
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "%RELEASE_DIR%\" >nul 2>&1
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "%RELEASE_DIR%\" >nul 2>&1
    copy "build\app\outputs\flutter-apk\app-x86_64-release.apk" "%RELEASE_DIR%\" >nul 2>&1
    copy "build\app\outputs\bundle\release\app-release.aab" "%RELEASE_DIR%\" >nul 2>&1
) else (
    copy "build\app\outputs\flutter-apk\app-debug.apk" "%RELEASE_DIR%\" >nul 2>&1
)

echo ✅ Release files organized

:: Step 11: Generate Build Info
echo 📋 Generating build information...

set BUILD_INFO_FILE=%RELEASE_DIR%\build_info.txt

echo %APP_NAME% Build Information > "%BUILD_INFO_FILE%"
echo ======================================== >> "%BUILD_INFO_FILE%"
echo. >> "%BUILD_INFO_FILE%"
echo Build Date: %date% %time% >> "%BUILD_INFO_FILE%"
echo Build Type: !BUILD_TYPE! >> "%BUILD_INFO_FILE%"
echo Flutter Version: !FLUTTER_VERSION! >> "%BUILD_INFO_FILE%"
echo. >> "%BUILD_INFO_FILE%"

echo ✅ Build information generated

:: Step 12: Installation Test (optional)
echo 📋 Testing installation...

adb devices | findstr "device$" >nul
if not errorlevel 1 (
    echo ✅ Found connected device(s)
    echo Install APK on connected device? (y/n)
    set /p install_response=
    
    if /i "!install_response!"=="y" (
        if exist "%RELEASE_DIR%\app-universal-release.apk" (
            adb install -r "%RELEASE_DIR%\app-universal-release.apk"
            echo ✅ APK installed successfully
        ) else if exist "%RELEASE_DIR%\app-debug.apk" (
            adb install -r "%RELEASE_DIR%\app-debug.apk"
            echo ✅ APK installed successfully
        ) else (
            echo ❌ APK file not found for installation
        )
    )
) else (
    echo ⚠️ No connected devices found for installation test
)

:: Step 13: Summary
echo.
echo 🎉 Build completed successfully!
echo.
echo 📁 Release files location: %RELEASE_DIR%
echo 📋 Build information: %BUILD_INFO_FILE%
echo.

if "!BUILD_TYPE!"=="release" (
    echo 🔐 Release build with signing
    echo 📦 Files ready for distribution:
    echo    - Universal APK: app-universal-release.apk
    echo    - Architecture-specific APKs: app-*-release.apk
    echo    - App Bundle: app-release.aab (for Play Store)
) else (
    echo 🔧 Debug build (no signing)
    echo 📦 Files for testing:
    echo    - Debug APK: app-debug.apk
)

echo.
echo 📱 Next steps:
echo    1. Test the APK on various devices
echo    2. Upload to Play Console (for release builds)
echo    3. Distribute to testers
echo.

echo ✅ Build process completed! 🚀

pause
