@echo off
setlocal enabledelayedexpansion

echo 🚀 Starting Production APK Build for GST Invoice App
echo ==================================================

REM Configuration
set APP_NAME=GST_Invoice_App
set BUILD_TYPE=release
set SPLIT_PER_ABI=true
set OBFUSCATE=true
set SHRINK_RESOURCES=true

REM Get current timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"
set "BUILD_DIR=build_output_%TIMESTAMP%"

echo Build Configuration:
echo   App Name: %APP_NAME%
echo   Build Type: %BUILD_TYPE%
echo   Split per ABI: %SPLIT_PER_ABI%
echo   Obfuscate: %OBFUSCATE%
echo   Shrink Resources: %SHRINK_RESOURCES%
echo   Output Directory: %BUILD_DIR%
echo.

REM Create output directory
mkdir "%BUILD_DIR%"

REM Step 1: Clean previous builds
echo Step 1: Cleaning previous builds...
flutter clean
if exist "android" (
    cd android
    call gradlew clean
    cd ..
)
echo ✓ Clean completed
echo.

REM Step 2: Get dependencies
echo Step 2: Getting dependencies...
flutter pub get
echo ✓ Dependencies updated
echo.

REM Step 3: Generate code
echo Step 3: Generating code...
findstr /C:"build_runner" pubspec.yaml >nul 2>&1
if !errorlevel! equ 0 (
    flutter packages pub run build_runner build --delete-conflicting-outputs
    echo ✓ Code generation completed
) else (
    echo ℹ No code generation needed
)
echo.

REM Step 4: Build APK
echo Step 4: Building production APK...

set "BUILD_CMD=flutter build apk --%BUILD_TYPE%"

if "%SPLIT_PER_ABI%"=="true" (
    set "BUILD_CMD=!BUILD_CMD! --split-per-abi"
)

if "%OBFUSCATE%"=="true" (
    set "BUILD_CMD=!BUILD_CMD! --obfuscate --split-debug-info=%BUILD_DIR%\symbols"
)

if "%SHRINK_RESOURCES%"=="true" (
    set "BUILD_CMD=!BUILD_CMD! --shrink"
)

set "BUILD_CMD=!BUILD_CMD! --target-platform android-arm,android-arm64,android-x64"

echo Executing: !BUILD_CMD!
!BUILD_CMD!

if !errorlevel! neq 0 (
    echo ✗ APK build failed
    exit /b 1
)
echo ✓ APK build completed successfully
echo.

REM Step 5: Copy APKs to output directory
echo Step 5: Organizing build outputs...

set "APK_SOURCE_DIR=build\app\outputs\flutter-apk"
if exist "%APK_SOURCE_DIR%" (
    xcopy "%APK_SOURCE_DIR%\*" "%BUILD_DIR%\" /Y
    
    REM Rename APKs with timestamp
    cd "%BUILD_DIR%"
    for %%f in (*.apk) do (
        set "apk=%%f"
        if "!apk:arm64-v8a=!" neq "!apk!" (
            set "ARCH=arm64"
        ) else if "!apk:armeabi-v7a=!" neq "!apk!" (
            set "ARCH=arm32"
        ) else if "!apk:x86_64=!" neq "!apk!" (
            set "ARCH=x64"
        ) else (
            set "ARCH=universal"
        )
        
        set "NEW_NAME=%APP_NAME%_!ARCH!_%TIMESTAMP%.apk"
        ren "%%f" "!NEW_NAME!"
        echo   ✓ Created: !NEW_NAME!
    )
    cd ..
) else (
    echo ✗ APK output directory not found
    exit /b 1
)
echo.

REM Step 6: Generate build report
echo Step 6: Generating build report...

set "REPORT_FILE=%BUILD_DIR%\build_report.txt"
(
echo GST Invoice App - Build Report
echo ==============================
echo.
echo Build Information:
echo - Build Date: %date% %time%
echo - Build Type: %BUILD_TYPE%
echo.
echo Configuration:
echo - Split per ABI: %SPLIT_PER_ABI%
echo - Code Obfuscation: %OBFUSCATE%
echo - Resource Shrinking: %SHRINK_RESOURCES%
echo.
echo Generated APKs:
) > "%REPORT_FILE%"

cd "%BUILD_DIR%"
for %%f in (*.apk) do (
    echo - %%f >> build_report.txt
)
cd ..

echo ✓ Build report generated
echo.

REM Step 7: Display summary
echo 🎉 Build completed successfully!
echo ==================================================
echo Output Directory: %BUILD_DIR%
echo Generated Files:

cd "%BUILD_DIR%"
dir /B
cd ..

echo.
echo APK Information:
cd "%BUILD_DIR%"
for %%f in (*.apk) do (
    echo   📱 %%f
)
cd ..

echo.
echo Next Steps:
echo 1. Test the APK on different devices
echo 2. Upload to Google Play Console or distribute directly
echo 3. Keep the symbols directory for crash reporting
echo.

REM Optional: Open output directory
start "" "%BUILD_DIR%"

echo Build script completed! 🚀
pause
