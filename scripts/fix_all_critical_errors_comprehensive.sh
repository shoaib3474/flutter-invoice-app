#!/bin/bash

echo "🔧 Starting comprehensive fix for Flutter Invoice App..."

# Create backup
echo "📦 Creating backup..."
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# 1. Fix pubspec.yaml dependencies
echo "📝 Fixing pubspec.yaml dependencies..."
cat > pubspec.yaml << 'EOF'
name: flutter_invoice_app
description: A comprehensive GST invoice and tax management application for Indian businesses
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Core dependencies
  cupertino_icons: ^1.0.6
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  path: ^1.8.3
  intl: ^0.19.0
  
  # UI dependencies
  flutter_colorpicker: ^1.0.3
  qr_flutter: ^4.1.0
  image_picker: ^1.0.4
  
  # Payment dependencies
  flutter_stripe: ^10.1.1
  razorpay_flutter: ^1.3.6
  
  # State management
  flutter_bloc: ^8.1.3
  
  # File handling
  file_picker: ^6.1.1
  share_plus: ^7.2.1
  path_provider: ^2.1.1
  
  # PDF generation
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # HTTP and API
  http: ^1.1.0
  dio: ^5.3.2
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  
  # Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  supabase_flutter: ^2.0.0
  
  # Utilities
  uuid: ^4.2.1
  crypto: ^3.0.3
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  firebase_auth_mocks: ^0.13.0

flutter:
  uses-material-design: true
  assets:
    - assets/config/
    - assets/sample_data/
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
EOF

# 2. Fix missing model classes
echo "🏗️ Creating missing model classes..."

# Create template models
mkdir -p lib/models/template
cat > lib/models/template/invoice_template_model.dart << 'EOF'
import 'package:flutter/material.dart';

class InvoiceTemplate {
  final String id;
  final String name;
  final String description;
  final TemplateColors colors;
  final TemplateStyle style;
  final TemplateLayout layout;
  final CompanyBranding branding;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.style,
    required this.layout,
    required this.branding,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  InvoiceTemplate copyWith({
    String? id,
    String? name,
    String? description,
    TemplateColors? colors,
    TemplateStyle? style,
    TemplateLayout? layout,
    CompanyBranding? branding,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colors: colors ?? this.colors,
      style: style ?? this.style,
      layout: layout ?? this.layout,
      branding: branding ?? this.branding,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TemplateColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final Color surface;
  final Color tableHeader;
  final Color border;

  const TemplateColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.surface,
    required this.tableHeader,
    required this.border,
  });

  // Legacy getters for backward compatibility
  Color get primaryColor => primary;
  Color get secondaryColor => secondary;
  Color get accentColor => accent;
  Color get textColor => textPrimary;
  Color get backgroundColor => background;
  Color get headerColor => surface;
  Color get borderColor => border;

  static const TemplateColors defaultColors = TemplateColors(
    primary: Color(0xFF2196F3),
    secondary: Color(0xFF03DAC6),
    accent: Color(0xFFFF5722),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F5),
    tableHeader: Color(0xFFE3F2FD),
    border: Color(0xFFE0E0E0),
  );

  TemplateColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? background,
    Color? surface,
    Color? tableHeader,
    Color? border,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? textColor,
    Color? backgroundColor,
    Color? headerColor,
    Color? borderColor,
  }) {
    return TemplateColors(
      primary: primary ?? primaryColor ?? this.primary,
      secondary: secondary ?? secondaryColor ?? this.secondary,
      accent: accent ?? accentColor ?? this.accent,
      textPrimary: textPrimary ?? textColor ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      background: background ?? backgroundColor ?? this.background,
      surface: surface ?? headerColor ?? this.surface,
      tableHeader: tableHeader ?? this.tableHeader,
      border: border ?? borderColor ?? this.border,
    );
  }
}

class TemplateStyle {
  final String name;
  final String description;

  const TemplateStyle({
    required this.name,
    required this.description,
  });
}

class TemplateLayout {
  final String name;
  final String description;

  const TemplateLayout({
    required this.name,
    required this.description,
  });
}

class CompanyBranding {
  final String companyName;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final String gstin;
  final String pan;
  final String email;
  final String phone;
  final String? website;
  final String? tagline;
  final String? logoPath;

