import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_app/models/ledger_models.dart';
import 'package:invoice_app/services/ledger_service.dart';

class ElectronicLedgerWidget extends StatefulWidget {
  final LedgerService ledgerService;
  
  const ElectronicLedgerWidget({
    Key? key,
    required this.ledgerService,
  }) : super(key: key);

  @override
  _ElectronicLedgerWidgetState createState() => _ElectronicLedgerWidgetState();
}

class _ElectronicLedgerWidgetState extends State<ElectronicLedgerWidget> {
  List<ElectronicLedgerEntry> _entries = [];
  bool _isLoading = true;
  String _selectedTaxType = 'All';
  String _selectedTransactionType = 'All';
  
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
      final entries = await widget.ledgerService.getElectronicLedgerEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading electronic ledger entries: $e')),
      );
    }
  }
  
  List<ElectronicLedgerEntry> _getFilteredEntries() {
    var filteredEntries = _entries;
    
    if (_selectedTaxType != 'All') {
      filteredEntries = filteredEntries.where((entry) => entry.taxType == _selectedTaxType).toList();
    }
    
    if (_selectedTransactionType != 'All') {
      filteredEntries = filteredEntries.where((entry) => entry.transactionType == _selectedTransactionType).toList();
    }
    
    return filteredEntries;
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('Tax Type: '),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedTaxType,
                items: [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'IGST', child: Text('IGST')),
                  DropdownMenuItem(value: 'CGST', child: Text('CGST')),
                  DropdownMenuItem(value: 'SGST', child: Text('SGST')),
                  DropdownMenuItem(value: 'CESS', child: Text('CESS')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTaxType = value!;
                  });
                },
              ),
              SizedBox(width: 16),
              Text('Transaction Type: '),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedTransactionType,
                items: [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                  DropdownMenuItem(value: 'Debit', child: Text('Debit')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTransactionType = value!;
                  });
                },
              ),
              Spacer(),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Entry'),
                onPressed: () {
                  // Navigate to add entry screen
                },
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.import_export),
                label: Text('Import/Export'),
                onPressed: () {
                  // Show import/export dialog
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredEntries.isEmpty
                  ? Center(child: Text('No electronic ledger entries found'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Transaction Type')),
                          DataColumn(label: Text('Tax Type')),
                          DataColumn(label: Text('Source')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Reference No.')),
                          DataColumn(label: Text('Opening Balance')),
                          DataColumn(label: Text('Closing Balance')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredEntries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(entry.date))),
                              DataCell(Text(entry.description)),
                              DataCell(Text(entry.transactionType)),
                              DataCell(Text(entry.taxType)),
                              DataCell(Text(entry.source)),
                              DataCell(Text('₹${entry.amount.toStringAsFixed(2)}')),
                              DataCell(Text(entry.referenceNumber)),
                              DataCell(Text('₹${entry.openingBalance.toStringAsFixed(2)}')),
                              DataCell(Text('₹${entry.closingBalance.toStringAsFixed(2)}')),
                              DataCell(Text(entry.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigate to edit entry screen
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Show delete confirmation dialog
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
}
