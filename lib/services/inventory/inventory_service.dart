import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory/inventory_item_model.dart';

class InventoryService {
  static const String _inventoryKey = 'inventory_items';
  static const String _categoriesKey = 'inventory_categories';

  // Sample inventory data
  static List<InventoryItem> _sampleInventory = [
    // Electronics
    InventoryItem(
      id: '1',
      name: 'Samsung Galaxy S23',
      category: 'Electronics',
      price: 75000.0,
      unit: 'Piece',
      stockQuantity: 25,
      barcode: '8901030895647',
      description: 'Latest Samsung smartphone with 256GB storage',
      gstRate: 18.0,
      hsnCode: '85171200',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '2',
      name: 'Apple iPhone 15',
      category: 'Electronics',
      price: 95000.0,
      unit: 'Piece',
      stockQuantity: 15,
      barcode: '8901030895648',
      description: 'Apple iPhone 15 with 128GB storage',
      gstRate: 18.0,
      hsnCode: '85171200',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '3',
      name: 'Dell Laptop Inspiron 15',
      category: 'Electronics',
      price: 55000.0,
      unit: 'Piece',
      stockQuantity: 10,
      barcode: '8901030895649',
      description: 'Dell Inspiron 15 with Intel i5 processor',
      gstRate: 18.0,
      hsnCode: '84713000',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    
    // Clothing
    InventoryItem(
      id: '4',
      name: 'Cotton T-Shirt',
      category: 'Clothing',
      price: 599.0,
      unit: 'Piece',
      stockQuantity: 100,
      barcode: '8901030895650',
      description: 'Premium cotton t-shirt, various sizes',
      gstRate: 12.0,
      hsnCode: '61091000',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '5',
      name: 'Denim Jeans',
      category: 'Clothing',
      price: 1299.0,
      unit: 'Piece',
      stockQuantity: 75,
      barcode: '8901030895651',
      description: 'Premium denim jeans, multiple sizes',
      gstRate: 12.0,
      hsnCode: '62034200',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
    ),
    
    // Food & Beverages
    InventoryItem(
      id: '6',
      name: 'Basmati Rice',
      category: 'Food & Beverages',
      price: 120.0,
      unit: 'Kg',
      stockQuantity: 500,
      barcode: '8901030895652',
      description: 'Premium basmati rice, 1kg pack',
      gstRate: 5.0,
      hsnCode: '10063000',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '7',
      name: 'Cooking Oil',
      category: 'Food & Beverages',
      price: 180.0,
      unit: 'Liter',
      stockQuantity: 200,
      barcode: '8901030895653',
      description: 'Refined sunflower oil, 1 liter',
      gstRate: 5.0,
      hsnCode: '15121100',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
    ),
    
    // Home & Garden
    InventoryItem(
      id: '8',
      name: 'LED Bulb 9W',
      category: 'Home & Garden',
      price: 150.0,
      unit: 'Piece',
      stockQuantity: 300,
      barcode: '8901030895654',
      description: 'Energy efficient LED bulb, 9 watts',
      gstRate: 18.0,
      hsnCode: '85395000',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '9',
      name: 'Garden Hose',
      category: 'Home & Garden',
      price: 899.0,
      unit: 'Piece',
      stockQuantity: 50,
      barcode: '8901030895655',
      description: '20 meter flexible garden hose',
      gstRate: 18.0,
      hsnCode: '39173900',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    
    // Books & Stationery
    InventoryItem(
      id: '10',
      name: 'Notebook A4',
      category: 'Books & Stationery',
      price: 45.0,
      unit: 'Piece',
      stockQuantity: 500,
      barcode: '8901030895656',
      description: 'A4 size ruled notebook, 200 pages',
      gstRate: 12.0,
      hsnCode: '48201000',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '11',
      name: 'Ball Pen',
      category: 'Books & Stationery',
      price: 15.0,
      unit: 'Piece',
      stockQuantity: 1000,
      barcode: '8901030895657',
      description: 'Blue ink ball pen',
      gstRate: 18.0,
      hsnCode: '96081000',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    
    // Sports & Fitness
    InventoryItem(
      id: '12',
      name: 'Cricket Bat',
      category: 'Sports & Fitness',
      price: 2500.0,
      unit: 'Piece',
      stockQuantity: 20,
      barcode: '8901030895658',
      description: 'Professional cricket bat, English willow',
      gstRate: 18.0,
      hsnCode: '95066200',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '13',
      name: 'Yoga Mat',
      category: 'Sports & Fitness',
      price: 799.0,
      unit: 'Piece',
      stockQuantity: 40,
      barcode: '8901030895659',
      description: 'Non-slip yoga mat, 6mm thickness',
      gstRate: 18.0,
      hsnCode: '95069990',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    
    // Automotive
    InventoryItem(
      id: '14',
      name: 'Engine Oil 5W-30',
      category: 'Automotive',
      price: 450.0,
      unit: 'Liter',
      stockQuantity: 100,
      barcode: '8901030895660',
      description: 'Synthetic engine oil, 1 liter',
      gstRate: 28.0,
      hsnCode: '27101981',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    InventoryItem(
      id: '15',
      name: 'Car Air Freshener',
      category: 'Automotive',
      price: 99.0,
      unit: 'Piece',
      stockQuantity: 200,
      barcode: '8901030895661',
      description: 'Long lasting car air freshener',
      gstRate: 28.0,
      hsnCode: '33074900',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<InventoryCategory> _sampleCategories = [
    InventoryCategory(id: '1', name: 'Electronics', description: 'Electronic devices and gadgets', icon: 'phone'),
    InventoryCategory(id: '2', name: 'Clothing', description: 'Apparel and fashion items', icon: 'shirt'),
    InventoryCategory(id: '3', name: 'Food & Beverages', description: 'Food items and drinks', icon: 'food'),
    InventoryCategory(id: '4', name: 'Home & Garden', description: 'Home improvement and garden items', icon: 'home'),
    InventoryCategory(id: '5', name: 'Books & Stationery', description: 'Books, notebooks and stationery', icon: 'book'),
    InventoryCategory(id: '6', name: 'Sports & Fitness', description: 'Sports equipment and fitness gear', icon: 'sports'),
    InventoryCategory(id: '7', name: 'Automotive', description: 'Car accessories and parts', icon: 'car'),
  ];

  Future<List<InventoryItem>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_inventoryKey);
    
    if (itemsJson == null) {
      // Initialize with sample data
      await _initializeSampleData();
      return _sampleInventory;
    }
    
    final List<dynamic> itemsList = json.decode(itemsJson);
    return itemsList.map((item) => InventoryItem.fromJson(item)).toList();
  }

  Future<List<InventoryCategory>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    
    if (categoriesJson == null) {
      await _initializeSampleCategories();
      return _sampleCategories;
    }
    
    final List<dynamic> categoriesList = json.decode(categoriesJson);
    return categoriesList.map((category) => InventoryCategory.fromJson(category)).toList();
  }

  Future<void> _initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(_sampleInventory.map((item) => item.toJson()).toList());
    await prefs.setString(_inventoryKey, itemsJson);
  }

  Future<void> _initializeSampleCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(_sampleCategories.map((category) => category.toJson()).toList());
    await prefs.setString(_categoriesKey, categoriesJson);
  }

  Future<void> addItem(InventoryItem item) async {
    final items = await getAllItems();
    items.add(item);
    await _saveItems(items);
  }

  Future<void> updateItem(InventoryItem item) async {
    final items = await getAllItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
      await _saveItems(items);
    }
  }

  Future<void> deleteItem(String itemId) async {
    final items = await getAllItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveItems(items);
  }

  Future<void> _saveItems(List<InventoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_inventoryKey, itemsJson);
  }

  Future<List<InventoryItem>> searchItems(String query) async {
    final items = await getAllItems();
    return items.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.category.toLowerCase().contains(query.toLowerCase()) ||
        (item.barcode?.contains(query) ?? false) ||
        (item.hsnCode?.contains(query) ?? false)
    ).toList();
  }

  Future<List<InventoryItem>> getItemsByCategory(String category) async {
    final items = await getAllItems();
    return items.where((item) => item.category == category).toList();
  }

  Future<InventoryItem?> getItemByBarcode(String barcode) async {
    final items = await getAllItems();
    try {
      return items.firstWhere((item) => item.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStock(String itemId, int newQuantity) async {
    final items = await getAllItems();
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(
        stockQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await _saveItems(items);
    }
  }
}
