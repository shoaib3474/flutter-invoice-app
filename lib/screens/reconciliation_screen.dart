import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/providers/reconciliation_provider.dart';
import 'package:flutter_invoice_app/widgets/reconciliation/reconciliation_details_widget.dart';
import 'package:flutter_invoice_app/widgets/reconciliation/reconciliation_selector_widget.dart';
import 'package:flutter_invoice_app/widgets/reconciliation/reconciliation_summary_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({Key? key}) : super(key: key);

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  ReconciliationType _selectedType = ReconciliationType.gstr1VsGstr2a;
  String _gstin = '';
  String _period = '';
  bool _showResults = false;
  
  final _gstinController = TextEditingController();
  final _periodController = TextEditingController();
  
  @override
  void dispose() {
    _gstinController.dispose();
    _periodController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final reconciliationProvider = Provider.of<ReconciliationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Reconciliation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              // Navigate to reconciliation history screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReconciliationSelectorWidget(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                  _showResults = false;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reconciliation Parameters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gstinController,
                            decoration: const InputDecoration(
                              labelText: 'GSTIN',
                              hintText: 'Enter your GSTIN',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _periodController,
                            decoration: const InputDecoration(
                              labelText: 'Period',
                              hintText: 'e.g., Apr-Jun 2023',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: reconciliationProvider.isLoading
                            ? null
                            : () => _performReconciliation(reconciliationProvider),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: reconciliationProvider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Perform Reconciliation'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (reconciliationProvider.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                width: double.infinity,
                child: Text(
                  reconciliationProvider.error!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            
            if (_showResults && reconciliationProvider.selectedResult != null)
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Summary'),
                          Tab(text: 'Details'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Summary tab
                            SingleChildScrollView(
                              child: ReconciliationSummaryWidget(
                                reconciliationResult: reconciliationProvider.selectedResult!,
                                onExport: () => _exportReconciliation(
                                  context,
                                  reconciliationProvider,
                                  reconciliationProvider.selectedResult!.id,
                                ),
                                onDelete: () => _deleteReconciliation(
                                  context,
                                  reconciliationProvider,
                                  reconciliationProvider.selectedResult!.id,
                                ),
                              ),
                            ),
                            
                            // Details tab
                            ReconciliationDetailsWidget(
                              reconciliationResult: reconciliationProvider.selectedResult!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _performReconciliation(ReconciliationProvider provider) async {
    setState(() {
      _gstin = _gstinController.text.trim();
      _period = _periodController.text.trim();
    });
    
    if (_gstin.isEmpty || _period.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter GSTIN and period')),
      );
      return;
    }
    
    try {
      switch (_selectedType) {
        case ReconciliationType.gstr1VsGstr2a:
          await provider.reconcileGSTR1WithGSTR2A(_gstin, _period);
          break;
        case ReconciliationType.gstr1VsGstr3b:
          await provider.reconcileGSTR1WithGSTR3B(_gstin, _period);
          break;
        case ReconciliationType.gstr2aVsGstr2b:
          await provider.reconcileGSTR2AWithGSTR2B(_gstin, _period);
          break;
        case ReconciliationType.gstr2bVsGstr3b:
          await provider.reconcileGSTR2BWithGSTR3B(_gstin, _period);
          break;
        case ReconciliationType.comprehensive:
          await provider.performComprehensiveReconciliation(_gstin, _period);
          break;
      }
      
      setState(() {
        _showResults = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _exportReconciliation(
    BuildContext context,
    ReconciliationProvider provider,
    String id,
  ) async {
    try {
      final jsonData = await provider.exportReconciliationToJson(id);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/reconciliation_$id.json');
      await file.writeAsString(jsonData);
      
      // Share the file
      await Share.shareFiles(
        [file.path],
        text: 'GST Reconciliation Result',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _deleteReconciliation(
    BuildContext context,
    ReconciliationProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reconciliation'),
        content: const Text('Are you sure you want to delete this reconciliation result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await provider.deleteReconciliationResult(id);
        setState(() {
          _showResults = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: ${e.toString()}')),
        );
      }
    }
  }
}
