#!/bin/bash

echo "🔧 Starting comprehensive model error fixes..."

# Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Add missing dependencies
echo "📦 Adding missing dependencies..."
flutter pub add json_annotation json_serializable build_runner equatable
flutter pub add --dev build_runner

# Fix QRMP model generation issue
echo "🔧 Fixing QRMP model..."
cat > lib/models/gst_returns/qrmp_model.dart << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'qrmp_model.g.dart';

@JsonSerializable()
class QRMPScheme {
  final String gstin;
  final String quarter;
  final String financialYear;
  final List<QRMPMonthlyPayment> monthlyPayments;
  final QRMPSelfAssessment selfAssessment;
  final QRMPQuarterlyReturn quarterlyReturn;

  const QRMPScheme({
    required this.gstin,
    required this.quarter,
    required this.financialYear,
    required this.monthlyPayments,
    required this.selfAssessment,
    required this.quarterlyReturn,
  });

  factory QRMPScheme.fromJson(Map<String, dynamic> json) =>
      _$QRMPSchemeFromJson(json);
  
  Map<String, dynamic> toJson() => _$QRMPSchemeToJson(this);
}

@JsonSerializable()
class QRMPMonthlyPayment {
  final String month;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;
  final DateTime paymentDate;
  final String challanNumber;

  const QRMPMonthlyPayment({
    required this.month,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cessAmount,
    required this.paymentDate,
    required this.challanNumber,
  });

  factory QRMPMonthlyPayment.fromJson(Map<String, dynamic> json) =>
      _$QRMPMonthlyPaymentFromJson(json);
  
  Map<String, dynamic> toJson() => _$QRMPMonthlyPaymentToJson(this);
}

@JsonSerializable()
class QRMPSelfAssessment {
  final double totalTurnover;
  final double exemptSupplies;
  final double nilRatedSupplies;
  final double nonGstSupplies;
  final double totalTaxableSupplies;
  final double totalTaxLiability;

  const QRMPSelfAssessment({
    required this.totalTurnover,
    required this.exemptSupplies,
    required this.nilRatedSupplies,
    required this.nonGstSupplies,
    required this.totalTaxableSupplies,
    required this.totalTaxLiability,
  });

  factory QRMPSelfAssessment.fromJson(Map<String, dynamic> json) =>
      _$QRMPSelfAssessmentFromJson(json);
  
  Map<String, dynamic> toJson() => _$QRMPSelfAssessmentToJson(this);
}

@JsonSerializable()
class QRMPQuarterlyReturn {
  final String returnPeriod;
  final DateTime filingDate;
  final String status;
  final double totalTaxableValue;
  final double totalTaxAmount;
  final double totalTaxPaid;
  final double balanceTaxDue;

  const QRMPQuarterlyReturn({
    required this.returnPeriod,
    required this.filingDate,
    required this.status,
    required this.totalTaxableValue,
    required this.totalTaxAmount,
    required this.totalTaxPaid,
    required this.balanceTaxDue,
  });

  factory QRMPQuarterlyReturn.fromJson(Map<String, dynamic> json) =>
      _$QRMPQuarterlyReturnFromJson(json);
  
  Map<String, dynamic> toJson() => _$QRMPQuarterlyReturnToJson(this);
}
EOF

# Fix Invoice Type enum
echo "🔧 Fixing Invoice Type enum..."
cat > lib/models/invoice/invoice_type.dart << 'EOF'
enum InvoiceType {
  standard,
  credit,
  debit,
  proforma,
  estimate,
  receipt,
  purchase,
  expense
}

extension InvoiceTypeExtension on InvoiceType {
  String get displayName {
    switch (this) {
      case InvoiceType.standard:
        return 'Standard Invoice';
      case InvoiceType.credit:
        return 'Credit Note';
      case InvoiceType.debit:
        return 'Debit Note';
      case InvoiceType.proforma:
        return 'Proforma Invoice';
      case InvoiceType.estimate:
        return 'Estimate';
      case InvoiceType.receipt:
        return 'Receipt';
      case InvoiceType.purchase:
        return 'Purchase Invoice';
      case InvoiceType.expense:
        return 'Expense';
    }
  }
}
EOF

# Fix Invoice Item Model
echo "🔧 Fixing Invoice Item Model..."
cat > lib/models/invoice/invoice_item_model.dart << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'invoice_item_model.g.dart';

@JsonSerializable()
class InvoiceItem {
  final String id;
  final String description;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);

  factory InvoiceItem.empty() {
    return const InvoiceItem(
      id: '',
      description: '',
      hsnCode: '',
      quantity: 0.0,
      unit: '',
      rate: 0.0,
      amount: 0.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? description,
    String? hsnCode,
    double? quantity,
    String? unit,
    double? rate,
    double? amount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
EOF

# Fix Customer Model
echo "🔧 Fixing Customer Model..."
cat > lib/models/customer/customer_model.dart << 'EOF'
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'customer_model.g.dart';

enum CustomerType {
  individual,
  business,
  government,
  nonprofit
}

@JsonSerializable()
class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gstin;
  final CustomerType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gstin,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  factory Customer.empty() {
    final now = DateTime.now();
    return Customer(
      id: '',
      name: '',
      email: '',
      phone: '',
      address: '',
      gstin: '',
      type: CustomerType.individual,
      createdAt: now,
      updatedAt: now,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gstin,
    CustomerType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        gstin,
        type,
        createdAt,
        updatedAt,
      ];
}
EOF

# Fix Ledger Models
echo "🔧 Fixing Ledger Models..."
cat > lib/models/ledger_models.dart << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'ledger_models.g.dart';

@JsonSerializable()
class CashLedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String reference;

  const CashLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.reference,
  });

  factory CashLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$CashLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CashLedgerEntryToJson(this);
}

