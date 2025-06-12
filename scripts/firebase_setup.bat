@echo off
echo 🔥 Firebase Setup Script for GST Invoice App
echo =============================================

REM Check if Firebase CLI is installed
echo [INFO] Checking Firebase CLI installation...
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Firebase CLI not found. Please install it first:
    echo npm install -g firebase-tools
    pause
    exit /b 1
) else (
    echo [SUCCESS] Firebase CLI is installed
)

REM Check if FlutterFire CLI is installed
echo [INFO] Checking FlutterFire CLI installation...
flutterfire --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] FlutterFire CLI not found. Installing...
    dart pub global activate flutterfire_cli
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install FlutterFire CLI
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] FlutterFire CLI installed successfully
    )
) else (
    echo [SUCCESS] FlutterFire CLI is already installed
)

REM Login to Firebase
echo [INFO] Checking Firebase authentication...
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Not logged in to Firebase. Please login...
    firebase login
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to login to Firebase
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] Already logged in to Firebase
)

REM Configure FlutterFire
echo [INFO] Configuring FlutterFire...
echo [WARNING] Please select or create a Firebase project when prompted
flutterfire configure

if %errorlevel% neq 0 (
    echo [ERROR] FlutterFire configuration failed
    pause
    exit /b 1
) else (
    echo [SUCCESS] FlutterFire configuration completed
)

REM Install dependencies
echo [INFO] Installing Flutter dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
) else (
    echo [SUCCESS] Dependencies installed successfully
)

REM Initialize Firebase project
if not exist firebase.json (
    echo [INFO] Initializing Firebase project...
    firebase init firestore functions hosting
    
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to initialize Firebase project
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] Firebase project initialized
    )
) else (
    echo [SUCCESS] Firebase project already initialized
)

echo [SUCCESS] 🎉 Firebase setup completed successfully!
echo [INFO] Next steps:
echo   1. Run: flutter run
echo   2. Go to Settings → Test Screens → Firebase Setup Test
echo   3. Deploy Cloud Functions: scripts\deploy_functions.bat
echo   4. Configure Stripe keys in lib\config\stripe_config.dart

pause
