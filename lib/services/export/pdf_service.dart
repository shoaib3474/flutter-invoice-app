import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart'; // Replaced with mock
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/gst_returns/gstr1_model.dart';
import '../../models/gst_returns/gstr3b_model.dart';
import '../../models/gst_returns/gstr9_model.dart';
import '../../models/reconciliation/reconciliation_result_model.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();

  factory PdfService() {
    return _instance;
  }

  PdfService._internal();

  // Generate PDF for GSTR1
  Future<Uint8List> generateGstr1Pdf(GSTR1 gstr1) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(
          'GSTR-1 Return',
          gstr1.gstin ?? '',
          gstr1.returnPeriod ?? '',
          boldFont,
        ),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total Taxable Value', font),
                  _buildTableCell(currencyFormat.format(gstr1.totalTaxableValue ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total IGST', font),
                  _buildTableCell(currencyFormat.format(gstr1.totalIgst ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total CGST', font),
                  _buildTableCell(currencyFormat.format(gstr1.totalCgst ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total SGST', font),
                  _buildTableCell(currencyFormat.format(gstr1.totalSgst ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Status', font),
                  _buildTableCell(gstr1.status ?? '', font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Filing Date', font),
                  _buildTableCell(gstr1.filingDate != null ? dateFormat.format(gstr1.filingDate!) : '', font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('B2B Invoices', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          _buildB2BInvoicesTable(gstr1.b2bInvoices ?? [], font, boldFont, currencyFormat, dateFormat),
          pw.SizedBox(height: 20),
          pw.Text('B2C Large Invoices', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          _buildB2CLInvoicesTable(gstr1.b2clInvoices ?? [], font, boldFont, currencyFormat, dateFormat),
          pw.SizedBox(height: 20),
          pw.Text('B2C Small Invoices', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          _buildB2CSInvoicesTable(gstr1.b2csInvoices ?? [], font, boldFont, currencyFormat),
          pw.SizedBox(height: 20),
          pw.Text('Export Invoices', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          _buildExportInvoicesTable(gstr1.exportInvoices ?? [], font, boldFont, currencyFormat, dateFormat),
        ],
      ),
    );

    return pdf.save();
  }

  // Generate PDF for GSTR3B
  Future<Uint8List> generateGstr3bPdf(GSTR3B gstr3b) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(
          'GSTR-3B Return',
          gstr3b.gstin ?? '',
          gstr3b.returnPeriod ?? '',
          boldFont,
        ),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text('Outward Supplies', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Taxable Outward Supplies', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.taxableOutwardSupplies ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Zero Rated Supplies', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.taxableOutwardSuppliesZeroRated ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Nil Rated Supplies', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.taxableOutwardSuppliesNilRated ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Non-GST Outward Supplies', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.nonGstOutwardSupplies ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Tax Details', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Tax Type', boldFont, isHeader: true),
                  _buildTableCell('Amount', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('IGST', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.igstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('CGST', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.cgstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('SGST', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.sgstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Cess', font),
                  _buildTableCell(currencyFormat.format(gstr3b.outwardSupplies?.cessAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Inward Supplies', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Reverse Charge Supplies', font),
                  _buildTableCell(currencyFormat.format(gstr3b.inwardSupplies?.reverseChargeSupplies ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Import of Goods', font),
                  _buildTableCell(currencyFormat.format(gstr3b.inwardSupplies?.importOfGoods ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Import of Services', font),
                  _buildTableCell(currencyFormat.format(gstr3b.inwardSupplies?.importOfServices ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('ITC Details', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('ITC Availed', font),
                  _buildTableCell(currencyFormat.format(gstr3b.itcDetails?.itcAvailed ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('ITC Reversed', font),
                  _buildTableCell(currencyFormat.format(gstr3b.itcDetails?.itcReversed ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Net ITC', font),
                  _buildTableCell(currencyFormat.format(gstr3b.itcDetails?.itcNet ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Ineligible ITC', font),
                  _buildTableCell(currencyFormat.format(gstr3b.itcDetails?.ineligibleITC ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Tax Payment', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('IGST Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.igstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('CGST Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.cgstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('SGST Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.sgstAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Cess Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.cessAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Interest Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.interestAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Late Fees Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.lateFeesAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Penalty Amount', font),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.penaltyAmount ?? 0), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Total Amount', boldFont),
                  _buildTableCell(currencyFormat.format(gstr3b.taxPayment?.totalAmount ?? 0), boldFont, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Return Status', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Value', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Status', font),
                  _buildTableCell(gstr3b.status ?? '', font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Filing Date', font),
                  _buildTableCell(gstr3b.filingDate != null ? dateFormat.format(gstr3b.filingDate!) : '', font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // Generate PDF for reconciliation results
  Future<Uint8List> generateReconciliationPdf(ReconciliationResult result) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(
          'Reconciliation Report',
          'Comparison: ${result.summary?.totalInvoices ?? 0} Invoices',
          DateTime.now().toString().substring(0, 10),
          boldFont,
        ),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Count', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total Invoices', font),
                  _buildTableCell((result.summary?.totalInvoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Matched Invoices', font),
                  _buildTableCell((result.summary?.matchedInvoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Partially Matched Invoices', font),
                  _buildTableCell((result.summary?.partiallyMatchedInvoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Unmatched Invoices', font),
                  _buildTableCell((result.summary?.unmatchedInvoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Only in Source 1', font),
                  _buildTableCell((result.summary?.onlyInSource1Invoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Only in Source 2', font),
                  _buildTableCell((result.summary?.onlyInSource2Invoices ?? 0).toString(), font, align: pw.TextAlign.right),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Financial Summary', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Source 1', boldFont, isHeader: true, align: pw.TextAlign.right),
                  _buildTableCell('Source 2', boldFont, isHeader: true, align: pw.TextAlign.right),
                  _buildTableCell('Difference', boldFont, isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Taxable Value', font),
                  _buildTableCell(currencyFormat.format(result.summary?.totalTaxableValueInSource1 ?? 0), font, align: pw.TextAlign.right),
                  _buildTableCell(currencyFormat.format(result.summary?.totalTaxableValueInSource2 ?? 0), font, align: pw.TextAlign.right),
                  _buildTableCell(
                    currencyFormat.format((result.summary?.totalTaxableValueInSource1 ?? 0) - (result.summary?.totalTaxableValueInSource2 ?? 0)),
                    font,
                    align: pw.TextAlign.right,
                    textColor: ((result.summary?.totalTaxableValueInSource1 ?? 0) - (result.summary?.totalTaxableValueInSource2 ?? 0)) != 0
                        ? PdfColors.red
                        : PdfColors.black,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Total Tax', font),
                  _buildTableCell(currencyFormat.format(result.summary?.totalTaxInSource1 ?? 0), font, align: pw.TextAlign.right),
                  _buildTableCell(currencyFormat.format(result.summary?.totalTaxInSource2 ?? 0), font, align: pw.TextAlign.right),
                  _buildTableCell(
                    currencyFormat.format(result.summary?.taxDifference ?? 0),
                    font,
                    align: pw.TextAlign.right,
                    textColor: (result.summary?.taxDifference ?? 0) != 0 ? PdfColors.red : PdfColors.black,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Discrepancy Details', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          _buildDiscrepancyTable(result.items ?? [], font, boldFont, currencyFormat),
        ],
      ),
    );

    return pdf.save();
  }

  // Print a PDF document
  Future<void> printPdf(Uint8List pdfData, String documentName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: documentName,
    );
  }

  // Save PDF to file and return the file path
  Future<String> savePdf(Uint8List pdfData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file.path;
  }

  // Share PDF file
  Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfData);
    await Share.shareXFiles([XFile(file.path)], text: 'Sharing $fileName');
  }

  // Open PDF file
  Future<void> openPdf(Uint8List pdfData, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfData);
    // await OpenFile.open(file.path); // Replaced with mock
    await MockOpenFile.open(file.path);
  }

  // Helper methods for building PDF components
  pw.Widget _buildHeader(String title, String subtitle1, String subtitle2, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 24)),
        pw.SizedBox(height: 5),
        pw.Text(subtitle1, style: pw.TextStyle(font: boldFont, fontSize: 14)),
        pw.Text(subtitle2, style: pw.TextStyle(font: boldFont, fontSize: 14)),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated on: ${DateTime.now().toString().substring(0, 19)}',
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(font: font, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font,
      {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          color: textColor,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildB2BInvoicesTable(
      List<B2BInvoice> invoices, pw.Font font, pw.Font boldFont, NumberFormat currencyFormat, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Invoice No.', boldFont, isHeader: true),
            _buildTableCell('Date', boldFont, isHeader: true),
            _buildTableCell('GSTIN', boldFont, isHeader: true),
            _buildTableCell('Taxable Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('IGST', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('CGST', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('SGST', boldFont, isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        ...invoices.map((invoice) => pw.TableRow(
              children: [
                _buildTableCell(invoice.invoiceNumber ?? '', font),
                _buildTableCell(invoice.invoiceDate != null ? dateFormat.format(invoice.invoiceDate!) : '', font),
                _buildTableCell(invoice.counterpartyGstin ?? '', font),
                _buildTableCell(currencyFormat.format(invoice.taxableValue ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.igstAmount ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.cgstAmount ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.sgstAmount ?? 0), font, align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildB2CLInvoicesTable(
      List<B2CLInvoice> invoices, pw.Font font, pw.Font boldFont, NumberFormat currencyFormat, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Invoice No.', boldFont, isHeader: true),
            _buildTableCell('Date', boldFont, isHeader: true),
            _buildTableCell('Place of Supply', boldFont, isHeader: true),
            _buildTableCell('Taxable Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('IGST', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('CGST/SGST', boldFont, isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        ...invoices.map((invoice) => pw.TableRow(
              children: [
                _buildTableCell(invoice.invoiceNumber ?? '', font),
                _buildTableCell(invoice.invoiceDate != null ? dateFormat.format(invoice.invoiceDate!) : '', font),
                _buildTableCell(invoice.placeOfSupply ?? '', font),
                _buildTableCell(currencyFormat.format(invoice.taxableValue ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.igstAmount ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(
                    currencyFormat.format((invoice.cgstAmount ?? 0) + (invoice.sgstAmount ?? 0)), font, align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildB2CSInvoicesTable(
      List<B2CSInvoice> invoices, pw.Font font, pw.Font boldFont, NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Type', boldFont, isHeader: true),
            _buildTableCell('Place of Supply', boldFont, isHeader: true),
            _buildTableCell('Taxable Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('IGST', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('CGST/SGST', boldFont, isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        ...invoices.map((invoice) => pw.TableRow(
              children: [
                _buildTableCell(invoice.type ?? '', font),
                _buildTableCell(invoice.placeOfSupply ?? '', font),
                _buildTableCell(currencyFormat.format(invoice.taxableValue ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.igstAmount ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(
                    currencyFormat.format((invoice.cgstAmount ?? 0) + (invoice.sgstAmount ?? 0)), font, align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildExportInvoicesTable(
      List<ExportInvoice> invoices, pw.Font font, pw.Font boldFont, NumberFormat currencyFormat, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Invoice No.', boldFont, isHeader: true),
            _buildTableCell('Date', boldFont, isHeader: true),
            _buildTableCell('Shipping Bill', boldFont, isHeader: true),
            _buildTableCell('Export Type', boldFont, isHeader: true),
            _buildTableCell('Taxable Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('IGST', boldFont, isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        ...invoices.map((invoice) => pw.TableRow(
              children: [
                _buildTableCell(invoice.invoiceNumber ?? '', font),
                _buildTableCell(invoice.invoiceDate != null ? dateFormat.format(invoice.invoiceDate!) : '', font),
                _buildTableCell(
                    '${invoice.shippingBillNumber ?? ''} (${invoice.shippingBillDate != null ? dateFormat.format(invoice.shippingBillDate!) : ''})',
                    font),
                _buildTableCell(invoice.exportType ?? '', font),
                _buildTableCell(currencyFormat.format(invoice.taxableValue ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(invoice.igstAmount ?? 0), font, align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildDiscrepancyTable(
      List<ComparisonItem> items, pw.Font font, pw.Font boldFont, NumberFormat currencyFormat) {
    // Filter to show only discrepancies
    final discrepancies = items.where((item) => item.matchStatus != 'Matched').toList();

    if (discrepancies.isEmpty) {
      return pw.Text('No discrepancies found.', style: pw.TextStyle(font: font, fontSize: 12));
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Invoice No.', boldFont, isHeader: true),
            _buildTableCell('GSTIN', boldFont, isHeader: true),
            _buildTableCell('Status', boldFont, isHeader: true),
            _buildTableCell('Source 1 Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('Source 2 Value', boldFont, isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('Remarks', boldFont, isHeader: true),
          ],
        ),
        ...discrepancies.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.invoiceNumber ?? '', font),
                _buildTableCell(item.counterpartyGstin ?? '', font),
                _buildTableCell(item.matchStatus ?? '', font),
                _buildTableCell(currencyFormat.format(item.taxableValueInSource1 ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(currencyFormat.format(item.taxableValueInSource2 ?? 0), font, align: pw.TextAlign.right),
                _buildTableCell(item.remarks ?? '', font),
              ],
            )),
      ],
    );
  }
}

// Mock OpenFile class
class MockOpenFile {
  static Future<void> open(String filePath) async {
    print('Opening file: $filePath (Mock)');
    // Simulate opening the file (e.g., log the action)
  }
}
