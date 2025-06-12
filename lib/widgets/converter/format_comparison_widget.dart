import 'package:flutter/material.dart';

class FormatComparisonWidget extends StatelessWidget {
  const FormatComparisonWidget({Key? key}) : super(key: key);

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
              'Format Comparison',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Feature')),
                  DataColumn(label: Text('Bill-Shill')),
                  DataColumn(label: Text('Tally')),
                  DataColumn(label: Text('Zoho')),
                  DataColumn(label: Text('QuickBooks')),
                  DataColumn(label: Text('JSON')),
                  DataColumn(label: Text('XML')),
                  DataColumn(label: Text('CSV')),
                ],
                rows: [
                  _buildDataRow(
                    'GST Support',
                    [true, true, true, true, true, true, true],
                  ),
                  _buildDataRow(
                    'Item-wise Tax',
                    [true, true, true, true, true, true, true],
                  ),
                  _buildDataRow(
                    'Multiple Tax Rates',
                    [true, true, true, true, true, true, false],
                  ),
                  _buildDataRow(
                    'HSN Codes',
                    [true, true, true, true, true, true, true],
                  ),
                  _buildDataRow(
                    'Customer Details',
                    [true, true, true, true, true, true, true],
                  ),
                  _buildDataRow(
                    'Payment Terms',
                    [true, false, true, true, true, true, false],
                  ),
                  _buildDataRow(
                    'Discounts',
                    [true, false, true, true, true, true, true],
                  ),
                  _buildDataRow(
                    'Notes & Terms',
                    [true, true, true, true, true, true, false],
                  ),
                  _buildDataRow(
                    'Human Readable',
                    [false, false, false, false, false, false, true],
                  ),
                  _buildDataRow(
                    'Machine Readable',
                    [true, true, true, true, true, true, true],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String feature, List<bool> supported) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...supported.map((isSupported) => DataCell(
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel,
            color: isSupported ? Colors.green : Colors.red,
          ),
        )),
      ],
    );
  }
}
