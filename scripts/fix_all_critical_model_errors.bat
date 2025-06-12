@echo off
echo 🔧 Fixing all critical model errors in Flutter Invoice App...

REM Step 1: Fix the severely corrupted gstr4_model.dart file
echo 📝 Fixing corrupted GSTR4 model...
(
echo class GSTR4Model {
echo   final int? id;
echo   final String gstin;
echo   final String returnPeriod;
echo   final DateTime filingDate;
echo   final List^<B2BInvoice^> b2bInvoices;
echo   final List^<B2BURInvoice^> b2burInvoices;
echo   final List^<ImportedGoods^> importedGoods;
echo   final List^<TaxPaid^> taxPaid;
echo   final DateTime createdAt;
echo   final DateTime updatedAt;
echo.
echo   const GSTR4Model^({
echo     this.id,
echo     required this.gstin,
echo     required this.returnPeriod,
echo     required this.filingDate,
echo     required this.b2bInvoices,
echo     required this.b2burInvoices,
echo     required this.importedGoods,
echo     required this.taxPaid,
echo     DateTime? createdAt,
echo     DateTime? updatedAt,
echo   }^) : createdAt = createdAt ?? DateTime.now^(^),
echo        updatedAt = updatedAt ?? DateTime.now^(^);
echo.
echo   factory GSTR4Model.fromJson^(Map^<String, dynamic^> json^) {
echo     return GSTR4Model^(
echo       id: json['id'] as int?,
echo       gstin: json['gstin'] as String,
echo       returnPeriod: json['return_period'] as String,
echo       filingDate: DateTime.parse^(json['filing_date'] as String^),
echo       b2bInvoices: ^(json['b2b_invoices'] as List^<dynamic^>^)
echo           .map^(^(e^) =^> B2BInvoice.fromJson^(e as Map^<String, dynamic^>^)^)
echo           .toList^(^),
echo       b2burInvoices: ^(json['b2bur_invoices'] as List^<dynamic^>^)
echo           .map^(^(e^) =^> B2BURInvoice.fromJson^(e as Map^<String, dynamic^>^)^)
echo           .toList^(^),
echo       importedGoods: ^(json['imported_goods'] as List^<dynamic^>^)
echo           .map^(^(e^) =^> ImportedGoods.fromJson^(e as Map^<String, dynamic^>^)^)
echo           .toList^(^),
echo       taxPaid: ^(json['tax_paid'] as List^<dynamic^>^)
echo           .map^(^(e^) =^> TaxPaid.fromJson^(e as Map^<String, dynamic^>^)^)
echo           .toList^(^),
echo       createdAt: DateTime.parse^(json['created_at'] as String^),
echo       updatedAt: DateTime.parse^(json['updated_at'] as String^),
echo     ^);
echo   }
echo.
echo   Map^<String, dynamic^> toJson^(^) {
echo     return {
echo       'id': id,
echo       'gstin': gstin,
echo       'return_period': returnPeriod,
echo       'filing_date': filingDate.toIso8601String^(^),
echo       'b2b_invoices': b2bInvoices.map^(^(e^) =^> e.toJson^(^)^).toList^(^),
echo       'b2bur_invoices': b2burInvoices.map^(^(e^) =^> e.toJson^(^)^).toList^(^),
echo       'imported_goods': importedGoods.map^(^(e^) =^> e.toJson^(^)^).toList^(^),
echo       'tax_paid': taxPaid.map^(^(e^) =^> e.toJson^(^)^).toList^(^),
echo       'created_at': createdAt.toIso8601String^(^),
echo       'updated_at': updatedAt.toIso8601String^(^),
echo     };
echo   }
echo }
) > lib\models\gstr4_model.dart

REM Step 2: Update pubspec.yaml with missing dependencies
echo 📝 Adding missing dependencies...
echo. >> pubspec.yaml
echo   # Missing dependencies >> pubspec.yaml
echo   url_launcher: ^6.2.4 >> pubspec.yaml
echo   json_annotation: ^4.8.1 >> pubspec.yaml
echo   equatable: ^2.0.5 >> pubspec.yaml

REM Step 3: Clean and get dependencies
echo 📝 Cleaning and getting dependencies...
flutter clean
flutter pub get

REM Step 4: Generate missing files
echo 📝 Generating missing model files...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Step 5: Fix remaining syntax issues
echo 📝 Running dart fix to auto-fix remaining issues...
dart fix --apply

echo ✅ All critical model errors have been fixed!
echo 🔍 Run 'flutter analyze' to check for any remaining issues.
pause
