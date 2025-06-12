import 'package:flutter/material.dart';
import '../../models/customer/customer_model.dart';
import '../../services/customer/customer_service.dart';
import '../../widgets/customer/customer_card.dart';
import '../../widgets/customer/add_customer_dialog.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  String _searchQuery = '';
  CustomerType? _selectedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customers: $e')),
        );
      }
    }
  }

  List<Customer> get _filteredCustomers {
    var filtered = _customers;
    
    if (_selectedType != null) {
      filtered = filtered.where((customer) => customer.type == _selectedType).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) =>
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (customer.mobile?.contains(_searchQuery) ?? false) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                _buildTypeFilter(),
                _buildCustomerStats(),
                Expanded(child: _buildCustomerList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search customers by name, mobile, or email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTypeChip(null, 'All'),
          ...CustomerType.values.map((type) => _buildTypeChip(type, type.displayName)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(CustomerType? type, String label) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedType = type);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.green[100],
        checkmarkColor: Colors.green[600],
      ),
    );
  }

  Widget _buildCustomerStats() {
    final totalCustomers = _customers.length;
    final totalBalance = _customers.fold<double>(0, (sum, customer) => sum + customer.currentBalance);
    final totalCreditLimit = _customers.fold<double>(0, (sum, customer) => sum + customer.creditLimit);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Customers', totalCustomers.toString(), Icons.people),
          _buildStatItem('Outstanding', '₹${totalBalance.toStringAsFixed(0)}', Icons.account_balance_wallet),
          _buildStatItem('Credit Limit', '₹${totalCreditLimit.toStringAsFixed(0)}', Icons.credit_card),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    final filteredCustomers = _filteredCustomers;
    
    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return CustomerCard(
          customer: customer,
          onEdit: () => _showEditCustomerDialog(customer),
          onDelete: () => _deleteCustomer(customer),
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCustomerDialog(
        onSave: (customer) async {
          await _customerService.addCustomer(customer);
          _loadCustomers();
        },
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AddCustomerDialog(
        customer: customer,
        onSave: (updatedCustomer) async {
          await _customerService.updateCustomer(updatedCustomer);
          _loadCustomers();
        },
      ),
    );
  }

  void _deleteCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _customerService.deleteCustomer(customer.id);
              _loadCustomers();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
