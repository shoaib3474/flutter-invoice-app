@echo off
echo 🔧 Starting comprehensive error fix...

echo 🧹 Cleaning project...
flutter clean
rmdir /s /q .dart_tool 2>nul
del pubspec.lock 2>nul

echo 📦 Clearing pub cache...
flutter pub cache clean

echo 📥 Getting dependencies...
flutter pub get

echo ⚙️ Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo 🔍 Analyzing code...
flutter analyze

echo 📤 Adding missing exports...

echo // API Models > lib\models\models.dart
echo export 'api/api_response.dart'; >> lib\models\models.dart
echo. >> lib\models\models.dart
echo // GST Returns Models >> lib\models\models.dart
echo export 'gst_returns/gstr1_model.dart'; >> lib\models\models.dart
echo export 'gst_returns/gstr3b_model.dart'; >> lib\models\models.dart
echo export 'gst_returns/gstr4_model.dart'; >> lib\models\models.dart
echo export 'gst_returns/gstr9_model.dart'; >> lib\models\models.dart
echo export 'gst_returns/gstr9c_model.dart'; >> lib\models\models.dart
echo export 'gst_returns/gst_summary_models.dart'; >> lib\models\models.dart

echo ✅ Error fix completed!
echo 🚀 Try building again: flutter build apk --release
