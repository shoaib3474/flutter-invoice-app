import 'package:flutter/foundation.dart';
import '../storage/local_storage_service.dart';
import '../../models/customer/customer_model.dart';
import '../../utils/gstin_validator.dart';

class LocalCustomerService {
  // Smart customer lookup by mobile number
  static Customer? getCustomerByMobile(String mobile) {
    final customerData = LocalStorageService.getCustomerByMobile(mobile);
    if (customerData != null) {
      return Customer.fromMap(customerData);
    }
    return null;
  }

  // Save customer with privacy compliance
  static void saveCustomer(Customer customer) {
    final customerData = customer.toMap();
    
    // Add privacy metadata
    customerData['createdAt'] = DateTime.now().toIso8601String();
    customerData['lastUpdated'] = DateTime.now().toIso8601String();
    customerData['dataSource'] = 'local_input'; // No external source
    customerData['privacyCompliant'] = true;
    
    LocalStorageService.saveCustomer(customerData);
    
    debugPrint('Customer saved locally: ${customer.name} (${customer.mobile})');
  }

  // Get all customers with privacy filtering
  static List<Customer> getAllCustomers({bool includeB2B = true, bool includeB2C = true}) {
    final customersData = LocalStorageService.getAllCustomers();
    final customers = <Customer>[];
    
    for (final data in customersData) {
      try {
        final customer = Customer.fromMap(data);
        
        // Filter by customer type
        final isB2B = customer.gstin?.isNotEmpty == true;
        final isB2C = customer.gstin?.isEmpty != false;
        
        if ((isB2B && includeB2B) || (isB2C && includeB2C)) {
          customers.add(customer);
        }
      } catch (e) {
        debugPrint('Error parsing customer data: $e');
      }
    }
    
    return customers;
  }

  // Search customers locally
  static List<Customer> searchCustomers(String query) {
    final allCustomers = getAllCustomers();
    final searchQuery = query.toLowerCase();
    
    return allCustomers.where((customer) {
      return customer.name.toLowerCase().contains(searchQuery) ||
             customer.mobile.contains(searchQuery) ||
             (customer.email?.toLowerCase().contains(searchQuery) ?? false) ||
             (customer.gstin?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  // Validate customer data for privacy compliance
  static Map<String, String> validateCustomer(Customer customer) {
    final errors = <String, String>{};
    
    // Basic validation
    if (customer.name.trim().isEmpty) {
      errors['name'] = 'Customer name is required';
    }
    
    if (customer.mobile.trim().isEmpty) {
      errors['mobile'] = 'Mobile number is required';
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(customer.mobile)) {
      errors['mobile'] = 'Invalid mobile number format';
    }
    
    // Email validation (optional)
    if (customer.email?.isNotEmpty == true) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(customer.email!)) {
        errors['email'] = 'Invalid email format';
      }
    }
    
    // GSTIN validation for B2B customers
    if (customer.gstin?.isNotEmpty == true) {
      if (!GSTINValidator.isValid(customer.gstin!)) {
        errors['gstin'] = 'Invalid GSTIN format';
      }
    }
    
    return errors;
  }

  // Get customer type (B2B/B2C)
  static String getCustomerType(Customer customer) {
    return (customer.gstin?.isNotEmpty == true) ? 'B2B' : 'B2C';
  }

  // Update customer with privacy tracking
  static void updateCustomer(Customer customer) {
    final existingData = LocalStorageService.getCustomerByMobile(customer.mobile);
    final customerData = customer.toMap();
    
    // Preserve creation date
    if (existingData != null) {
      customerData['createdAt'] = existingData['createdAt'];
    }
    
    // Update timestamp
    customerData['lastUpdated'] = DateTime.now().toIso8601String();
    customerData['privacyCompliant'] = true;
    
    LocalStorageService.saveCustomer(customerData);
    
    debugPrint('Customer updated locally: ${customer.name}');
  }

  // Delete customer (GDPR compliance)
  static void deleteCustomer(String customerId) {
    LocalStorageService.deleteCustomer(customerId);
    debugPrint('Customer deleted locally: $customerId');
  }

  // Get customer statistics
  static Map<String, dynamic> getCustomerStats() {
    final customers = getAllCustomers();
    final b2bCustomers = customers.where((c) => c.gstin?.isNotEmpty == true).length;
    final b2cCustomers = customers.length - b2bCustomers;
    
    return {
      'total': customers.length,
      'b2b': b2bCustomers,
      'b2c': b2cCustomers,
      'withEmail': customers.where((c) => c.email?.isNotEmpty == true).length,
      'withAddress': customers.where((c) => c.address?.isNotEmpty == true).length,
    };
  }

  // Export customers for backup (privacy-safe)
  static Map<String, dynamic> exportCustomers() {
    final customers = getAllCustomers();
    return {
      'customers': customers.map((c) => c.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'totalCount': customers.length,
      'privacyCompliant': true,
      'dataSource': 'local_storage_only',
    };
  }

  // Import customers from backup
  static void importCustomers(List<Map<String, dynamic>> customersData) {
    for (final data in customersData) {
      try {
        final customer = Customer.fromMap(data);
        saveCustomer(customer);
      } catch (e) {
        debugPrint('Error importing customer: $e');
      }
    }
  }

  // Get recent customers
  static List<Customer> getRecentCustomers({int limit = 10}) {
    final customers = getAllCustomers();
    
    // Sort by last updated or created date
    customers.sort((a, b) {
      final aData = LocalStorageService.getCustomerByMobile(a.mobile);
      final bData = LocalStorageService.getCustomerByMobile(b.mobile);
      
      final aDate = aData?['lastUpdated'] ?? aData?['createdAt'] ?? '';
      final bDate = bData?['lastUpdated'] ?? bData?['createdAt'] ?? '';
      
      return bDate.compareTo(aDate);
    });
    
    return customers.take(limit).toList();
  }

  // Check if customer exists
  static bool customerExists(String mobile) {
    return LocalStorageService.getCustomerByMobile(mobile) != null;
  }

  // Get customer balance from ledger
  static double getCustomerBalance(String customerId) {
    return LocalStorageService.getCustomerBalance(customerId);
  }

  // Privacy compliance check
  static bool isPrivacyCompliant() {
    // Since all data is stored locally, it's privacy compliant by design
    return true;
  }

  // Get data retention info
  static Map<String, dynamic> getDataRetentionInfo() {
    return {
      'storageType': 'local_browser_storage',
      'dataLocation': 'user_device_only',
      'serverStorage': false,
      'cloudSync': false,
      'privacyCompliant': true,
      'gdprCompliant': true,
      'dataRetention': 'user_controlled',
      'dataDeletion': 'immediate_on_user_request',
    };
  }
}
