import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/reconciliation/reconciliation_result_model.dart';
import '../../providers/reconciliation_provider.dart';

class ReconciliationSummaryWidget extends StatelessWidget {
  const ReconciliationSummaryWidget({
    super.key,
    required this.reconciliationId,
  });

  final String reconciliationId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReconciliationProvider, ReconciliationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = state.results[reconciliationId];
        if (result == null) {
          return const Center(
            child: Text('No reconciliation data found'),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reconciliation Summary',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildSummaryCards(context, result),
                const SizedBox(height: 16),
                _buildDiscrepanciesList(context, result),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReconciliationResult result) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Matched',
            result.matchedCount.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Unmatched',
            result.unmatchedCount.toString(),
            Colors.orange,
            Icons.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Errors',
            result.errorCount.toString(),
            Colors.red,
            Icons.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscrepanciesList(BuildContext context, ReconciliationResult result) {
    if (result.discrepancies.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No discrepancies found'),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discrepancies',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.discrepancies.length,
          itemBuilder: (context, index) {
            final discrepancy = result.discrepancies[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  _getDiscrepancyIcon(discrepancy.type),
                  color: _getDiscrepancyColor(discrepancy.severity),
                ),
                title: Text(discrepancy.description),
                subtitle: Text(discrepancy.details),
                trailing: Chip(
                  label: Text(discrepancy.severity.toUpperCase()),
                  backgroundColor: _getDiscrepancyColor(discrepancy.severity).withValues(alpha: 0.2),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getDiscrepancyIcon(String type) {
    switch (type.toLowerCase()) {
      case 'amount':
        return Icons.attach_money;
      case 'date':
        return Icons.calendar_today;
      case 'tax':
        return Icons.receipt;
      case 'missing':
        return Icons.search_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getDiscrepancyColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
