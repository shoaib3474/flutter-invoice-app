@echo off
echo 🔧 Starting comprehensive model error fixes...

REM Clean and get dependencies
echo 📦 Cleaning and getting dependencies...
flutter clean
flutter pub get

REM Add missing dependencies
echo 📦 Adding missing dependencies...
flutter pub add json_annotation json_serializable build_runner equatable
flutter pub add --dev build_runner

REM Fix QRMP model generation issue
echo 🔧 Fixing QRMP model...
(
echo import 'package:json_annotation/json_annotation.dart';
echo.
echo part 'qrmp_model.g.dart';
echo.
echo @JsonSerializable^(^)
echo class QRMPScheme {
echo   final String gstin;
echo   final String quarter;
echo   final String financialYear;
echo   final List^<QRMPMonthlyPayment^> monthlyPayments;
echo   final QRMPSelfAssessment selfAssessment;
echo   final QRMPQuarterlyReturn quarterlyReturn;
echo.
echo   const QRMPScheme^({
echo     required this.gstin,
echo     required this.quarter,
echo     required this.financialYear,
echo     required this.monthlyPayments,
echo     required this.selfAssessment,
echo     required this.quarterlyReturn,
echo   }^);
echo.
echo   factory QRMPScheme.fromJson^(Map^<String, dynamic^> json^) =^>
echo       _$QRMPSchemeFromJson^(json^);
echo.
echo   Map^<String, dynamic^> toJson^(^) =^> _$QRMPSchemeToJson^(this^);
echo }
) > lib\models\gst_returns\qrmp_model.dart

REM Generate missing files
echo 🔧 Generating missing files...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Apply dart fix
echo 🔧 Applying dart fix for linting issues...
dart fix --apply

REM Final cleanup
echo 🔧 Final cleanup...
flutter pub get
flutter analyze --no-fatal-infos

echo ✅ Comprehensive model error fixes completed!
echo 📊 Run 'flutter analyze' to check remaining issues
echo 🚀 Run 'flutter build apk' to test the build
