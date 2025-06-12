#!/bin/bash

echo "Generating Android Keystore for Release Signing..."

# Create keystore directory if it doesn't exist
mkdir -p android/keystore

# Keystore details
KEYSTORE_PATH="android/keystore/release-keystore.jks"
KEY_ALIAS="release"
VALIDITY_DAYS=10000

echo "Creating release keystore..."
keytool -genkey -v -keystore $KEYSTORE_PATH -alias $KEY_ALIAS -keyalg RSA -keysize 2048 -validity $VALIDITY_DAYS

echo "Keystore generated successfully at: $KEYSTORE_PATH"
echo ""
echo "Please update android/keystore.properties with your keystore details:"
echo "storePassword=<your_store_password>"
echo "keyPassword=<your_key_password>"
echo "keyAlias=$KEY_ALIAS"
echo "storeFile=keystore/release-keystore.jks"
echo ""
echo "For Play Store upload, also generate an upload keystore:"
echo "keytool -genkey -v -keystore android/keystore/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity $VALIDITY_DAYS"