  const CompanyBranding({
    required this.companyName,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.gstin,
    required this.pan,
    required this.email,
    required this.phone,
    this.website,
    this.tagline,
    this.logoPath,
  });

  CompanyBranding copyWith({
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? pinCode,
    String? country,
    String? gstin,
    String? pan,
    String? email,
    String? phone,
    String? website,
    String? tagline,
    String? logoPath,
  }) {
    return CompanyBranding(
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      country: country ?? this.country,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      tagline: tagline ?? this.tagline,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
EOF

# Create inventory models
mkdir -p lib/models/inventory
cat > lib/models/inventory/inventory_item_model.dart << 'EOF'
class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double costPrice;
  final double sellingPrice;
  final String unit;
  final int stockQuantity;
  final String? barcode;
  final String? description;
  final double? gstRate;
  final String? hsnCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.unit,
    required this.stockQuantity,
    this.barcode,
    this.description,
    this.gstRate,
    this.hsnCode,
    required this.createdAt,
    required this.updatedAt,
  });

  // Legacy getter for backward compatibility
  double get price => sellingPrice;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? costPrice,
    double? sellingPrice,
    String? unit,
    int? stockQuantity,
    String? barcode,
    String? description,
    double? gstRate,
    String? hsnCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      gstRate: gstRate ?? this.gstRate,
      hsnCode: hsnCode ?? this.hsnCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'barcode': barcode,
      'description': description,
      'gstRate': gstRate,
      'hsnCode': hsnCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      costPrice: json['costPrice']?.toDouble() ?? 0.0,
      sellingPrice: json['sellingPrice']?.toDouble() ?? 0.0,
      unit: json['unit'],
      stockQuantity: json['stockQuantity'] ?? 0,
      barcode: json['barcode'],
      description: json['description'],
      gstRate: json['gstRate']?.toDouble(),
      hsnCode: json['hsnCode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class InventoryCategory {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  const InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
EOF

# Create invoice models
cat > lib/models/invoice/invoice_model.dart << 'EOF'
import 'invoice_item_model.dart';
import 'invoice_status.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String customerGstin;
  final List<InvoiceItem> items;
  final double subtotal;
  final double cgstTotal;
  final double sgstTotal;
  final double igstTotal;
  final double cessTotal;
  final double grandTotal;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerGstin,
    required this.items,
    required this.subtotal,
    required this.cgstTotal,
    required this.sgstTotal,
    required this.igstTotal,
    required this.cessTotal,
    required this.grandTotal,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? customerGstin,
    List<InvoiceItem>? items,
    double? subtotal,
    double? cgstTotal,
    double? sgstTotal,
    double? igstTotal,
    double? cessTotal,
    double? grandTotal,
    InvoiceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGstin: customerGstin ?? this.customerGstin,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      cgstTotal: cgstTotal ?? this.cgstTotal,
      sgstTotal: sgstTotal ?? this.sgstTotal,
      igstTotal: igstTotal ?? this.igstTotal,
      cessTotal: cessTotal ?? this.cessTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Legacy alias for backward compatibility
typedef Invoice = InvoiceModel;
EOF

cat > lib/models/invoice/invoice_item_model.dart << 'EOF'
class InvoiceItem {
  final String id;
  final String name;
  final String description;
  final String hsnSacCode;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discount;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final double amount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;

  const InvoiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.hsnSacCode,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.discount,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
    required this.amount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
  });

