import 'package:uuid/uuid.dart';

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
  
  // Calculated fields
  final double taxableValue;
  final double totalBeforeTax;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAfterTax;

  // Legacy property for compatibility
  double get rate => unitPrice;

  InvoiceItem({
    String? id,
    required this.name,
    this.description = '',
    required this.hsnSacCode,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discount = 0,
    this.cgstRate = 0,
    this.sgstRate = 0,
    this.igstRate = 0,
    this.cessRate = 0,
    required this.taxableValue,
    required this.totalBeforeTax,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAfterTax,
  }) : id = id ?? const Uuid().v4();

  factory InvoiceItem.create({
    required String name,
    String description = '',
    required String hsnSacCode,
    required double quantity,
    required String unit,
    required double unitPrice,
    double discount = 0,
    required double cgstRate,
    required double sgstRate,
    required double igstRate,
    double cessRate = 0,
    required bool isInterState,
  }) {
    final baseAmount = unitPrice * quantity;
    final discountAmount = baseAmount * discount / 100;
    final taxableValue = baseAmount - discountAmount;
    
    final cgstAmount = isInterState ? 0 : taxableValue * cgstRate / 100;
    final sgstAmount = isInterState ? 0 : taxableValue * sgstRate / 100;
    final igstAmount = isInterState ? taxableValue * igstRate / 100 : 0;
    final cessAmount = taxableValue * cessRate / 100;
    
    final totalAfterTax = taxableValue + cgstAmount + sgstAmount + igstAmount + cessAmount;

    return InvoiceItem(
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
      taxableValue: taxableValue,
      totalBeforeTax: taxableValue,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      cessAmount: cessAmount,
      totalAfterTax: totalAfterTax,
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
  }) {
    return InvoiceItem.create(
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
      isInterState: igstRate > 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hsnSacCode': hsnSacCode,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discount': discount,
      'cgstRate': cgstRate,
      'sgstRate': sgstRate,
      'igstRate': igstRate,
      'cessRate': cessRate,
      'taxableValue': taxableValue,
      'totalBeforeTax': totalBeforeTax,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'cessAmount': cessAmount,
      'totalAfterTax': totalAfterTax,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      hsnSacCode: json['hsnSacCode'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'],
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      cgstRate: json['cgstRate']?.toDouble() ?? 0.0,
      sgstRate: json['sgstRate']?.toDouble() ?? 0.0,
      igstRate: json['igstRate']?.toDouble() ?? 0.0,
      cessRate: json['cessRate']?.toDouble() ?? 0.0,
      taxableValue: json['taxableValue']?.toDouble() ?? 0.0,
      totalBeforeTax: json['totalBeforeTax']?.toDouble() ?? 0.0,
      cgstAmount: json['cgstAmount']?.toDouble() ?? 0.0,
      sgstAmount: json['sgstAmount']?.toDouble() ?? 0.0,
      igstAmount: json['igstAmount']?.toDouble() ?? 0.0,
      cessAmount: json['cessAmount']?.toDouble() ?? 0.0,
      totalAfterTax: json['totalAfterTax']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'InvoiceItem(id: $id, name: $name, quantity: $quantity, unitPrice: $unitPrice, totalAfterTax: $totalAfterTax)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
