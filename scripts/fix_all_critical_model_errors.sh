#!/bin/bash

echo "🔧 Fixing all critical model errors in Flutter Invoice App..."

# Step 1: Fix the severely corrupted gstr4_model.dart file
echo "📝 Fixing corrupted GSTR4 model..."
cat > lib/models/gstr4_model.dart << 'EOF'
class GSTR4Model {
  final int? id;
  final String gstin;
  final String returnPeriod;
  final DateTime filingDate;
  final List<B2BInvoice> b2bInvoices;
  final List<B2BURInvoice> b2burInvoices;
  final List<ImportedGoods> importedGoods;
  final List<TaxPaid> taxPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GSTR4Model({
    this.id,
    required this.gstin,
    required this.returnPeriod,
    required this.filingDate,
    required this.b2bInvoices,
    required this.b2burInvoices,
    required this.importedGoods,
    required this.taxPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory GSTR4Model.fromJson(Map<String, dynamic> json) {
    return GSTR4Model(
      id: json['id'] as int?,
      gstin: json['gstin'] as String,
      returnPeriod: json['return_period'] as String,
      filingDate: DateTime.parse(json['filing_date'] as String),
      b2bInvoices: (json['b2b_invoices'] as List<dynamic>)
          .map((e) => B2BInvoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      b2burInvoices: (json['b2bur_invoices'] as List<dynamic>)
          .map((e) => B2BURInvoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      importedGoods: (json['imported_goods'] as List<dynamic>)
          .map((e) => ImportedGoods.fromJson(e as Map<String, dynamic>))
          .toList(),
      taxPaid: (json['tax_paid'] as List<dynamic>)
          .map((e) => TaxPaid.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gstin': gstin,
      'return_period': returnPeriod,
      'filing_date': filingDate.toIso8601String(),
      'b2b_invoices': b2bInvoices.map((e) => e.toJson()).toList(),
      'b2bur_invoices': b2burInvoices.map((e) => e.toJson()).toList(),
      'imported_goods': importedGoods.map((e) => e.toJson()).toList(),
      'tax_paid': taxPaid.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GSTR4Model copyWith({
    int? id,
    String? gstin,
    String? returnPeriod,
    DateTime? filingDate,
    List<B2BInvoice>? b2bInvoices,
    List<B2BURInvoice>? b2burInvoices,
    List<ImportedGoods>? importedGoods,
    List<TaxPaid>? taxPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GSTR4Model(
      id: id ?? this.id,
      gstin: gstin ?? this.gstin,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      filingDate: filingDate ?? this.filingDate,
      b2bInvoices: b2bInvoices ?? this.b2bInvoices,
      b2burInvoices: b2burInvoices ?? this.b2burInvoices,
      importedGoods: importedGoods ?? this.importedGoods,
      taxPaid: taxPaid ?? this.taxPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class B2BURInvoice {
  final String? id;
  final String supplierGstin;
  final String supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceValue;
  final String placeOfSupply;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  const B2BURInvoice({
    this.id,
    required this.supplierGstin,
    required this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceValue,
    required this.placeOfSupply,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory B2BURInvoice.fromJson(Map<String, dynamic> json) {
    return B2BURInvoice(
      id: json['id'] as String?,
      supplierGstin: json['supplier_gstin'] as String,
      supplierName: json['supplier_name'] as String,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      invoiceValue: (json['invoice_value'] as num).toDouble(),
      placeOfSupply: json['place_of_supply'] as String,
      taxableValue: (json['taxable_value'] as num).toDouble(),
      cgstAmount: (json['cgst_amount'] as num).toDouble(),
      sgstAmount: (json['sgst_amount'] as num).toDouble(),
      igstAmount: (json['igst_amount'] as num).toDouble(),
      cessAmount: (json['cess_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_gstin': supplierGstin,
      'supplier_name': supplierName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'invoice_value': invoiceValue,
      'place_of_supply': placeOfSupply,
      'taxable_value': taxableValue,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class ImportedGoods {
  final String? id;
  final String portCode;
  final String billOfEntry;
  final DateTime billDate;
  final double billValue;
  final double taxableValue;
  final double igstAmount;
  final double cessAmount;

  const ImportedGoods({
    this.id,
    required this.portCode,
    required this.billOfEntry,
    required this.billDate,
    required this.billValue,
    required this.taxableValue,
    required this.igstAmount,
    required this.cessAmount,
  });

  factory ImportedGoods.fromJson(Map<String, dynamic> json) {
    return ImportedGoods(
      id: json['id'] as String?,
      portCode: json['port_code'] as String,
      billOfEntry: json['bill_of_entry'] as String,
      billDate: DateTime.parse(json['bill_date'] as String),
      billValue: (json['bill_value'] as num).toDouble(),
      taxableValue: (json['taxable_value'] as num).toDouble(),
      igstAmount: (json['igst_amount'] as num).toDouble(),
      cessAmount: (json['cess_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'port_code': portCode,
      'bill_of_entry': billOfEntry,
      'bill_date': billDate.toIso8601String(),
      'bill_value': billValue,
      'taxable_value': taxableValue,
      'igst_amount': igstAmount,
      'cess_amount': cessAmount,
    };
  }
}

class TaxPaid {
  final String? id;
  final String taxType;
  final double taxAmount;
  final String challanNumber;
  final DateTime paymentDate;

  const TaxPaid({
    this.id,
    required this.taxType,
    required this.taxAmount,
    required this.challanNumber,
    required this.paymentDate,
  });

  factory TaxPaid.fromJson(Map<String, dynamic> json) {
    return TaxPaid(
      id: json['id'] as String?,
      taxType: json['tax_type'] as String,
      taxAmount: (json['tax_amount'] as num).toDouble(),
      challanNumber: json['challan_number'] as String,
      paymentDate: DateTime.parse(json['payment_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tax_type': taxType,
      'tax_amount': taxAmount,
      'challan_number': challanNumber,
      'payment_date': paymentDate.toIso8601String(),
    };
  }
}
EOF

# Step 2: Fix the firestore_gstr3b_model.dart syntax error
echo "📝 Fixing firestore GSTR3B model syntax error..."
sed -i 's/ineligibleITC: json\['\''ineligible_itc'\''\],$/ineligibleITC: (json['\''ineligible_itc'\''] as num).toDouble(),/' lib/models/gst_returns/firestore_gstr3b_model.dart
sed -i 's/eligibleITC: json\['\''eligible_itc'\''\],$/eligibleITC: (json['\''eligible_itc'\''] as num).toDouble(),/' lib/models/gst_returns/firestore_gstr3b_model.dart

# Step 3: Fix environment configuration
echo "📝 Fixing environment configuration..."
cat > lib/config/environment.dart << 'EOF'
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static set environment(Environment env) {
    _environment = env;
  }
  
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }
}
EOF

# Step 4: Fix customer model and extensions
echo "📝 Fixing customer model..."
cat > lib/models/customer/customer_model.dart << 'EOF'
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

enum CustomerType { individual, business, government }

@JsonSerializable()
class Customer extends Equatable {
  final String? id;
  final String name;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstin;
  final String? panNumber;
  final CustomerType type;
  final double? creditLimit;
  final double currentBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.mobile,
    this.email,
    this.address,
    this.gstin,
    this.panNumber,
    this.type = CustomerType.individual,
    this.creditLimit,
    this.currentBalance = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? panNumber,
    CustomerType? type,
    double? creditLimit,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      panNumber: panNumber ?? this.panNumber,
      type: type ?? this.type,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, mobile, email, address, gstin, panNumber, 
    type, creditLimit, currentBalance, createdAt, updatedAt
  ];
}
EOF

# Step 5: Fix customer extensions
echo "📝 Fixing customer extensions..."
cat > lib/models/customer/customer_extensions.dart << 'EOF'
import 'customer_model.dart';

extension CustomerExtensions on Customer {
  Map<String, dynamic> toDisplayMap() {
    return {
      'ID': id ?? 'N/A',
      'Name': name,
      'Mobile': mobile ?? 'N/A',
      'Email': email ?? 'N/A',
      'Address': address ?? 'N/A',
      'GSTIN': gstin ?? 'N/A',
      'PAN Number': panNumber ?? 'N/A',
      'Type': type.toString().split('.').last,
      'Credit Limit': creditLimit?.toString() ?? 'N/A',
      'Current Balance': currentBalance.toString(),
      'Created At': createdAt.toString(),
      'Updated At': updatedAt.toString(),
    };
  }

  String get displayName {
    return name;
  }

  bool get hasGstin {
    return gstin != null && gstin!.isNotEmpty;
  }

  CustomerType get customerType {
    return type;
  }

  bool get isBusinessCustomer {
    return type == CustomerType.business;
  }
}
EOF

# Step 6: Update pubspec.yaml with missing dependencies
echo "📝 Adding missing dependencies to pubspec.yaml..."
cat >> pubspec.yaml << 'EOF'

  # Missing dependencies
  url_launcher: ^6.2.4
  json_annotation: ^4.8.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
EOF

# Step 7: Remove unused imports and fix constructor ordering
echo "📝 Fixing import issues and constructor ordering..."

# Fix GSTR1 model
sed -i '/^import.*foundation/d' lib/models/gstr1_model.dart
sed -i '/^import.*foundation/d' lib/models/gstr3b_model.dart

# Step 8: Add missing localization strings
echo "📝 Adding missing localization strings..."
cat >> lib/l10n/app_en.arb << 'EOF'
  "firebaseMonitoring": "Firebase Monitoring",
  "crashlytics": "Crashlytics",
  "analytics": "Analytics",
  "testTools": "Test Tools",
  "quickLinks": "Quick Links",
  "crashReports": "Crash Reports",
  "crashReportsDescription": "Monitor app crashes and stability",
  "crashFreeUsers": "Crash-free Users",
  "totalCrashes": "Total Crashes",
  "affectedUsers": "Affected Users",
  "openCrashlytics": "Open Crashlytics",
  "analyticsOverview": "Analytics Overview",
  "analyticsDescription": "Track user behavior and app usage",
  "activeUsers": "Active Users",
  "sessions": "Sessions",
  "screenViews": "Screen Views",
  "openAnalytics": "Open Analytics",
  "recentCrashes": "Recent Crashes",
  "crashTrends": "Crash Trends",
  "topEvents": "Top Events",
  "userJourney": "User Journey",
  "firebaseQuickLinks": "Firebase Quick Links",
  "crashlyticsConsole": "Crashlytics Console",
  "crashlyticsDescription": "View crash reports and analytics",
  "analyticsConsole": "Analytics Console",
  "analyticsConsoleDescription": "View user analytics and events",
  "performanceConsole": "Performance Console",
  "performanceDescription": "Monitor app performance metrics",
  "remoteConfigConsole": "Remote Config Console",
  "remoteConfigDescription": "Manage remote configuration",
  "firestoreConsole": "Firestore Console",
  "firestoreDescription": "Manage database collections",
  "firebaseProjectNote": "Note: Replace 'your-project-id' with your actual Firebase project ID"
EOF

# Step 9: Clean and get dependencies
echo "📝 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Step 10: Generate missing files
echo "📝 Generating missing model files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Step 11: Fix remaining syntax issues
echo "📝 Running dart fix to auto-fix remaining issues..."
dart fix --apply

echo "✅ All critical model errors have been fixed!"
echo "🔍 Run 'flutter analyze' to check for any remaining issues."
EOF
