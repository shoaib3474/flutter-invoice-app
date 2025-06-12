import 'package:flutter/material.dart';
import '../../models/gstr4_model.dart';

class GSTR4SummaryWidget extends StatelessWidget {
  const GSTR4SummaryWidget({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final GSTR4Model data;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GSTR-4 Summary (Composition Scheme)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Edit GSTR-4',
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('GSTIN', data.gstin),
            _buildInfoRow('Tax Period', data.returnPeriod ?? 'N/A'),
            _buildInfoRow('Financial Year', data.financialYear ?? 'N/A'),
            const SizedBox(height: 16),
            
            // Outward Supplies Summary
            _buildSectionHeader(context, 'Outward Supplies'),
            _buildInfoRow('B2B Supplies', _formatCurrency(data.b2bInvoices.length.toDouble())),
            _buildInfoRow('B2C Supplies', _formatCurrency(data.b2burInvoices.length.toDouble())),
            _buildInfoRow(
              'Total Outward Supplies', 
              _formatCurrency((data.b2bInvoices.length + data.b2burInvoices.length).toDouble()),
            ),
            
            const SizedBox(height: 16),
            
            // Inward Supplies Summary
            _buildSectionHeader(context, 'Inward Supplies'),
            _buildInfoRow('Reverse Charge Supplies', _formatCurrency(0.0)),
            _buildInfoRow('Imports', _formatCurrency(data.importedGoods.length.toDouble())),
            
            const SizedBox(height: 16),
            
            // Tax Payment Summary
            _buildSectionHeader(context, 'Tax Payment'),
            _buildInfoRow('Total Tax Paid', _formatCurrency(data.taxesPaid.values.fold(0.0, (sum, tax) => sum + tax))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
