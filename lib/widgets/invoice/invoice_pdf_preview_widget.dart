import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../models/invoice/invoice_model.dart';
import '../../services/pdf/invoice_pdf_service.dart';

class InvoicePdfPreviewWidget extends StatefulWidget {
  const InvoicePdfPreviewWidget({
    super.key,
    required this.invoice,
  });

  final InvoiceModel invoice;

  @override
  State<InvoicePdfPreviewWidget> createState() => _InvoicePdfPreviewWidgetState();
}

class _InvoicePdfPreviewWidgetState extends State<InvoicePdfPreviewWidget> {
  final InvoicePdfService _pdfService = InvoicePdfService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${widget.invoice.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadInvoice,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    return await _pdfService.generateInvoicePdf(
      widget.invoice,
      format: format,
    );
  }

  Future<void> _shareInvoice() async {
    try {
      final pdf = await _generatePdf(PdfPageFormat.a4);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'invoice_${widget.invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share invoice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadInvoice() async {
    try {
      final pdf = await _generatePdf(PdfPageFormat.a4);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
        name: 'invoice_${widget.invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
