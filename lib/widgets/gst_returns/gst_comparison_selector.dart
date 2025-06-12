import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gst_returns_provider.dart';

class GstComparisonSelector extends StatefulWidget {
  const GstComparisonSelector({super.key});

  @override
  State<GstComparisonSelector> createState() => _GstComparisonSelectorState();
}

class _GstComparisonSelectorState extends State<GstComparisonSelector> {
  final TextEditingController _gstinController = TextEditingController();
  final List<String> _returnPeriods = [
    'Apr-Jun 2023',
    'Jul-Sep 2023',
    'Oct-Dec 2023',
    'Jan-Mar 2024',
  ];
  String _selectedReturnPeriod = 'Jan-Mar 2024';

  @override
  void initState() {
    super.initState();
    _gstinController.text = '27AADCB2230M1ZT'; // Demo GSTIN
  }

  @override
  void dispose() {
    _gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GstReturnsProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(),
              const SizedBox(height: 24),
              _buildComparisonResults(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GST Returns Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(
                labelText: 'GSTIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReturnPeriod,
              decoration: const InputDecoration(
                labelText: 'Return Period',
                border: OutlineInputBorder(),
              ),
              items: _returnPeriods.map((period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReturnPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Trigger comparison
              },
              child: const Text('Compare Returns'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonResults() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Comparison Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('No comparison data available'),
          ],
        ),
      ),
    );
  }
}
