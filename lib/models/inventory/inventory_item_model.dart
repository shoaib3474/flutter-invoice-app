import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'inventory_item_model.g.dart';

@HiveType(typeId: 3)
class InventoryItem extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String unit;
  
  @HiveField(5)
  final double sellingPrice;
  
  @HiveField(6)
  final double costPrice;
  
  @HiveField(7)
  final int stockQuantity;
  
  @HiveField(8)
  final int minStockLevel;
  
  @HiveField(9)
  final String? hsnCode;
  
  @HiveField(10)
  final String? sacCode;
  
  @HiveField(11)
  final double taxRate;
  
  @HiveField(12)
  final String? barcode;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.unit,
    required this.sellingPrice,
    required this.costPrice,
    required this.stockQuantity,
    this.minStockLevel = 10,
    this.hsnCode,
    this.sacCode,
    this.taxRate = 18.0,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.create({
    required String name,
    required String description,
    required String category,
    required String unit,
    required double sellingPrice,
    required double costPrice,
    required int stockQuantity,
    int minStockLevel = 10,
    String? hsnCode,
    String? sacCode,
    double taxRate = 18.0,
    String? barcode,
  }) {
    final now = DateTime.now();
    return InventoryItem(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      unit: unit,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      hsnCode: hsnCode,
      sacCode: sacCode,
      taxRate: taxRate,
      barcode: barcode,
      createdAt: now,
      updatedAt: now,
    );
  }

  bool get isLowStock => stockQuantity <= minStockLevel;
  bool get isOutOfStock => stockQuantity <= 0;
  double get profitMargin => sellingPrice - costPrice;
  double get profitPercentage => (profitMargin / costPrice) * 100;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        unit,
        sellingPrice,
        costPrice,
        stockQuantity,
        minStockLevel,
        hsnCode,
        sacCode,
        taxRate,
        barcode,
        createdAt,
        updatedAt,
      ];

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? unit,
    double? sellingPrice,
    double? costPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? hsnCode,
    String? sacCode,
    double? taxRate,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      hsnCode: hsnCode ?? this.hsnCode,
      sacCode: sacCode ?? this.sacCode,
      taxRate: taxRate ?? this.taxRate,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'unit': unit,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'hsnCode': hsnCode,
      'sacCode': sacCode,
      'taxRate': taxRate,
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      minStockLevel: json['minStockLevel'] as int? ?? 10,
      hsnCode: json['hsnCode'] as String?,
      sacCode: json['sacCode'] as String?,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 18.0,
      barcode: json['barcode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
