@echo off
echo Generating Android Keystore for Release Signing...

if not exist "android\keystore" mkdir android\keystore

set KEYSTORE_PATH=android\keystore\release-keystore.jks
set KEY_ALIAS=release
set VALIDITY_DAYS=10000

echo Creating release keystore...
keytool -genkey -v -keystore %KEYSTORE_PATH% -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity %VALIDITY_DAYS%

echo Keystore generated successfully at: %KEYSTORE_PATH%
echo.
echo Please update android\keystore.properties with your keystore details:
echo storePassword=^<your_store_password^>
echo keyPassword=^<your_key_password^>
echo keyAlias=%KEY_ALIAS%
echo storeFile=keystore\release-keystore.jks
echo.
echo For Play Store upload, also generate an upload keystore:
echo keytool -genkey -v -keystore android\keystore\upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity %VALIDITY_DAYS%

pause
