import 'package:hive_flutter/hive_flutter.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/customer/customer_model.dart';
import '../../models/template/invoice_template_model.dart';
import '../../models/inventory/inventory_item_model.dart';

class HiveStorageService {
  static late Box<InvoiceModel> _invoiceBox;
  static late Box<Customer> _customerBox;
  static late Box<InvoiceTemplate> _templateBox;
  static late Box<InventoryItem> _inventoryBox;
  static late Box _settingsBox;
  static late Box _appDataBox;

  static Future<void> initialize() async {
    _invoiceBox = Hive.box<InvoiceModel>('invoices');
    _customerBox = Hive.box<Customer>('customers');
    _templateBox = Hive.box<InvoiceTemplate>('templates');
    _inventoryBox = Hive.box<InventoryItem>('inventory');
    _settingsBox = Hive.box('settings');
    _appDataBox = Hive.box('app_data');
  }

  // Invoice operations
  static Future<void> saveInvoice(InvoiceModel invoice) async {
    await _invoiceBox.put(invoice.id, invoice);
  }

  static InvoiceModel? getInvoice(String id) {
    return _invoiceBox.get(id);
  }

  static List<InvoiceModel> getAllInvoices() {
    return _invoiceBox.values.toList();
  }

  static Future<void> deleteInvoice(String id) async {
    await _invoiceBox.delete(id);
  }

  static List<InvoiceModel> getInvoicesByCustomer(String customerId) {
    return _invoiceBox.values
        .where((invoice) => invoice.customerName.contains(customerId))
        .toList();
  }

  static List<InvoiceModel> getInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoiceBox.values
        .where((invoice) => 
            invoice.invoiceDate.isAfter(start) && 
            invoice.invoiceDate.isBefore(end))
        .toList();
  }

  // Customer operations
  static Future<void> saveCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  static Customer? getCustomer(String id) {
    return _customerBox.get(id);
  }

  static List<Customer> getAllCustomers() {
    return _customerBox.values.toList();
  }

  static Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }

  static List<Customer> searchCustomers(String query) {
    return _customerBox.values
        .where((customer) => 
            customer.name.toLowerCase().contains(query.toLowerCase()) ||
            (customer.mobile?.contains(query) ?? false) ||
            (customer.email?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  // Template operations
  static Future<void> saveTemplate(InvoiceTemplate template) async {
    await _templateBox.put(template.id, template);
  }

  static InvoiceTemplate? getTemplate(String id) {
    return _templateBox.get(id);
  }

  static List<InvoiceTemplate> getAllTemplates() {
    return _templateBox.values.toList();
  }

  static Future<void> deleteTemplate(String id) async {
    await _templateBox.delete(id);
  }

  static InvoiceTemplate? getDefaultTemplate() {
    final templates = getAllTemplates();
    try {
      return templates.firstWhere((template) => template.isDefault);
    } catch (e) {
      return templates.isNotEmpty ? templates.first : null;
    }
  }

  // Inventory operations
  static Future<void> saveInventoryItem(InventoryItem item) async {
    await _inventoryBox.put(item.id, item);
  }

  static InventoryItem? getInventoryItem(String id) {
    return _inventoryBox.get(id);
  }

  static List<InventoryItem> getAllInventoryItems() {
    return _inventoryBox.values.toList();
  }

  static Future<void> deleteInventoryItem(String id) async {
    await _inventoryBox.delete(id);
  }

  static List<InventoryItem> searchInventoryItems(String query) {
    return _inventoryBox.values
        .where((item) => 
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase()) ||
            (item.barcode?.contains(query) ?? false))
        .toList();
  }

  static List<InventoryItem> getLowStockItems(int threshold) {
    return _inventoryBox.values
        .where((item) => item.stockQuantity < threshold)
        .toList();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  static Map<String, dynamic> getAllSettings() {
    return Map<String, dynamic>.from(_settingsBox.toMap());
  }

  // App data operations
  static Future<void> saveAppData(String key, dynamic value) async {
    await _appDataBox.put(key, value);
  }

  static T? getAppData<T>(String key, {T? defaultValue}) {
    return _appDataBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteAppData(String key) async {
    await _appDataBox.delete(key);
  }

  // Backup and restore
  static Map<String, dynamic> exportAllData() {
    return {
      'invoices': _invoiceBox.values.map((e) => e.toJson()).toList(),
      'customers': _customerBox.values.map((e) => e.toJson()).toList(),
      'templates': _templateBox.values.map((e) => e.toJson()).toList(),
      'inventory': _inventoryBox.values.map((e) => e.toJson()).toList(),
      'settings': _settingsBox.toMap(),
      'appData': _appDataBox.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'appName': 'iTaxInvoice',
      'company': 'Itax Easy Pvt Ltd',
    };
  }

  static Future<void> importAllData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllData();

    // Import invoices
    if (data['invoices'] != null) {
      for (var invoiceData in data['invoices']) {
        final invoice = InvoiceModel.fromJson(invoiceData);
        await saveInvoice(invoice);
      }
    }

    // Import customers
    if (data['customers'] != null) {
      for (var customerData in data['customers']) {
        final customer = Customer.fromJson(customerData);
        await saveCustomer(customer);
      }
    }

    // Import templates
    if (data['templates'] != null) {
      for (var templateData in data['templates']) {
        final template = InvoiceTemplate.fromJson(templateData);
        await saveTemplate(template);
      }
    }

    // Import inventory
    if (data['inventory'] != null) {
      for (var itemData in data['inventory']) {
        final item = InventoryItem.fromJson(itemData);
        await saveInventoryItem(item);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      for (var entry in (data['settings'] as Map).entries) {
        await saveSetting(entry.key, entry.value);
      }
    }

    // Import app data
    if (data['appData'] != null) {
      for (var entry in (data['appData'] as Map).entries) {
        await saveAppData(entry.key, entry.value);
      }
    }
  }

  static Future<void> clearAllData() async {
    await _invoiceBox.clear();
    await _customerBox.clear();
    await _templateBox.clear();
    await _inventoryBox.clear();
    await _settingsBox.clear();
    await _appDataBox.clear();
  }

  // Statistics
  static Map<String, int> getDataStatistics() {
    return {
      'totalInvoices': _invoiceBox.length,
      'totalCustomers': _customerBox.length,
      'totalTemplates': _templateBox.length,
      'totalInventoryItems': _inventoryBox.length,
      'totalSettings': _settingsBox.length,
    };
  }

  // Database health check
  static bool isDatabaseHealthy() {
    try {
      _invoiceBox.isOpen;
      _customerBox.isOpen;
      _templateBox.isOpen;
      _inventoryBox.isOpen;
      _settingsBox.isOpen;
      _appDataBox.isOpen;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Close all boxes (call this when app is closing)
  static Future<void> closeAll() async {
    await _invoiceBox.close();
    await _customerBox.close();
    await _templateBox.close();
    await _inventoryBox.close();
    await _settingsBox.close();
    await _appDataBox.close();
  }
}
