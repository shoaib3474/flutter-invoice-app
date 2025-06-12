import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr1_model.dart';
import 'package:flutter_invoice_app/services/gstr1_service.dart';
import 'package:flutter_invoice_app/utils/error_handler.dart';
import 'package:flutter_invoice_app/widgets/error_boundary_widget.dart';
import 'package:intl/intl.dart';

class GSTR1SummaryWidget extends StatelessWidget {
  final GSTR1Model data;
  final Function() onEdit;
  final Function() onExport;
  final Function() onSubmit;

  const GSTR1SummaryWidget({
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
                        'GSTR-1 Summary',
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
              
              // B2B Invoices Summary
              _buildSummaryCard(
                'B2B Invoices',
                [
                  _buildInfoRow('Number of Invoices', 
                    data.b2bInvoiceCount?.toString() ?? '0'),
                  _buildInfoRow('Total Value', 
                    currencyFormat.format(data.b2bInvoiceValue ?? 0)),
                  _buildInfoRow('Total Tax', 
                    currencyFormat.format(data.b2bTaxAmount ?? 0)),
                ],
              ),
              
              // B2C Invoices Summary
              _buildSummaryCard(
                'B2C Invoices',
                [
                  _buildInfoRow('Number of Invoices', 
                    data.b2cInvoiceCount?.toString() ?? '0'),
                  _buildInfoRow('Total Value', 
                    currencyFormat.format(data.b2cInvoiceValue ?? 0)),
                  _buildInfoRow('Total Tax', 
                    currencyFormat.format(data.b2cTaxAmount ?? 0)),
                ],
              ),
              
              // HSN Summary
              _buildSummaryCard(
                'HSN Summary',
                [
                  _buildInfoRow('Number of HSN Codes', 
                    data.hsnSummaryCount?.toString() ?? '0'),
                  _buildInfoRow('Total Value', 
                    currencyFormat.format(data.hsnTotalValue ?? 0)),
                  _buildInfoRow('Total Taxable Value', 
                    currencyFormat.format(data.hsnTaxableValue ?? 0)),
                  _buildInfoRow('Total Tax', 
                    currencyFormat.format(data.hsnTotalTax ?? 0)),
                ],
              ),
              
              // Nil Rated, Exempted and Non-GST Supplies
              _buildSummaryCard(
                'Nil Rated, Exempted and Non-GST Supplies',
                [
                  _buildInfoRow('Nil Rated Supplies', 
                    currencyFormat.format(data.nilRatedSupplies ?? 0)),
                  _buildInfoRow('Exempted Supplies', 
                    currencyFormat.format(data.exemptedSupplies ?? 0)),
                  _buildInfoRow('Non-GST Supplies', 
                    currencyFormat.format(data.nonGstSupplies ?? 0)),
                ],
              ),
            ],
          ),
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
