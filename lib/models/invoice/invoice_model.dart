// ignore_for_file: always_put_required_named_parameters_first, avoid_equals_and_hash_code_on_mutable_classes, avoid_unused_constructor_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'invoice_item_model.dart';
import 'invoice_status.dart';
import 'invoice_type.dart';

class Invoice {
  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.customerAddress,
    this.customerGstin,
    required this.customerState,
    required this.customerStateCode,
    required this.placeOfSupply,
    required this.placeOfSupplyCode,
    this.invoiceType = InvoiceType.sales,
    required this.items,
    required this.subtotal,
    required this.cgstTotal,
    required this.sgstTotal,
    required this.igstTotal,
    required this.cessTotal,
    required this.totalTax,
    required this.grandTotal,
    this.status = InvoiceStatus.draft,
    this.notes = '',
    this.termsAndConditions = '',
    this.isReverseCharge = false,
    this.isInterState = false,
    this.isB2B = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdBy,
    required double taxAmount,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      customerGstin: json['customerGstin'],
      customerState: json['customerState'],
      customerStateCode: json['customerStateCode'],
      placeOfSupply: json['placeOfSupply'],
      placeOfSupplyCode: json['placeOfSupplyCode'],
      invoiceType: InvoiceType.values.firstWhere(
        (e) => e.name == json['invoiceType'],
        orElse: () => InvoiceType.sales,
      ),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      cgstTotal: json['cgstTotal']?.toDouble() ?? 0.0,
      sgstTotal: json['sgstTotal']?.toDouble() ?? 0.0,
      igstTotal: json['igstTotal']?.toDouble() ?? 0.0,
      cessTotal: json['cessTotal']?.toDouble() ?? 0.0,
      totalTax: json['totalTax']?.toDouble() ?? 0.0,
      grandTotal: json['grandTotal']?.toDouble() ?? 0.0,
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      notes: json['notes'] ?? '',
      termsAndConditions: json['termsAndConditions'] ?? '',
      isReverseCharge: json['isReverseCharge'] ?? false,
      isInterState: json['isInterState'] ?? false,
      isB2B: json['isB2B'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      taxAmount: json['totalTax']?.toDouble() ?? 0.0,
    );
  }

  factory Invoice.create({
    required String invoiceNumber,
    required DateTime invoiceDate,
    required DateTime dueDate,
    required String customerName,
    required String customerGstin,
    required String customerAddress,
    required String customerState,
    required int customerStateCode,
    required String placeOfSupply,
    required int placeOfSupplyCode,
    required InvoiceType invoiceType,
    required List<InvoiceItem> items,
    required String notes,
    required String termsAndConditions,
    required bool isReverseCharge,
    required String createdBy,
  }) {
    double subtotal = 0;
    double cgstTotal = 0;
    double sgstTotal = 0;
    double igstTotal = 0;
    double cessTotal = 0;

    for (final item in items) {
      subtotal += item.totalBeforeTax;
      cgstTotal += item.cgstAmount;
      sgstTotal += item.sgstAmount;
      igstTotal += item.igstAmount;
      cessTotal += item.cessAmount;
    }

    final totalTax = cgstTotal + sgstTotal + igstTotal + cessTotal;
    final grandTotal = subtotal + totalTax;
    final isInterState = customerStateCode != placeOfSupplyCode;

    return Invoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      customerName: customerName,
      customerEmail: '', // Default empty email
      customerAddress: customerAddress,
      customerGstin: customerGstin,
      customerState: customerState,
      customerStateCode: customerStateCode,
      placeOfSupply: placeOfSupply,
      placeOfSupplyCode: placeOfSupplyCode,
      invoiceType: invoiceType,
      items: items,
      subtotal: subtotal,
      cgstTotal: cgstTotal,
      sgstTotal: sgstTotal,
      igstTotal: igstTotal,
      cessTotal: cessTotal,
      totalTax: totalTax,
      grandTotal: grandTotal,
      notes: notes,
      termsAndConditions: termsAndConditions,
      isReverseCharge: isReverseCharge,
      isInterState: isInterState,
      createdBy: createdBy,
      taxAmount: totalTax,
    );
  }
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String customerAddress;
  final String? customerGstin;
  final String customerState;
  final int customerStateCode;
  final String placeOfSupply;
  final int placeOfSupplyCode;
  final InvoiceType invoiceType;
  final List<InvoiceItem> items;
  final double subtotal;
  final double cgstTotal;
  final double sgstTotal;
  final double igstTotal;
  final double cessTotal;
  final double totalTax;
  final double grandTotal;
  final InvoiceStatus status;
  final String notes;
  final String termsAndConditions;
  final bool isReverseCharge;
  final bool isInterState;
  final bool isB2B;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  // Legacy properties for compatibility
  double get taxAmount => totalTax;
  double get total => grandTotal;
  DateTime get date => invoiceDate;

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? customerGstin,
    String? customerState,
    int? customerStateCode,
    String? placeOfSupply,
    int? placeOfSupplyCode,
    InvoiceType? invoiceType,
    List<InvoiceItem>? items,
    double? subtotal,
    double? cgstTotal,
    double? sgstTotal,
    double? igstTotal,
    double? cessTotal,
    double? totalTax,
    double? grandTotal,
    InvoiceStatus? status,
    String? notes,
    String? termsAndConditions,
    bool? isReverseCharge,
    bool? isInterState,
    bool? isB2B,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGstin: customerGstin ?? this.customerGstin,
      customerState: customerState ?? this.customerState,
      customerStateCode: customerStateCode ?? this.customerStateCode,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      placeOfSupplyCode: placeOfSupplyCode ?? this.placeOfSupplyCode,
      invoiceType: invoiceType ?? this.invoiceType,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      cgstTotal: cgstTotal ?? this.cgstTotal,
      sgstTotal: sgstTotal ?? this.sgstTotal,
      igstTotal: igstTotal ?? this.igstTotal,
      cessTotal: cessTotal ?? this.cessTotal,
      totalTax: totalTax ?? this.totalTax,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      isReverseCharge: isReverseCharge ?? this.isReverseCharge,
      isInterState: isInterState ?? this.isInterState,
      isB2B: isB2B ?? this.isB2B,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      taxAmount: totalTax ?? this.totalTax,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerGstin': customerGstin,
      'customerState': customerState,
      'customerStateCode': customerStateCode,
      'placeOfSupply': placeOfSupply,
      'placeOfSupplyCode': placeOfSupplyCode,
      'invoiceType': invoiceType.name,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'cgstTotal': cgstTotal,
      'sgstTotal': sgstTotal,
      'igstTotal': igstTotal,
      'cessTotal': cessTotal,
      'totalTax': totalTax,
      'grandTotal': grandTotal,
      'status': status.name,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'isReverseCharge': isReverseCharge,
      'isInterState': isInterState,
      'isB2B': isB2B,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  @override
  String toString() {
    return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, customerName: $customerName, grandTotal: $grandTotal, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static Future<Invoice?> fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) async {}

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
