import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/firestore_model.dart';

class Product extends FirestoreModel {
  final String name;
  final String description;
  final String hsnSacCode;
  final String unit;
  final double salePrice;
  final double purchasePrice;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final String category;
  final String? subcategory;
  final String? imageUrl;
  final double openingStock;
  final double currentStock;
  final double minimumStock;
  final bool isActive;
  final bool isService;
  final String? barcode;
  final String? sku;
  final String? manufacturer;
  final String? brand;
  final String? model;
  final String? size;
  final String? color;
  final double? weight;
  final String? weightUnit;
  final String? dimensions;
  final String? notes;
  
  Product({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    required this.name,
    required this.description,
    required this.hsnSacCode,
    required this.unit,
    required this.salePrice,
    required this.purchasePrice,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
    required this.category,
    this.subcategory,
    this.imageUrl,
    required this.openingStock,
    required this.currentStock,
    required this.minimumStock,
    required this.isActive,
    required this.isService,
    this.barcode,
    this.sku,
    this.manufacturer,
    this.brand,
    this.model,
    this.size,
    this.color,
    this.weight,
    this.weightUnit,
    this.dimensions,
    this.notes,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
  );
  
  factory Product.create({
    required String name,
    required String hsnSacCode,
    required String unit,
    required double salePrice,
    required double purchasePrice,
    required double cgstRate,
    required double sgstRate,
    required double igstRate,
    required double cessRate,
    required String category,
    String description = '',
    String? subcategory,
    String? imageUrl,
    double openingStock = 0.0,
    double minimumStock = 0.0,
    bool isService = false,
    String createdBy = '',
  }) {
    final now = DateTime.now();
    final id = FirebaseFirestore.instance.collection('products').doc().id;
    
    return Product(
      id: id,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      name: name,
      description: description,
      hsnSacCode: hsnSacCode,
      unit: unit,
      salePrice: salePrice,
      purchasePrice: purchasePrice,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      igstRate: igstRate,
      cessRate: cessRate,
      category: category,
      subcategory: subcategory,
      imageUrl: imageUrl,
      openingStock: openingStock,
      currentStock: openingStock,
      minimumStock: minimumStock,
      isActive: true,
      isService: isService,
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hsn_sac_code': hsnSacCode,
      'unit': unit,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'cgst_rate': cgstRate,
      'sgst_rate': sgstRate,
      'igst_rate': igstRate,
      'cess_rate': cessRate,
      'category': category,
      'subcategory': subcategory,
      'image_url': imageUrl,
      'opening_stock': openingStock,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'is_active': isActive,
      'is_service': isService,
      'barcode': barcode,
      'sku': sku,
      'manufacturer': manufacturer,
      'brand': brand,
      'model': model,
      'size': size,
      'color': color,
      'weight': weight,
      'weight_unit': weightUnit,
      'dimensions': dimensions,
      'notes': notes,
    };
  }
  
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      createdAt: FirestoreModel.timestampToDateTime(data['created_at']),
      updatedAt: FirestoreModel.timestampToDateTime(data['updated_at']),
      createdBy: data['created_by'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      hsnSacCode: data['hsn_sac_code'] ?? '',
      unit: data['unit'] ?? '',
      salePrice: data['sale_price']?.toDouble() ?? 0.0,
      purchasePrice: data['purchase_price']?.toDouble() ?? 0.0,
      cgstRate: data['cgst_rate']?.toDouble() ?? 0.0,
      sgstRate: data['sgst_rate']?.toDouble() ?? 0.0,
      igstRate: data['igst_rate']?.toDouble() ?? 0.0,
      cessRate: data['cess_rate']?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      imageUrl: data['image_url'],
      openingStock: data['opening_stock']?.toDouble() ?? 0.0,
      currentStock: data['current_stock']?.toDouble() ?? 0.0,
      minimumStock: data['minimum_stock']?.toDouble() ?? 0.0,
      isActive: data['is_active'] ?? true,
      isService: data['is_service'] ?? false,
      barcode: data['barcode'],
      sku: data['sku'],
      manufacturer: data['manufacturer'],
      brand: data['brand'],
      model: data['model'],
      size: data['size'],
      color: data['color'],
      weight: data['weight']?.toDouble(),
      weightUnit: data['weight_unit'],
      dimensions: data['dimensions'],
      notes: data['notes'],
    );
  }
  
  Product copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? name,
    String? description,
    String? hsnSacCode,
    String? unit,
    double? salePrice,
    double? purchasePrice,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
    String? category,
    String? subcategory,
    String? imageUrl,
    double? openingStock,
    double? currentStock,
    double? minimumStock,
    bool? isActive,
    bool? isService,
    String? barcode,
    String? sku,
    String? manufacturer,
    String? brand,
    String? model,
    String? size,
    String? color,
    double? weight,
    String? weightUnit,
    String? dimensions,
    String? notes,
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      description: description ?? this.description,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      unit: unit ?? this.unit,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrl: imageUrl ?? this.imageUrl,
      openingStock: openingStock ?? this.openingStock,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      isActive: isActive ?? this.isActive,
      isService: isService ?? this.isService,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      manufacturer: manufacturer ?? this.manufacturer,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      size: size ?? this.size,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      dimensions: dimensions ?? this.dimensions,
      notes: notes ?? this.notes,
    );
  }
}
