import 'package:flutter/material.dart';

class SupportedFormatsWidget extends StatelessWidget {
  const SupportedFormatsWidget({Key? key}) : super(key: key);

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
              'Supported Invoice Formats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Our converter supports the following invoice formats:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFormatList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatList() {
    return Column(
      children: [
        _buildFormatItem(
          'Bill-Shill',
          'Our native invoice format with comprehensive GST support',
          Icons.receipt,
          Colors.blue,
        ),
        _buildFormatItem(
          'Tally',
          'Compatible with Tally ERP 9 and Tally Prime',
          Icons.account_balance,
          Colors.red,
        ),
        _buildFormatItem(
          'Zoho',
          'Import and export Zoho Invoice format',
          Icons.cloud,
          Colors.green,
        ),
        _buildFormatItem(
          'QuickBooks',
          'Compatible with QuickBooks Online and Desktop',
          Icons.book,
          Colors.purple,
        ),
        _buildFormatItem(
          'JSON',
          'Standard JSON format for easy integration',
          Icons.code,
          Colors.orange,
        ),
        _buildFormatItem(
          'XML',
          'Standard XML format for system interoperability',
          Icons.code,
          Colors.teal,
        ),
        _buildFormatItem(
          'CSV',
          'Simple CSV format for spreadsheet compatibility',
          Icons.table_chart,
          Colors.brown,
        ),
      ],
    );
  }

  Widget _buildFormatItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