  factory InvoiceItem.create({
    String? id,
    required String name,
    required String description,
    required String hsnSacCode,
    required double quantity,
    required String unit,
    required double unitPrice,
    required double discount,
    required double cgstRate,
    required double sgstRate,
    required double igstRate,
    required double cessRate,
    required bool isInterState,
  }) {
    final amount = (quantity * unitPrice) * (1 - discount / 100);
    final cgstAmount = isInterState ? 0.0 : amount * cgstRate / 100;
    final sgstAmount = isInterState ? 0.0 : amount * sgstRate / 100;
    final igstAmount = isInterState ? amount * igstRate / 100 : 0.0;
    final cessAmount = amount * cessRate / 100;
    final totalAmount = amount + cgstAmount + sgstAmount + igstAmount + cessAmount;

    return InvoiceItem(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      hsnSacCode: hsnSacCode,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      discount: discount,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      igstRate: igstRate,
      cessRate: cessRate,
      amount: amount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      cessAmount: cessAmount,
      totalAmount: totalAmount,
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    String? hsnSacCode,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discount,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
    double? amount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
    double? totalAmount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
      amount: amount ?? this.amount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
EOF

cat > lib/models/invoice/invoice_status.dart << 'EOF'
enum InvoiceStatus {
  draft,
  issued,
  paid,
  partiallyPaid,
  overdue,
  cancelled,
  void,
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.void:
        return 'Void';
    }
  }
}
EOF

# Create missing service files
echo "🔧 Creating missing service files..."

mkdir -p lib/services/import
cat > lib/services/import/data_import_service.dart << 'EOF'
import 'dart:io';
import '../../models/gst_returns/gstr1_model.dart';

class DataImportService {
  Future<GSTR1Model> importTallyData(File file) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
    
    return GSTR1Model(
      gstin: '27AAPFU0939F1ZV',
      returnPeriod: '032024',
      b2bInvoices: [],
      b2cInvoices: [],
      b2clInvoices: [],
      exportInvoices: [],
      cdnrInvoices: [],
      cdnurInvoices: [],
      exemptSupplies: [],
      nilSupplies: [],
      hsnSummary: [],
    );
  }

  Future<GSTR1Model> importMargData(File file) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
    
    return GSTR1Model(
      gstin: '27AAPFU0939F1ZV',
      returnPeriod: '032024',
      b2bInvoices: [],
      b2cInvoices: [],
      b2clInvoices: [],
      exportInvoices: [],
      cdnrInvoices: [],
      cdnurInvoices: [],
      exemptSupplies: [],
      nilSupplies: [],
      hsnSummary: [],
    );
  }
}
EOF

# Create HSN SAC provider
mkdir -p lib/providers
cat > lib/providers/hsn_sac_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/hsn_sac/hsn_sac_model.dart';

class HsnSacProvider extends ChangeNotifier {
  List<HsnSacModel> _codes = [];
  bool _isLoading = false;

  List<HsnSacModel> get codes => _codes;
  bool get isLoading => _isLoading;