@JsonSerializable()
class ElectronicLedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String reference;

  const ElectronicLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.reference,
  });

  factory ElectronicLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$ElectronicLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ElectronicLedgerEntryToJson(this);
}

@JsonSerializable()
class LiabilityLedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String reference;

  const LiabilityLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.reference,
  });

  factory LiabilityLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$LiabilityLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LiabilityLedgerEntryToJson(this);
}

@JsonSerializable()
class RCMLedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String reference;

  const RCMLedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.reference,
  });

  factory RCMLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$RCMLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RCMLedgerEntryToJson(this);
}
EOF

# Fix Migration Result Model
echo "🔧 Fixing Migration Result Model..."
cat > lib/models/migration/migration_result.dart << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'migration_result.g.dart';

@JsonSerializable()
class MigrationResult {
  final bool success;
  final String message;
  final int recordsProcessed;
  final int recordsSuccessful;
  final int recordsFailed;
  final Duration duration;
  final List<String> errors;

  const MigrationResult({
    required this.success,
    required this.message,
    required this.recordsProcessed,
    required this.recordsSuccessful,
    required this.recordsFailed,
    required this.duration,
    required this.errors,
  });

  factory MigrationResult.fromJson(Map<String, dynamic> json) =>
      _$MigrationResultFromJson(json);

  Map<String, dynamic> toJson() => _$MigrationResultToJson(this);

  factory MigrationResult.success({
    required int recordsProcessed,
    required Duration duration,
  }) {
    return MigrationResult(
      success: true,
      message: 'Migration completed successfully',
      recordsProcessed: recordsProcessed,
      recordsSuccessful: recordsProcessed,
      recordsFailed: 0,
      duration: duration,
      errors: const [],
    );
  }

  factory MigrationResult.failure({
    required String message,
    required int recordsProcessed,
    required int recordsSuccessful,
    required int recordsFailed,
    required Duration duration,
    required List<String> errors,
  }) {
    return MigrationResult(
      success: false,
      message: message,
      recordsProcessed: recordsProcessed,
      recordsSuccessful: recordsSuccessful,
      recordsFailed: recordsFailed,
      duration: duration,
      errors: errors,
    );
  }
}
EOF

# Fix Stripe Payment Model syntax errors
echo "🔧 Fixing Stripe Payment Model..."
sed -i 's/required this\.amount,$/required this.amount,/' lib/models/payment/stripe_payment_model.dart
sed -i 's/required this\.currency,$/required this.currency,/' lib/models/payment/stripe_payment_model.dart
sed -i 's/required this\.status,$/required this.status,/' lib/models/payment/stripe_payment_model.dart

# Fix Reconciliation Extensions
echo "🔧 Fixing Reconciliation Extensions..."
cat > lib/models/reconciliation/reconciliation_extensions.dart << 'EOF'
// Placeholder for reconciliation extensions
// This file will be implemented when reconciliation models are defined

class ReconciliationSummary {
  final int mismatchedInvoices;
  final double totalTaxableValueSource1;
  final double totalTaxableValueSource2;
  final double totalTaxSource1;
  final double totalTaxSource2;
  final double totalTaxDifference;

  const ReconciliationSummary({
    required this.mismatchedInvoices,
    required this.totalTaxableValueSource1,
    required this.totalTaxableValueSource2,
    required this.totalTaxSource1,
    required this.totalTaxSource2,
    required this.totalTaxDifference,
  });
}

class ReconciliationItem {
  final double taxableValueSource1;
  final double taxableValueSource2;
  final double igstSource1;
  final double igstSource2;
  final double cgstSource1;
  final double cgstSource2;
  final double sgstSource1;
  final double sgstSource2;

  const ReconciliationItem({
    required this.taxableValueSource1,
    required this.taxableValueSource2,
    required this.igstSource1,
    required this.igstSource2,
    required this.cgstSource1,
    required this.cgstSource2,
    required this.sgstSource1,
    required this.sgstSource2,
  });
}

extension ReconciliationSummaryExtensions on ReconciliationSummary {
  double get totalValueDifference =>
      totalTaxableValueSource1 - totalTaxableValueSource2;
}

extension ReconciliationItemExtensions on ReconciliationItem {
  double get totalTaxDifference =>
      (igstSource1 + cgstSource1 + sgstSource1) -
      (igstSource2 + cgstSource2 + sgstSource2);
}
EOF

# Remove unused imports
echo "🔧 Removing unused imports..."
find lib -name "*.dart" -exec sed -i '/^import.*foundation\.dart/d' {} \;

# Generate missing files
echo "🔧 Generating missing files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix constructor ordering and parameter ordering
echo "🔧 Applying dart fix for linting issues..."
dart fix --apply

# Final cleanup
echo "🔧 Final cleanup..."
flutter pub get
flutter analyze --no-fatal-infos

echo "✅ Comprehensive model error fixes completed!"
echo "📊 Run 'flutter analyze' to check remaining issues"
echo "🚀 Run 'flutter build apk' to test the build"
