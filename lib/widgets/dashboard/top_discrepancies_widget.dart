import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:intl/intl.dart';

class TopDiscrepanciesWidget extends StatelessWidget {
  final List<DiscrepancyTypeMetric> topDiscrepancies;
  
  const TopDiscrepanciesWidget({
    Key? key,
    required this.topDiscrepancies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Discrepancies',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            topDiscrepancies.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No discrepancies found'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topDiscrepancies.length,
                    itemBuilder: (context, index) {
                      final discrepancy = topDiscrepancies[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(discrepancy.discrepancyType),
                        subtitle: Text(
                          'Occurrences: ${discrepancy.count}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(discrepancy.totalValue),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${discrepancy.percentageOfTotal.toStringAsFixed(1)}% of total',
                              style: const TextStyle(fontSize: 12),
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
}