  Future<List<HsnSacModel>> searchCodes(String query, {
    String? code,
    String? description,
    bool isSac = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock search implementation
      await Future.delayed(const Duration(seconds: 1));
      
      final results = <HsnSacModel>[
        HsnSacModel(
          code: isSac ? '998431' : '8471',
          description: isSac ? 'Information technology consultancy services' : 'Automatic data processing machines',
          gstRate: 18.0,
          isSac: isSac,
        ),
      ];

      _codes = results;
      return results;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Create reconciliation models
mkdir -p lib/models/reconciliation
cat > lib/models/reconciliation/reconciliation_result_model.dart << 'EOF'
class ReconciliationResult {
  final String id;
  final String type;
  final DateTime timestamp;
  final int matchedCount;
  final int unmatchedCount;
  final int errorCount;
  final List<ReconciliationDiscrepancy> discrepancies;
  final Map<String, dynamic> summary;

  const ReconciliationResult({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.matchedCount,
    required this.unmatchedCount,
    required this.errorCount,
    required this.discrepancies,
    required this.summary,
  });
}

class ReconciliationDiscrepancy {
  final String id;
  final String type;
  final String description;
  final String details;
  final String severity;
  final Map<String, dynamic> data;

  const ReconciliationDiscrepancy({
    required this.id,
    required this.type,
    required this.description,
    required this.details,
    required this.severity,
    required this.data,
  });
}

class ReconciliationState {
  final bool isLoading;
  final Map<String, ReconciliationResult> results;
  final String? error;

  const ReconciliationState({
    this.isLoading = false,
    this.results = const {},
    this.error,
  });
}
EOF

# Create GSTIN tracking provider
cat > lib/providers/gstin_tracking_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';

class GstinTrackingProvider extends ChangeNotifier {
  List<String> _recentPanSearches = [];

  List<String> get recentPanSearches => _recentPanSearches;

  Future<List<String>> getRecentPanSearches() async {
    return _recentPanSearches;
  }

  Future<void> addToRecentPanSearches(String pan) async {
    if (!_recentPanSearches.contains(pan)) {
      _recentPanSearches.insert(0, pan);
      if (_recentPanSearches.length > 10) {
        _recentPanSearches = _recentPanSearches.take(10).toList();
      }
      notifyListeners();
    }
  }
}
EOF

# Create validation service
mkdir -p lib/services/validation
cat > lib/services/validation/invoice_validation_service.dart << 'EOF'
import '../../models/invoice/invoice_model.dart';
import '../../models/validation/invoice_validation_result.dart';

class InvoiceValidationService {
  Future<InvoiceValidationResult> validateInvoiceData(InvoiceModel invoice) async {
    final issues = <ValidationIssue>[];
    
    // Basic validation
    if (invoice.customerName.isEmpty) {
      issues.add(ValidationIssue(
        field: 'customerName',
        message: 'Customer name is required',
        severity: ValidationSeverity.error,
      ));
    }
    
    if (invoice.items.isEmpty) {
      issues.add(ValidationIssue(
        field: 'items',
        message: 'At least one item is required',
        severity: ValidationSeverity.error,
      ));
    }
    
    return InvoiceValidationResult(
      isValid: issues.where((i) => i.severity == ValidationSeverity.error).isEmpty,
      issues: issues,
    );
  }
}
EOF

mkdir -p lib/models/validation
cat > lib/models/validation/invoice_validation_result.dart << 'EOF'
class InvoiceValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;

  const InvoiceValidationResult({
    required this.isValid,
    required this.issues,
  });
}

class ValidationIssue {
  final String field;
  final String message;
  final ValidationSeverity severity;

  const ValidationIssue({
    required this.field,
    required this.message,
    required this.severity,
  });

  @override
  String toString() => message;
}

enum ValidationSeverity {
  error,
  warning,
  info,
}
EOF

# Create custom text field widget
mkdir -p lib/widgets/common
cat > lib/widgets/common/custom_text_field.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  // Legacy parameters for backward compatibility
  final String? label;
  final String? hint;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    // Legacy parameters
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabelText = label ?? labelText;
    final effectiveHintText = hint ?? hintText;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: effectiveLabelText,
        hintText: effectiveHintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
EOF

# Create custom button widget
cat > lib/widgets/common/custom_button.dart << 'EOF'
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: child,
      ),
    );
  }
}
EOF

# 3. Run flutter commands to fix dependencies
echo "📦 Getting dependencies..."
flutter clean
flutter pub get

# 4. Fix linting issues with dart fix
echo "🔧 Applying automatic fixes..."
dart fix --apply

# 5. Create missing directories
echo "📁 Creating missing directories..."
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/config
mkdir -p assets/sample_data

# 6. Create placeholder files
echo "📄 Creating placeholder files..."
echo '{}' > assets/config/app_config.json
echo '[]' > assets/sample_data/sample_invoices.json

echo "✅ Comprehensive fix completed!"
echo ""
echo "📋 Summary of fixes applied:"
echo "  ✓ Fixed pubspec.yaml dependencies"
echo "  ✓ Created missing model classes"
echo "  ✓ Created missing service files"
echo "  ✓ Created missing provider classes"
echo "  ✓ Created custom widget components"
echo "  ✓ Applied automatic dart fixes"
echo "  ✓ Created missing asset directories"
echo ""
echo "🚀 Next steps:"
echo "  1. Run 'flutter pub get' to ensure all dependencies are installed"
echo "  2. Run 'flutter analyze' to check for remaining issues"
echo "  3. Run 'flutter build apk' to test the build"
echo ""
echo "⚠️  Note: Some widgets may still need manual fixes for specific business logic"
EOF

