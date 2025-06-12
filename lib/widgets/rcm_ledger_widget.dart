import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ledger_models.dart';
import '../services/ledger_service.dart';

class RCMLedgerWidget extends StatefulWidget {
  const RCMLedgerWidget({
    super.key,
    required this.ledgerService,
  });

  final LedgerService ledgerService;

  @override
  State<RCMLedgerWidget> createState() => _RCMLedgerWidgetState();
}

class _RCMLedgerWidgetState extends State<RCMLedgerWidget> {
  List<RCMLedgerEntry> _entries = [];
  bool _isLoading = true;
  String _selectedPaymentStatus = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final entries = await widget.ledgerService.getRCMLedgerEntries();
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading RCM ledger entries: $e')),
        );
      }
    }
  }
  
  List<RCMLedgerEntry> _getFilteredEntries() {
    if (_selectedPaymentStatus == 'All') {
      return _entries;
    }
    
    return _entries.where((entry) => entry.status == _selectedPaymentStatus).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Filter by Payment Status: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedPaymentStatus,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentStatus = value!;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
                onPressed: () {
                  // Navigate to add entry screen
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.import_export),
                label: const Text('Import/Export'),
                onPressed: () {
                  // Show import/export dialog
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredEntries.isEmpty
                  ? const Center(child: Text('No RCM ledger entries found'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Tax Type')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredEntries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(entry.date))),
                              DataCell(Text(entry.description)),
                              DataCell(Text(entry.taxType)),
                              DataCell(Text('₹${entry.amount.toStringAsFixed(2)}')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(entry.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    entry.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(entry.category)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigate to edit entry screen
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _showDeleteConfirmation(entry);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(RCMLedgerEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Are you sure you want to delete this RCM ledger entry?\n\n${entry.description}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEntry(entry);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(RCMLedgerEntry entry) {
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RCM ledger entry deleted successfully')),
    );
  }
}
