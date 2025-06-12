import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr3b_model.dart';
import 'package:flutter_invoice_app/services/gstr3b_service.dart';
import 'package:flutter_invoice_app/utils/error_handler.dart';
import 'package:flutter_invoice_app/widgets/error_boundary_widget.dart';
import 'package:intl/intl.dart';

class GSTR3BSummaryWidget extends StatelessWidget {
  final GSTR3BModel data;
  final Function() onEdit;
  final Function() onExport;
  final Function() onSubmit;

  const GSTR3BSummaryWidget({
    Key? key,
    required this.data,
    required this.onEdit,
    required this.onExport,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return ErrorBoundaryWidget(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GSTR-3B Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('GSTIN', data.gstin),
                      _buildInfoRow('Financial Year', data.financialYear ?? 'N/A'),
                      _buildInfoRow('Tax Period', data.taxPeriod ?? 'N/A'),
                      _buildInfoRow('Status', data.status ?? 'Draft'),
                      const Divider(height: 32),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Outward Supplies Summary
              _buildSummaryCard(
                'Outward Supplies',
                [
                  _buildInfoRow('Total Taxable Value', 
                    currencyFormat.format(data.outwardSuppliesTotal ?? 0)),
                  _buildInfoRow('Zero Rated Supplies', 
                    currencyFormat.format(data.outwardSuppliesZeroRated ?? 0)),
                  _buildInfoRow('Nil Rated, Exempted Supplies', 
                    currencyFormat.format(data.outwardSuppliesNilRated ?? 0)),
                ],
              ),
              
              // Inward Supplies Summary
              _buildSummaryCard(
                'Inward Supplies',
                [
                  _buildInfoRow('Reverse Charge', 
                    currencyFormat.format(data.inwardSuppliesReverseCharge ?? 0)),
                  _buildInfoRow('Import of Goods', 
                    currencyFormat.format(data.inwardSuppliesImport ?? 0)),
                ],
              ),
              
              // ITC Details Summary
              _buildSummaryCard(
                'Input Tax Credit (ITC)',
                [
                  _buildInfoRow('ITC Availed', 
                    currencyFormat.format(data.itcAvailed ?? 0)),
                  _buildInfoRow('ITC Reversed', 
                    currencyFormat.format(data.itcReversed ?? 0)),
                  _buildInfoRow('Net ITC Available', 
                    currencyFormat.format((data.itcAvailed ?? 0) - (data.itcReversed ?? 0))),
                ],
              ),
              
              // Tax Payable Summary
              _buildSummaryCard(
                'Tax Payable',
                [
                  _buildInfoRow('CGST', 
                    currencyFormat.format(data.taxPayableCGST ?? 0)),
                  _buildInfoRow('SGST', 
                    currencyFormat.format(data.taxPayableSGST ?? 0)),
                  _buildInfoRow('IGST', 
                    currencyFormat.format(data.taxPayableIGST ?? 0)),
                  _buildInfoRow('Cess', 
                    currencyFormat.format(data.taxPayableCess ?? 0)),
                  const Divider(),
                  _buildInfoRow('Total Tax Payable', 
                    currencyFormat.format(
                      (data.taxPayableCGST ?? 0) +
                      (data.taxPayableSGST ?? 0) +
                      (data.taxPayableIGST ?? 0) +
                      (data.taxPayableCess ?? 0)
                    ),
                    isHighlighted: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted ? Colors.black : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.file_download),
          label: const Text('Export'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.send),
          label: const Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
