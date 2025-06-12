@echo off
setlocal enabledelayedexpansion

echo 🚀 Building Final Production APK for GST Invoice App
echo =====================================================

REM Configuration
set APP_NAME=GST_Invoice_App
set VERSION=1.0.0
set BUILD_NUMBER=1

REM Get current timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"
set "BUILD_DIR=production_build_%TIMESTAMP%"
set "SYMBOLS_DIR=%BUILD_DIR%\symbols"

echo Build Configuration:
echo   📱 App Name: %APP_NAME%
echo   🔢 Version: %VERSION%+%BUILD_NUMBER%
echo   📅 Build Time: %date% %time%
echo   📁 Output Directory: %BUILD_DIR%
echo   🔒 Obfuscation: Enabled
echo   📦 Split APKs: Enabled
echo   🗜️ Resource Shrinking: Enabled
echo.

REM Create output directories
mkdir "%BUILD_DIR%" 2>nul
mkdir "%SYMBOLS_DIR%" 2>nul

REM Step 1: Environment Check
echo Step 1: Checking build environment...

REM Check Flutter installation
flutter --version >nul 2>&1
if !errorlevel! neq 0 (
    echo ✗ Flutter not found. Please install Flutter first.
    exit /b 1
)

echo ✓ Build environment verified
echo.

REM Step 2: Flutter Doctor Check
echo Step 2: Running Flutter doctor...
flutter doctor
echo ✓ Flutter doctor completed
echo.

REM Step 3: Clean Everything
echo Step 3: Performing deep clean...

flutter clean

if exist "android" (
    cd android
    if exist "gradlew.bat" (
        call gradlew.bat clean
    ) else if exist "gradlew" (
        call gradlew clean
    )
    cd ..
)

REM Remove build directories
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"

echo ✓ Deep clean completed
echo.

REM Step 4: Get Dependencies
echo Step 4: Getting dependencies...
flutter pub get

if !errorlevel! neq 0 (
    echo ✗ Failed to get dependencies
    exit /b 1
)

echo ✓ Dependencies updated
echo.

REM Step 5: Code Generation
echo Step 5: Running code generation...

findstr /C:"build_runner" pubspec.yaml >nul 2>&1
if !errorlevel! equ 0 (
    echo Running build_runner...
    flutter packages pub run build_runner build --delete-conflicting-outputs
    echo ✓ Code generation completed
) else (
    echo ℹ No code generation needed
)
echo.

REM Step 6: Pre-build Analysis
echo Step 6: Running pre-build analysis...
flutter analyze
echo ✓ Static analysis completed
echo.

REM Step 7: Build Production APK
echo Step 7: Building production APK...

set "BUILD_CMD=flutter build apk --release --split-per-abi --obfuscate --split-debug-info=%SYMBOLS_DIR% --shrink --target-platform android-arm,android-arm64,android-x64"

echo Executing: !BUILD_CMD!
echo.

!BUILD_CMD!

if !errorlevel! neq 0 (
    echo ✗ APK build failed
    exit /b 1
)

echo ✓ APK build completed successfully
echo.

REM Step 8: Organize Build Outputs
echo Step 8: Organizing build outputs...

set "APK_SOURCE_DIR=build\app\outputs\flutter-apk"
if exist "%APK_SOURCE_DIR%" (
    xcopy "%APK_SOURCE_DIR%\*" "%BUILD_DIR%\" /Y
    
    REM Rename APKs with proper naming
    cd "%BUILD_DIR%"
    for %%f in (*.apk) do (
        set "apk=%%f"
        if "!apk:arm64-v8a=!" neq "!apk!" (
            set "ARCH=arm64"
            set "ARCH_FULL=ARM64 (64-bit)"
        ) else if "!apk:armeabi-v7a=!" neq "!apk!" (
            set "ARCH=arm32"
            set "ARCH_FULL=ARM32 (32-bit)"
        ) else if "!apk:x86_64=!" neq "!apk!" (
            set "ARCH=x64"
            set "ARCH_FULL=x86_64 (64-bit)"
        ) else (
            set "ARCH=universal"
            set "ARCH_FULL=Universal (All architectures)"
        )
        
        set "NEW_NAME=%APP_NAME%_v%VERSION%_!ARCH!_%TIMESTAMP%.apk"
        ren "%%f" "!NEW_NAME!"
        echo   ✓ Created: !NEW_NAME! - !ARCH_FULL!
    )
    cd ..
) else (
    echo ✗ APK output directory not found
    exit /b 1
)
echo.

REM Step 9: Generate Build Report
echo Step 9: Generating comprehensive build report...

set "REPORT_FILE=%BUILD_DIR%\BUILD_REPORT.md"
(
echo # GST Invoice App - Production Build Report
echo.
echo ## Build Information
echo - **App Name**: %APP_NAME%
echo - **Version**: %VERSION%+%BUILD_NUMBER%
echo - **Build Date**: %date% %time%
echo - **Build Type**: Production Release
echo - **Build ID**: %TIMESTAMP%
echo.
echo ## Build Configuration
echo - ✅ Code Obfuscation: Enabled
echo - ✅ Resource Shrinking: Enabled
echo - ✅ Split APKs: Enabled (ARM32, ARM64, x86_64^)
echo - ✅ Debug Info: Stripped (symbols saved separately^)
echo - ✅ Proguard: Enabled
echo - ✅ R8 Optimization: Enabled
echo.
echo ## Generated APKs
) > "%REPORT_FILE%"

REM Add APK information to report
cd "%BUILD_DIR%"
for %%f in (*.apk) do (
    echo - **%%f** >> BUILD_REPORT.md
)
cd ..

echo ✓ Build report generated
echo.

REM Step 10: Build Summary
echo 🎉 Production APK Build Completed Successfully!
echo ==============================================
echo.
echo 📁 Output Directory: %BUILD_DIR%
echo 📊 Build Report: %BUILD_DIR%\BUILD_REPORT.md
echo 🔒 Debug Symbols: %SYMBOLS_DIR%
echo.

echo 📱 Generated APKs:
cd "%BUILD_DIR%"
for %%f in (*.apk) do (
    echo   • %%f
)
cd ..

echo.
echo 📋 Next Steps:
echo 1. 🧪 Test APKs on different devices
echo 2. 📤 Upload to Google Play Console or distribute directly
echo 3. 💾 Keep symbols directory for crash reporting
echo 4. 📋 Review build report for details
echo.

REM Optional: Open output directory
start "" "%BUILD_DIR%"

echo 🚀 Production build completed successfully!
echo Build ID: %TIMESTAMP%
pause
