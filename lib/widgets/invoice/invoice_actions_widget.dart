// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_status.dart';
import 'package:flutter_invoice_app/services/pdf/invoice_pdf_service.dart';
import 'package:flutter_invoice_app/widgets/common/custom_button.dart';

class InvoiceActionsWidget extends StatelessWidget {
  const InvoiceActionsWidget({
    required this.invoice,
    Key? key,
    this.onShare,
  }) : super(key: key);
  final InvoiceModel invoice;
  final Function? onShare;

  @override
  Widget build(BuildContext context) {
    final pdfService = InvoicePdfService();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.visibility,
                  label: 'View PDF',
                  color: Colors.blue,
                  onPressed: () async {
                    try {
                      await pdfService.viewInvoicePdf(invoice);
                    } catch (e) {
                      _showErrorSnackbar(context, 'Failed to view PDF: $e');
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.share,
                  label: 'Share PDF',
                  color: Colors.green,
                  onPressed: () async {
                    try {
                      await pdfService.shareInvoicePdf(invoice);
                      if (onShare != null) {
                        onShare!();
                      }
                    } catch (e) {
                      _showErrorSnackbar(context, 'Failed to share PDF: $e');
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.print,
                  label: 'Print PDF',
                  color: Colors.purple,
                  onPressed: () async {
                    try {
                      await pdfService.printInvoicePdf(invoice);
                    } catch (e) {
                      _showErrorSnackbar(context, 'Failed to print PDF: $e');
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.save_alt,
                  label: 'Save PDF',
                  color: Colors.orange,
                  onPressed: () async {
                    try {
                      final filePath = await pdfService.saveInvoicePdf(invoice);
                      if (context.mounted) {
                        _showSuccessSnackbar(
                            context, 'PDF saved to: $filePath');
                      }
                    } catch (e) {
                      _showErrorSnackbar(context, 'Failed to save PDF: $e');
                    }
                  },
                ),
                if (invoice.status == InvoiceStatus.draft) ...[
                  _buildActionButton(
                    context,
                    icon: Icons.check_circle,
                    label: 'Mark as Issued',
                    color: Colors.teal,
                    onPressed: () {
                      // This would be implemented to update the invoice status
                      _showSuccessSnackbar(context, 'Invoice marked as issued');
                    },
                  ),
                ],
                if (invoice.status == InvoiceStatus.issued ||
                    invoice.status == InvoiceStatus.overdue) ...[
                  _buildActionButton(
                    context,
                    icon: Icons.payment,
                    label: 'Record Payment',
                    color: Colors.indigo,
                    onPressed: () {
                      // This would be implemented to record a payment
                      _showInfoDialog(context, 'Record Payment');
                    },
                  ),
                ],
                if (invoice.status != InvoiceStatus.cancelled &&
                    invoice.status != InvoiceStatus.voided) ...[
                  _buildActionButton(
                    context,
                    icon: Icons.cancel,
                    label: 'Cancel Invoice',
                    color: Colors.red,
                    onPressed: () {
                      // This would be implemented to cancel the invoice
                      _showWarningDialog(context, 'Cancel Invoice');
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CustomButton(
      text: label,
      icon: icon,
      color: color,
      onPressed: onPressed,
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('This feature would be implemented in a real app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Are you sure you want to perform this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackbar(context, 'Operation completed');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