```bat file="scripts/fix_all_critical_errors_comprehensive.bat"
@echo off
echo 🔧 Starting comprehensive fix for Flutter Invoice App...

REM Create backup
echo 📦 Creating backup...
xcopy lib lib_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2% /E /I /Q

REM 1. Fix pubspec.yaml dependencies
echo 📝 Fixing pubspec.yaml dependencies...
(
echo name: flutter_invoice_app
echo description: A comprehensive GST invoice and tax management application for Indian businesses
echo publish_to: 'none'
echo version: 1.0.0+1
echo.
echo environment:
echo   sdk: '>=3.0.0 ^&lt;4.0.0'
echo   flutter: ">=3.10.0"
echo.
echo dependencies:
echo   flutter:
echo     sdk: flutter
echo.
echo   # Core dependencies
echo   cupertino_icons: ^1.0.6
echo   provider: ^6.1.1
echo   shared_preferences: ^2.2.2
echo   sqflite: ^2.3.0
echo   path: ^1.8.3
echo   intl: ^0.19.0
echo.
echo   # UI dependencies
echo   flutter_colorpicker: ^1.0.3
echo   qr_flutter: ^4.1.0
echo   image_picker: ^1.0.4
echo.
echo   # Payment dependencies
echo   flutter_stripe: ^10.1.1
echo   razorpay_flutter: ^1.3.6
echo.
echo   # State management
echo   flutter_bloc: ^8.1.3
echo.
echo   # File handling
echo   file_picker: ^6.1.1
echo   share_plus: ^7.2.1
echo   path_provider: ^2.1.1
echo.
echo   # PDF generation
echo   pdf: ^3.10.7
echo   printing: ^5.11.1
echo.
echo   # HTTP and API
echo   http: ^1.1.0
echo   dio: ^5.3.2
echo.
echo   # Firebase
echo   firebase_core: ^2.24.2
echo   firebase_auth: ^4.15.3
echo   cloud_firestore: ^4.13.6
echo   firebase_storage: ^11.5.6
echo.
echo   # Database
echo   hive: ^2.2.3
echo   hive_flutter: ^1.1.0
echo   supabase_flutter: ^2.0.0
echo.
echo   # Utilities
echo   uuid: ^4.2.1
echo   crypto: ^3.0.3
echo   connectivity_plus: ^5.0.2
echo.
echo dev_dependencies:
echo   flutter_test:
echo     sdk: flutter
echo   flutter_lints: ^3.0.1
echo   build_runner: ^2.4.7
echo   hive_generator: ^2.0.1
echo   firebase_auth_mocks: ^0.13.0
echo.
echo flutter:
echo   uses-material-design: true
echo   assets:
echo     - assets/config/
echo     - assets/sample_data/
echo   fonts:
echo     - family: Roboto
echo       fonts:
echo         - asset: fonts/Roboto-Regular.ttf
echo         - asset: fonts/Roboto-Bold.ttf
echo           weight: 700
) > pubspec.yaml

REM 2. Create missing directories
echo 📁 Creating missing directories...
if not exist "lib\models\template" mkdir lib\models\template
if not exist "lib\models\inventory" mkdir lib\models\inventory
if not exist "lib\models\invoice" mkdir lib\models\invoice
if not exist "lib\models\reconciliation" mkdir lib\models\reconciliation
if not exist "lib\models\validation" mkdir lib\models\validation
if not exist "lib\services\import" mkdir lib\services\import
if not exist "lib\services\validation" mkdir lib\services\validation
if not exist "lib\providers" mkdir lib\providers
if not exist "lib\widgets\common" mkdir lib\widgets\common
if not exist "assets\images" mkdir assets\images
if not exist "assets\icons" mkdir assets\icons
if not exist "assets\config" mkdir assets\config
if not exist "assets\sample_data" mkdir assets\sample_data

REM 3. Run flutter commands
echo 📦 Getting dependencies...
flutter clean
flutter pub get

REM 4. Apply automatic fixes
echo 🔧 Applying automatic fixes...
dart fix --apply

REM 5. Create placeholder files
echo 📄 Creating placeholder files...
echo {} > assets\config\app_config.json
echo [] > assets\sample_data\sample_invoices.json

echo ✅ Comprehensive fix completed!
echo.
echo 📋 Summary of fixes applied:
echo   ✓ Fixed pubspec.yaml dependencies
echo   ✓ Created missing directories
echo   ✓ Applied automatic dart fixes
echo   ✓ Created missing asset directories
echo.
echo 🚀 Next steps:
echo   1. Run 'flutter pub get' to ensure all dependencies are installed
echo   2. Run 'flutter analyze' to check for remaining issues
echo   3. Run 'flutter build apk' to test the build
echo.
echo ⚠️  Note: Some widgets may still need manual fixes for specific business logic

pause
