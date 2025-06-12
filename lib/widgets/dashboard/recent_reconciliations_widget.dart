import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:intl/intl.dart';

class RecentReconciliationsWidget extends StatelessWidget {
  final List<RecentReconciliation> recentReconciliations;
  final Function(String id)? onViewDetails;
  
  const RecentReconciliationsWidget({
    Key? key,
    required this.recentReconciliations,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reconciliations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            recentReconciliations.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recent reconciliations'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentReconciliations.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final reconciliation = recentReconciliations[index];
                      return ListTile(
                        title: Text(
                          _getReconciliationTypeText(reconciliation.type),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Period: ${reconciliation.period} | ${dateFormat.format(reconciliation.date)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Match: ${reconciliation.matchPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: _getMatchColor(reconciliation.matchPercentage),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Diff: ${currencyFormat.format(reconciliation.taxDifference)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (onViewDetails != null)
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                tooltip: 'View Details',
                                onPressed: () => onViewDetails!(reconciliation.id),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
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
  
  Color _getMatchColor(double matchPercentage) {
    if (matchPercentage >= 90) {
      return Colors.green;
    } else if (matchPercentage >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
