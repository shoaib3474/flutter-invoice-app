@echo off
echo 🔧 Fixing demo GST API client issues...

echo 📝 Generating missing model files...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo 🎯 Fixing linting issues...
dart fix --apply

echo 🧹 Cleaning and getting dependencies...
flutter clean
flutter pub get

echo 🔄 Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo 🔍 Checking for remaining issues...
flutter analyze lib/api/demo_gst_api_client.dart

echo ✅ Demo API client fixes completed!
pause
