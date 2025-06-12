import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryMetricsWidget extends StatelessWidget {
  final int totalReconciliations;
  final int pendingIssues;
  final double totalTaxDifference;
  
  const SummaryMetricsWidget({
    Key? key,
    required this.totalReconciliations,
    required this.pendingIssues,
    required this.totalTaxDifference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Reconciliations',
            totalReconciliations.toString(),
            Icons.assessment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Pending Issues',
            pendingIssues.toString(),
            Icons.warning,
            pendingIssues > 0 ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Tax Difference',
            currencyFormat.format(totalTaxDifference),
            Icons.currency_rupee,
            totalTaxDifference > 1000 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
