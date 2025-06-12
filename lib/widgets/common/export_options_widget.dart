import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/services/export/pdf_service.dart';

enum ExportType {
  pdf,
  excel,
  json,
}

class ExportOptionsWidget extends StatelessWidget {
  const ExportOptionsWidget({
    required this.title,
    required this.data,
    required this.fileName,
    required this.onExport,
    Key? key,
    this.showPrint = true,
  }) : super(key: key);
  final String title;
  final dynamic data;
  final String fileName;
  final Function(ExportType) onExport;
  final bool showPrint;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportButton(
                  context,
                  'PDF',
                  Icons.picture_as_pdf,
                  Colors.red,
                  () => onExport(ExportType.pdf),
                ),
                _buildExportButton(
                  context,
                  'Excel',
                  Icons.table_chart,
                  Colors.green,
                  () => onExport(ExportType.excel),
                ),
                _buildExportButton(
                  context,
                  'JSON',
                  Icons.code,
                  Colors.blue,
                  () => onExport(ExportType.json),
                ),
                if (showPrint)
                  _buildExportButton(
                    context,
                    'Print',
                    Icons.print,
                    Colors.purple,
                    () async {
                      final pdfService = PdfService();
                      final pdfData = await _generatePdfData();
                      await pdfService.printPdf(pdfData, fileName);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            // ignore: deprecated_member_use
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _generatePdfData() async {
    final pdfService = PdfService();

    if (data is GSTR1) {
      return pdfService.generateGstr1Pdf(data);
    } else if (data is GSTR3B) {
      return pdfService.generateGstr3bPdf(data);
    } else if (data is ReconciliationResult) {
      return pdfService.generateReconciliationPdf(data);
    } else {
      throw Exception('Unsupported data type for PDF export');
    }
  }
}
