@echo off
echo 📦 Installing BLoC CLI globally...

REM Install bloc_cli globally
dart pub global activate bloc_cli

REM Add pub cache bin to PATH
set PATH=%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin

REM Verify installation
echo 🔍 Verifying BLoC CLI installation...
bloc --version

echo ✅ BLoC CLI installed successfully!
echo 💡 The BLoC CLI has been added to your PATH for this session.
echo    To make it permanent, add %USERPROFILE%\AppData\Local\Pub\Cache\bin to your system PATH.
pause
