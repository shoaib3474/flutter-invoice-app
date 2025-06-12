import 'package:flutter/material.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_status.dart';
import '../../repositories/invoice_repository.dart';
import 'invoice_detail_screen.dart';
import 'invoice_form_screen.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/invoice/invoice_list_item_widget.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final InvoiceRepository _invoiceRepository = InvoiceRepository();
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  InvoiceStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would fetch from a repository
      // For now, we'll create some dummy data
      _invoices = _createDummyInvoices();
      
      // Apply filters
      _applyFilters();
    } catch (e) {
      _showErrorSnackbar('Failed to load invoices: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Invoice> filteredInvoices = List.from(_invoices);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredInvoices = filteredInvoices.where((invoice) {
        return invoice.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply status filter
    if (_statusFilter != null) {
      filteredInvoices = filteredInvoices.where((invoice) {
        return invoice.status == _statusFilter;
      }).toList();
    }
    
    setState(() {
      _invoices = filteredInvoices;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToInvoiceDetail(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoice: invoice),
      ),
    ).then((_) => _loadInvoices());
  }

  void _navigateToCreateInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(),
      ),
    ).then((_) => _loadInvoices());
  }

  void _navigateToEditInvoice(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(invoice: invoice),
      ),
    ).then((_) => _loadInvoices());
  }

  void _deleteInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice #${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would delete from a repository
              setState(() {
                _invoices.removeWhere((item) => item.id == invoice.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search invoices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
          if (_statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Filtered by: '),
                  Chip(
                    label: Text(_getStatusText(_statusFilter!)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _statusFilter = null;
                      });
                      _loadInvoices();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _invoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No invoices found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your first invoice by tapping the + button',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _navigateToCreateInvoice,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Invoice'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInvoices,
                        child: ListView.builder(
                          itemCount: _invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _invoices[index];
                            return InvoiceListItem(
                              invoice: invoice,
                              onTap: () => _navigateToInvoiceDetail(invoice),
                              onEdit: () => _navigateToEditInvoice(invoice),
                              onDelete: () => _deleteInvoice(invoice),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateInvoice,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Invoices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Invoices'),
              leading: Radio<InvoiceStatus?>(
                value: null,
                groupValue: _statusFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadInvoices();
                },
              ),
            ),
            ...InvoiceStatus.values.map((status) => ListTile(
              title: Text(_getStatusText(status)),
              leading: Radio<InvoiceStatus?>(
                value: status,
                groupValue: _statusFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadInvoices();
                },
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.void:
        return 'Void';
      default:
        return 'Unknown';
    }
  }

  // Create dummy invoices for testing
  List<Invoice> _createDummyInvoices() {
    final now = DateTime.now();
    
    return [
      Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        invoiceDate: now.subtract(const Duration(days: 30)),
        dueDate: now.subtract(const Duration(days: 15)),
        customerName: 'ABC Corporation',
        customerEmail: 'abc@example.com',
        customerGstin: '27AADCB2230M1ZP',
        customerAddress: '123 Business Street, Mumbai',
        customerState: 'Maharashtra',
        customerStateCode: 27,
        placeOfSupply: 'Maharashtra',
        placeOfSupplyCode: 27,
        items: [],
        status: InvoiceStatus.paid,
        subtotal: 10000,
        cgstTotal: 900,
        sgstTotal: 900,
        igstTotal: 0,
        cessTotal: 0,
        totalTax: 1800,
        grandTotal: 11800,
        createdBy: 'user1',
      ),
      Invoice(
        id: '2',
        invoiceNumber: 'INV-002',
        invoiceDate: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 5)),
        customerName: 'XYZ Enterprises',
        customerEmail: 'xyz@example.com',
        customerGstin: '29AADCX1234Y1ZP',
        customerAddress: '456 Commerce Road, Bangalore',
        customerState: 'Karnataka',
        customerStateCode: 29,
        placeOfSupply: 'Karnataka',
        placeOfSupplyCode: 29,
        items: [],
        status: InvoiceStatus.paid,
        subtotal: 15000,
        cgstTotal: 1350,
        sgstTotal: 1350,
        igstTotal: 0,
        cessTotal: 0,
        totalTax: 2700,
        grandTotal: 17700,
        createdBy: 'user1',
      ),
      Invoice(
        id: '3',
        invoiceNumber: 'INV-003',
        invoiceDate: now.subtract(const Duration(days: 10)),
        dueDate: now.add(const Duration(days: 5)),
        customerName: 'PQR Limited',
        customerEmail: 'pqr@example.com',
        customerGstin: '07AADCP5678Z1ZP',
        customerAddress: '789 Business Hub, Delhi',
        customerState: 'Delhi',
        customerStateCode: 7,
        placeOfSupply: 'Maharashtra',
        placeOfSupplyCode: 27,
        items: [],
        status: InvoiceStatus.issued,
        subtotal: 20000,
        cgstTotal: 0,
        sgstTotal: 0,
        igstTotal: 3600,
        cessTotal: 0,
        totalTax: 3600,
        grandTotal: 23600,
        isInterState: true,
        createdBy: 'user1',
      ),
      Invoice(
        id: '4',
        invoiceNumber: 'INV-004',
        invoiceDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 10)),
        customerName: 'LMN Services',
        customerEmail: 'lmn@example.com',
        customerGstin: '33AADCL9876A1ZP',
        customerAddress: '321 Tech Park, Chennai',
        customerState: 'Tamil Nadu',
        customerStateCode: 33,
        placeOfSupply: 'Tamil Nadu',
        placeOfSupplyCode: 33,
        items: [],
        status: InvoiceStatus.draft,
        subtotal: 5000,
        cgstTotal: 450,
        sgstTotal: 450,
        igstTotal: 0,
        cessTotal: 0,
        totalTax: 900,
        grandTotal: 5900,
        createdBy: 'user1',
      ),
      Invoice(
        id: '5',
        invoiceNumber: 'INV-005',
        invoiceDate: now.subtract(const Duration(days: 45)),
        dueDate: now.subtract(const Duration(days: 15)),
        customerName: 'EFG Traders',
        customerEmail: 'efg@example.com',
        customerGstin: '',
        customerAddress: '654 Market Street, Jaipur',
        customerState: 'Rajasthan',
        customerStateCode: 8,
        placeOfSupply: 'Rajasthan',
        placeOfSupplyCode: 8,
        items: [],
        status: InvoiceStatus.overdue,
        subtotal: 3000,
        cgstTotal: 270,
        sgstTotal: 270,
        igstTotal: 0,
        cessTotal: 0,
        totalTax: 540,
        grandTotal: 3540,
        isB2B: false,
        createdBy: 'user1',
      ),
    ];
  }
}
