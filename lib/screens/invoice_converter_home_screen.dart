import 'package:flutter/material.dart';

import '../widgets/converter/format_comparison_widget.dart';
import '../widgets/converter/supported_formats_widget.dart';
import 'batch_invoice_converter_screen.dart';
import 'invoice_converter_screen.dart';

class InvoiceConverterHomeScreen extends StatelessWidget {
  const InvoiceConverterHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Format Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 24),
            const SupportedFormatsWidget(),
            const SizedBox(height: 24),
            const FormatComparisonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill-Shill Format Converter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Convert between different invoice formats seamlessly. Our converter supports all major accounting software formats including Tally, Zoho, QuickBooks, and more.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildFeatureItem(
                  context,
                  Icons.swap_horiz,
                  'Easy Conversion',
                  'Convert between 7 different formats',
                ),
                _buildFeatureItem(
                  context,
                  Icons.security,
                  'Secure',
                  'All processing happens on your device',
                ),
                _buildFeatureItem(
                  context,
                  Icons.check_circle,
                  'Accurate',
                  'Preserves all invoice details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoiceConverterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Convert Single Invoice'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BatchInvoiceConverterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.batch_prediction),
                label: const Text('Batch Convert Invoices'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Show a dialog with instructions
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('How to Convert'),
                      content: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Single Conversion:'),
                            SizedBox(height: 4),
                            Text('1. Click on "Convert Single Invoice"'),
                            Text('2. Select your invoice file'),
                            Text('3. Choose source and target formats'),
                            Text('4. Click "Convert"'),
                            Text('5. Save or share the converted file'),
                            SizedBox(height: 12),
                            Text('Batch Conversion:'),
                            SizedBox(height: 4),
                            Text('1. Click on "Batch Convert Invoices"'),
                            Text('2. Select multiple invoice files'),
                            Text('3. Choose target format'),
                            Text('4. Click "Convert All Files"'),
                            Text('5. Save or share the converted files'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help),
                label: const Text('How to Convert'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
