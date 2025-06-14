// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static const String _customerPrefix = 'customers_';
  static const String _itemPrefix = 'items_';
  static const String _invoicePrefix = 'invoices_';
  static const String _purchasePrefix = 'purchases_';
  static const String _paymentPrefix = 'payments_';
  static const String _ledgerPrefix = 'ledger_';
  static const String _settingsKey = 'app_settings';
  static const String _businessInfoKey = 'business_info';

  // Generic storage methods
  static void setItem(String key, String value) {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    }
  }

  static String? getItem(String key) {
    if (kIsWeb) {
      return html.window.localStorage[key];
    }
    return null;
  }

  static void removeItem(String key) {
    if (kIsWeb) {
      html.window.localStorage.remove(key);
    }
  }

  static void clear() {
    if (kIsWeb) {
      html.window.localStorage.clear();
    }
  }

  // JSON storage methods
  static void setJson(String key, Map<String, dynamic> data) {
    setItem(key, jsonEncode(data));
  }

  static Map<String, dynamic>? getJson(String key) {
    final value = getItem(key);
    if (value != null) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error parsing JSON for key $key: $e');
        return null;
      }
    }
    return null;
  }

  // List storage methods
  static void setJsonList(String key, List<Map<String, dynamic>> data) {
    setItem(key, jsonEncode(data));
  }

  static List<Map<String, dynamic>> getJsonList(String key) {
    final value = getItem(key);
    if (value != null) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        debugPrint('Error parsing JSON list for key $key: $e');
      }
    }
    return [];
  }

  // Customer methods
  static void saveCustomer(Map<String, dynamic> customer) {
    final customerId = customer['id'] ?? customer['mobile'];
    setJson('$_customerPrefix$customerId', customer);
  }

  static Map<String, dynamic>? getCustomer(String customerId) {
    return getJson('$_customerPrefix$customerId');
  }

  static Map<String, dynamic>? getCustomerByMobile(String mobile) {
    return getJson('$_customerPrefix$mobile');
  }

  static List<Map<String, dynamic>> getAllCustomers() {
    final customers = <Map<String, dynamic>>[];
    if (kIsWeb) {
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_customerPrefix)) {
          final customer = getJson(key);
          if (customer != null) {
            customers.add(customer);
          }
        }
      }
    }
    return customers;
  }

  static void deleteCustomer(String customerId) {
    removeItem('$_customerPrefix$customerId');
  }

  // Item methods
  static void saveItem(Map<String, dynamic> item) {
    final itemId = item['id'] ?? item['code'];
    setJson('$_itemPrefix$itemId', item);
  }

  static Map<String, dynamic>? getItems(String itemId) {
    return getJson('$_itemPrefix$itemId');
  }

  static List<Map<String, dynamic>> getAllItems() {
    final items = <Map<String, dynamic>>[];
    if (kIsWeb) {
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_itemPrefix)) {
          final item = getJson(key);
          if (item != null) {
            items.add(item);
          }
        }
      }
    }
    return items;
  }

  static void deleteItem(String itemId) {
    removeItem('$_itemPrefix$itemId');
  }

  // Invoice methods
  static void saveInvoice(Map<String, dynamic> invoice) {
    final invoiceId = invoice['id'] ?? invoice['invoiceNumber'];
    setJson('$_invoicePrefix$invoiceId', invoice);
  }

  static Map<String, dynamic>? getInvoice(String invoiceId) {
    return getJson('$_invoicePrefix$invoiceId');
  }

  static List<Map<String, dynamic>> getAllInvoices() {
    final invoices = <Map<String, dynamic>>[];
    if (kIsWeb) {
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_invoicePrefix)) {
          final invoice = getJson(key);
          if (invoice != null) {
            invoices.add(invoice);
          }
        }
      }
    }
    return invoices;
  }

  static void deleteInvoice(String invoiceId) {
    removeItem('$_invoicePrefix$invoiceId');
  }

  // Purchase methods
  static void savePurchase(Map<String, dynamic> purchase) {
    final purchaseId = purchase['id'] ?? purchase['invoiceNumber'];
    setJson('$_purchasePrefix$purchaseId', purchase);
  }

  static Map<String, dynamic>? getPurchase(String purchaseId) {
    return getJson('$_purchasePrefix$purchaseId');
  }

  static List<Map<String, dynamic>> getAllPurchases() {
    final purchases = <Map<String, dynamic>>[];
    if (kIsWeb) {
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_purchasePrefix)) {
          final purchase = getJson(key);
          if (purchase != null) {
            purchases.add(purchase);
          }
        }
      }
    }
    return purchases;
  }

  // Payment methods
  static void savePayment(Map<String, dynamic> payment) {
    final paymentId =
        payment['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    setJson('$_paymentPrefix$paymentId', payment);
  }

  static List<Map<String, dynamic>> getAllPayments() {
    final payments = <Map<String, dynamic>>[];
    if (kIsWeb) {
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_paymentPrefix)) {
          final payment = getJson(key);
          if (payment != null) {
            payments.add(payment);
          }
        }
      }
    }
    return payments;
  }

  // Ledger methods
  static void updateCustomerLedger(
      String customerId, Map<String, dynamic> ledgerEntry) {
    final ledgerKey = '$_ledgerPrefix$customerId';
    final existingLedger = getJsonList(ledgerKey);
    existingLedger.add(ledgerEntry);
    setJsonList(ledgerKey, existingLedger);
  }

  static List<Map<String, dynamic>> getCustomerLedger(String customerId) {
    return getJsonList('$_ledgerPrefix$customerId');
  }

  static double getCustomerBalance(String customerId) {
    final ledger = getCustomerLedger(customerId);
    double balance = 0.0;
    for (final entry in ledger) {
      final amount = (entry['amount'] as num?)?.toDouble() ?? 0.0;
      final type = entry['type'] as String? ?? 'debit';
      if (type == 'debit') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    return balance;
  }

  // Settings methods
  static void saveSettings(Map<String, dynamic> settings) {
    setJson(_settingsKey, settings);
  }

  static Map<String, dynamic> getSettings() {
    return getJson(_settingsKey) ?? {};
  }

  // Business info methods
  static void saveBusinessInfo(Map<String, dynamic> businessInfo) {
    setJson(_businessInfoKey, businessInfo);
  }

  static Map<String, dynamic> getBusinessInfo() {
    return getJson(_businessInfoKey) ?? {};
  }

  // Export/Import methods
  static Map<String, dynamic> exportAllData() {
    return {
      'customers': getAllCustomers(),
      'items': getAllItems(),
      'invoices': getAllInvoices(),
      'purchases': getAllPurchases(),
      'payments': getAllPayments(),
      'settings': getSettings(),
      'businessInfo': getBusinessInfo(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  static void importAllData(Map<String, dynamic> data) {
    // Clear existing data
    clear();

    // Import customers
    final customers = data['customers'] as List<dynamic>? ?? [];
    for (final customer in customers) {
      if (customer is Map<String, dynamic>) {
        saveCustomer(customer);
      }
    }

    // Import items
    final items = data['items'] as List<dynamic>? ?? [];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        saveItem(item);
      }
    }

    // Import invoices
    final invoices = data['invoices'] as List<dynamic>? ?? [];
    for (final invoice in invoices) {
      if (invoice is Map<String, dynamic>) {
        saveInvoice(invoice);
      }
    }

    // Import purchases
    final purchases = data['purchases'] as List<dynamic>? ?? [];
    for (final purchase in purchases) {
      if (purchase is Map<String, dynamic>) {
        savePurchase(purchase);
      }
    }

    // Import payments
    final payments = data['payments'] as List<dynamic>? ?? [];
    for (final payment in payments) {
      if (payment is Map<String, dynamic>) {
        savePayment(payment);
      }
    }

    // Import settings
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    if (settings.isNotEmpty) {
      saveSettings(settings);
    }

    // Import business info
    final businessInfo = data['businessInfo'] as Map<String, dynamic>? ?? {};
    if (businessInfo.isNotEmpty) {
      saveBusinessInfo(businessInfo);
    }
  }

  // Storage statistics
  static Map<String, int> getStorageStats() {
    return {
      'customers': getAllCustomers().length,
      'items': getAllItems().length,
      'invoices': getAllInvoices().length,
      'purchases': getAllPurchases().length,
      'payments': getAllPayments().length,
    };
  }

  // Clear specific data types
  static void clearCustomers() {
    if (kIsWeb) {
      final keysToRemove = <String>[];
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_customerPrefix)) {
          keysToRemove.add(key);
        }
      }
      for (final key in keysToRemove) {
        removeItem(key);
      }
    }
  }

  static void clearInvoices() {
    if (kIsWeb) {
      final keysToRemove = <String>[];
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(_invoicePrefix)) {
          keysToRemove.add(key);
        }
      }
      for (final key in keysToRemove) {
        removeItem(key);
      }
    }
  }
}
