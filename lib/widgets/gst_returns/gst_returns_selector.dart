import 'package:flutter/material.dart';

class GstReturnsSelector extends StatelessWidget {
  final String selectedReturnType;
  final Function(String) onReturnTypeChanged;
  
  const GstReturnsSelector({
    Key? key,
    required this.selectedReturnType,
    required this.onReturnTypeChanged,
  }) : super(key: key);

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
              'Select Return Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Return type selection
            Row(
              children: [
                _buildReturnTypeButton(
                  context,
                  'GSTR1',
                  'Outward Supplies',
                  'Monthly/Quarterly',
                ),
                _buildReturnTypeButton(
                  context,
                  'GSTR3B',
                  'Summary Return',
                  'Monthly',
                ),
                _buildReturnTypeButton(
                  context,
                  'GSTR9',
                  'Annual Return',
                  'Yearly',
                ),
                _buildReturnTypeButton(
                  context,
                  'GSTR9C',
                  'Reconciliation Statement',
                  'Yearly',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReturnTypeButton(
    BuildContext context,
    String returnType,
    String description,
    String frequency,
  ) {
    final isSelected = selectedReturnType == returnType;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () => onReturnTypeChanged(returnType),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  returnType,
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
