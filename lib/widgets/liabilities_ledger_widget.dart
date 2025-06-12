import 'package:flutter/material.dart';
import '../models/ledger_models.dart';
import '../services/ledger_service.dart';

class LiabilitiesLedgerWidget extends StatefulWidget {
  const LiabilitiesLedgerWidget({
    super.key,
    required this.gstin,
  });

  final String gstin;

  @override
  State<LiabilitiesLedgerWidget> createState() => _LiabilitiesLedgerWidgetState();
}

class _LiabilitiesLedgerWidgetState extends State<LiabilitiesLedgerWidget> {
  final LedgerService _ledgerService = LedgerService();
  
  List<LiabilitiesLedgerEntry> _entries = [];
  bool _isLoading = false;
  String? _selectedTaxType;
  String? _selectedStatus;
  
  final List<String> _taxTypes = const ['All', 'CGST', 'SGST', 'IGST', 'CESS'];
  final List<String> _statuses = const ['All', 'Pending', 'Paid', 'Overdue'];

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
      final entries = await _ledgerService.getLiabilitiesLedgerEntries(
        taxType: _selectedTaxType == 'All' ? null : _selectedTaxType,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
      );
      
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liabilities Ledger',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Filters
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Tax Type:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  child: DropdownButton<String>(
                    value: null,
                    hint: Text('Select Tax Type'),
                    isExpanded: true,
                    items: [],
                    onChanged: null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: null,
                    hint: Text('Select Status'),
                    isExpanded: true,
                    items: [],
                    onChanged: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Entries List
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_entries.isEmpty)
              const Center(
                child: Text('No entries found'),
              )
            else
              Column(
                children: const [
                  Row(
                    children: [
                      Expanded(child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Tax Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Divider(),
                ],
              ),
            
            // Summary
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total Liabilities:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹0.00',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
