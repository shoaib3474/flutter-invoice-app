import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/providers/reconciliation_provider.dart';
import 'package:flutter_invoice_app/screens/reconciliation_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReconciliationHistoryScreen extends StatefulWidget {
  const ReconciliationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReconciliationHistoryScreen> createState() => _ReconciliationHistoryScreenState();
}

class _ReconciliationHistoryScreenState extends State<ReconciliationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReconciliationProvider>(context, listen: false)
          .loadAllReconciliationResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reconciliationProvider = Provider.of<ReconciliationProvider>(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation History'),
      ),
      body: reconciliationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reconciliationProvider.reconciliationResults.isEmpty
              ? const Center(child: Text('No reconciliation history found'))
              : ListView.builder(
                  itemCount: reconciliationProvider.reconciliationResults.length,
                  itemBuilder: (context, index) {
                    final result = reconciliationProvider.reconciliationResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(_getReconciliationTypeText(result.type)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GSTIN: ${result.gstin}'),
                            Text('Period: ${result.period}'),
                            Text('Date: ${dateFormat.format(result.reconciliationDate)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View',
                              onPressed: () {
                                _viewReconciliation(context, result.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete',
                              onPressed: () {
                                _deleteReconciliation(context, reconciliationProvider, result.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _viewReconciliation(context, result.id);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReconciliationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  String _getReconciliationTypeText(ReconciliationType type) {
    switch (type) {
      case ReconciliationType.gstr1VsGstr2a:
        return 'GSTR-1 vs GSTR-2A';
      case ReconciliationType.gstr1VsGstr3b:
        return 'GSTR-1 vs GSTR-3B';
      case ReconciliationType.gstr2aVsGstr2b:
        return 'GSTR-2A vs GSTR-2B';
      case ReconciliationType.gstr2bVsGstr3b:
        return 'GSTR-2B vs GSTR-3B';
      case ReconciliationType.comprehensive:
        return 'Comprehensive';
    }
  }
  
  Future<void> _viewReconciliation(BuildContext context, String id) async {
    final provider = Provider.of<ReconciliationProvider>(context, listen: false);
    await provider.loadReconciliationResultById(id);
    
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReconciliationScreen(),
      ),
    );
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
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: ${e.toString()}')),
        );
      }
    }
  }
}
