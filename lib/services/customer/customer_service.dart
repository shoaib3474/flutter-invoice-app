import 'dart:convert';
import '../../models/customer/customer_model.dart';
import '../../utils/local_storage_mock.dart';

class CustomerService {
  static const String _customersKey = 'customers';

  // Sample customer data
  static final List<Customer> _sampleCustomers = [
    Customer(
      id: '1',
      name: 'Rajesh Kumar',
      mobile: '9876543210',
      email: 'rajesh@example.com',
      address: '123 MG Road, Bangalore, Karnataka 560001',
      gstin: '29ABCDE1234F1Z5',
      panNumber: 'ABCDE1234F',
      type: CustomerType.wholesale,
      creditLimit: 50000,
      currentBalance: 15000,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: '2',
      name: 'Priya Sharma',
      mobile: '9876543211',
      email: 'priya@example.com',
      address: '456 Brigade Road, Bangalore, Karnataka 560025',
      type: CustomerType.retail,
      creditLimit: 10000,
      currentBalance: 2500,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: '3',
      name: 'Amit Patel',
      mobile: '9876543212',
      email: 'amit@example.com',
      address: '789 Commercial Street, Bangalore, Karnataka 560001',
      gstin: '29FGHIJ5678K1L2',
      panNumber: 'FGHIJ5678K',
      type: CustomerType.distributor,
      creditLimit: 100000,
      currentBalance: 35000,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: '4',
      name: 'Sunita Reddy',
      mobile: '9876543213',
      email: 'sunita@example.com',
      address: '321 Koramangala, Bangalore, Karnataka 560034',
      type: CustomerType.regular,
      creditLimit: 5000,
      currentBalance: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: '5',
      name: 'Vikram Singh',
      mobile: '9876543214',
      email: 'vikram@example.com',
      address: '654 Indiranagar, Bangalore, Karnataka 560038',
      gstin: '29MNOPQ9012R3S4',
      panNumber: 'MNOPQ9012R',
      type: CustomerType.wholesale,
      creditLimit: 75000,
      currentBalance: 22000,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<Customer>> getAllCustomers() async {
    final prefs = await LocalStorageMock.getInstance();
    final customersJson = prefs.getString(_customersKey);

    if (customersJson == null) {
      await _initializeSampleData();
      return _sampleCustomers;
    }

    final List<dynamic> customersList = json.decode(customersJson);
    return customersList.map((customer) => Customer.fromJson(customer)).toList();
  }

  Future<void> _initializeSampleData() async {
    final prefs = await LocalStorageMock.getInstance();
    final customersJson = json.encode(_sampleCustomers.map((customer) => customer.toJson()).toList());
    await prefs.setString(_customersKey, customersJson);
  }

  Future<void> addCustomer(Customer customer) async {
    final customers = await getAllCustomers();
    customers.add(customer);
    await _saveCustomers(customers);
  }

  Future<void> updateCustomer(Customer customer) async {
    final customers = await getAllCustomers();
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      await _saveCustomers(customers);
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    final customers = await getAllCustomers();
    customers.removeWhere((customer) => customer.id == customerId);
    await _saveCustomers(customers);
  }

  Future<void> _saveCustomers(List<Customer> customers) async {
    final prefs = await LocalStorageMock.getInstance();
    final customersJson = json.encode(customers.map((customer) => customer.toJson()).toList());
    await prefs.setString(_customersKey, customersJson);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final customers = await getAllCustomers();
    return customers.where((customer) =>
        customer.name.toLowerCase().contains(query.toLowerCase()) ||
        (customer.mobile?.contains(query) ?? false) ||
        (customer.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (customer.gstin?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  Future<Customer?> getCustomerByMobile(String mobile) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.mobile == mobile);
    } catch (e) {
      return null;
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCustomerBalance(String customerId, double newBalance) async {
    final customers = await getAllCustomers();
    final index = customers.indexWhere((customer) => customer.id == customerId);
    if (index != -1) {
      customers[index] = customers[index].copyWith(
        currentBalance: newBalance,
        updatedAt: DateTime.now(),
      );
      await _saveCustomers(customers);
    }
  }

  Future<List<Customer>> getCustomersByType(CustomerType type) async {
    final customers = await getAllCustomers();
    return customers.where((customer) => customer.type == type).toList();
  }
}
