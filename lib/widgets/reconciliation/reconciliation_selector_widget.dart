import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';

class ReconciliationSelectorWidget extends StatelessWidget {
  final ReconciliationType selectedType;
  final Function(ReconciliationType) onTypeChanged;
  
  const ReconciliationSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Reconciliation Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Reconciliation type selection
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTypeButton(
                  context,
                  ReconciliationType.gstr1VsGstr2a,
                  'GSTR-1 vs GSTR-2A',
                  'Compare outward supplies with vendor reported inward supplies',
                ),
                _buildTypeButton(
                  context,
                  ReconciliationType.gstr1VsGstr3b,
                  'GSTR-1 vs GSTR-3B',
                  'Compare outward supplies with summary return',
                ),
                _buildTypeButton(
                  context,
                  ReconciliationType.gstr2aVsGstr2b,
                  'GSTR-2A vs GSTR-2B',
                  'Compare vendor reported supplies with ITC statement',
                ),
                _buildTypeButton(
                  context,
                  ReconciliationType.gstr2bVsGstr3b,
                  'GSTR-2B vs GSTR-3B',
                  'Compare ITC statement with claimed ITC',
                ),
                _buildTypeButton(
                  context,
                  ReconciliationType.comprehensive,
                  'Comprehensive',
                  'Compare all returns for complete reconciliation',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeButton(
    BuildContext context,
    ReconciliationType type,
    String title,
    String description,
  ) {
    final isSelected = selectedType == type;
    
    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
