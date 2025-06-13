// ignore_for_file: avoid_print, avoid_escaping_inner_quotes, flutter_style_todos, avoid_redundant_argument_values

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_type.dart';
import 'package:flutter_invoice_app/services/settings/logo_service.dart';
import 'package:flutter_invoice_app/utils/number_formatter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class InvoicePdfService {
  factory InvoicePdfService() {
    return _instance;
  }

  InvoicePdfService._internal();
  static final InvoicePdfService _instance = InvoicePdfService._internal();
  final LogoService _logoService = LogoService();

  Future<Uint8List> generateInvoicePdf(Invoice invoice,
      {required PdfPageFormat format}) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Try to load custom logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await _logoService.getLogoBytes();
      if (logoBytes != null) {
        logoImage = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      print('Error loading logo: $e');
      // Continue without logo
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) =>
            _buildHeader(invoice, logoImage, boldFont, dateFormat),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          // Customer information
          _buildCustomerInfo(invoice, font, boldFont),
          pw.SizedBox(height: 20),

          // Items table
          _buildItemsTable(invoice, font, boldFont),
          pw.SizedBox(height: 20),

          // Invoice summary
          _buildInvoiceSummary(invoice, font, boldFont),
          pw.SizedBox(height: 20),

          // Additional notes and terms
          if (invoice.notes.isNotEmpty) ...[
            pw.Text('Notes:',
                style: pw.TextStyle(font: boldFont, fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text(invoice.notes,
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 20),
          ],

          if (invoice.termsAndConditions.isNotEmpty) ...[
            pw.Text('Terms and Conditions:',
                style: pw.TextStyle(font: boldFont, fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text(invoice.termsAndConditions,
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 20),
          ],

          // GST declaration
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GST Declaration:',
                    style: pw.TextStyle(font: boldFont, fontSize: 10)),
                pw.SizedBox(height: 5),
                pw.Text(
                  'We declare that this invoice shows the actual price of the goods/services described and that all particulars are true and correct.',
                  style: pw.TextStyle(font: font, fontSize: 9),
                ),
              ],
            ),
          ),

          // Signature section
          pw.SizedBox(height: 50),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Receiver\'s Signature',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 150,
                    height: 1,
                    color: PdfColors.black,
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('For ${invoice.customerName}',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 150,
                    height: 1,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Authorized Signatory',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Invoice invoice, pw.MemoryImage? logoImage,
      pw.Font boldFont, DateFormat dateFormat) {
    String invoiceTypeText;
    switch (invoice.invoiceType) {
      case InvoiceType.sales:
        invoiceTypeText = 'TAX INVOICE';
        break;
      case InvoiceType.purchase:
        invoiceTypeText = 'PURCHASE INVOICE';
        break;
      case InvoiceType.creditNote:
        invoiceTypeText = 'CREDIT NOTE';
        break;
      case InvoiceType.debitNote:
        invoiceTypeText = 'DEBIT NOTE';
        break;
      case InvoiceType.regular:
        invoiceTypeText = 'REGULAR INVOICE';
        break;
      case InvoiceType.proforma:
        invoiceTypeText = 'PROFORMA INVOICE';
        break;
      case InvoiceType.export:
        invoiceTypeText = 'EXPORT INVOICE';
        break;
      case InvoiceType.standard:
        invoiceTypeText = 'STANDARD INVOICE';
        break;
      default:
        invoiceTypeText = 'INVOICE';
        break;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logoImage != null)
              pw.Image(logoImage, width: 80, height: 80)
            else
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text('LOGO',
                    style: pw.TextStyle(font: boldFont, color: PdfColors.grey)),
              ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(invoiceTypeText,
                    style: pw.TextStyle(font: boldFont, fontSize: 16)),
                pw.SizedBox(height: 5),
                pw.Text('Invoice #: ${invoice.invoiceNumber}',
                    style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Text('Date: ${dateFormat.format(invoice.invoiceDate)}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Due Date: ${dateFormat.format(invoice.dueDate)}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            'YOUR COMPANY NAME',
            style: pw.TextStyle(font: boldFont, fontSize: 14),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('123 Business Street, Area Name',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text('City, State - PIN Code',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text('GSTIN: 27AADCB2230M1ZP',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text('PAN: AADCB2230M',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text('Email: contact@yourcompany.com',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text('Phone: +91 9876543210',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ],
              ),
            ),
            if (invoice.isReverseCharge)
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.red),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text('Reverse Charge: Yes',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 10, color: PdfColors.red)),
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildCustomerInfo(
      Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                bottomLeft: pw.Radius.circular(5),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:',
                    style: pw.TextStyle(font: boldFont, fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text(invoice.customerName,
                    style: pw.TextStyle(font: boldFont, fontSize: 11)),
                pw.SizedBox(height: 2),
                pw.Text(invoice.customerAddress,
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(
                    'State: ${invoice.customerState} (${invoice.customerStateCode})',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                if (invoice.customerGstin != null &&
                    invoice.customerGstin!.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text('GSTIN: ${invoice.customerGstin}',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ],
              ],
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.only(
                topRight: pw.Radius.circular(5),
                bottomRight: pw.Radius.circular(5),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ship To:',
                    style: pw.TextStyle(font: boldFont, fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text(invoice.customerName,
                    style: pw.TextStyle(font: boldFont, fontSize: 11)),
                pw.SizedBox(height: 2),
                pw.Text(invoice.customerAddress,
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(
                    'Place of Supply: ${invoice.placeOfSupply} (${invoice.placeOfSupplyCode})',
                    style: pw.TextStyle(font: boldFont, fontSize: 10)),
                pw.SizedBox(height: 2),
                if (invoice.isB2B) ...[
                  pw.Text('Supply Type: B2B',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ] else ...[
                  pw.Text('Supply Type: B2C',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ],
                pw.SizedBox(height: 2),
                if (invoice.isInterState) ...[
                  pw.Text('Interstate Supply',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ] else ...[
                  pw.Text('Intrastate Supply',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Invoice invoice, pw.Font font, pw.Font boldFont) {
    // Define table columns
    final tableHeaders = [
      'Item & Description',
      'HSN/SAC',
      'Qty',
      'Rate',
      'Discount',
      'Taxable Value',
      'Tax Rate',
      'Tax Amount',
      'Total',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Item & Description
        1: const pw.FlexColumnWidth(1), // HSN/SAC
        2: const pw.FlexColumnWidth(1), // Qty
        3: const pw.FlexColumnWidth(1), // Rate
        4: const pw.FlexColumnWidth(1), // Discount
        5: const pw.FlexColumnWidth(1.5), // Taxable Value
        6: const pw.FlexColumnWidth(1), // Tax Rate
        7: const pw.FlexColumnWidth(1.5), // Tax Amount
        8: const pw.FlexColumnWidth(1.5), // Total
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: tableHeaders
              .map((header) => pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ))
              .toList(),
        ),

        // Table Rows for Items
        ...invoice.items.map((item) {
          // Calculate tax rate text
          String taxRateText = '';
          if (invoice.isInterState) {
            taxRateText = 'IGST ${item.igstRate}%';
          } else {
            taxRateText = 'CGST ${item.cgstRate}%, SGST ${item.sgstRate}%';
          }

          // Calculate tax amount text
          String taxAmountText = '';
          if (invoice.isInterState) {
            taxAmountText = '₹${NumberFormatter.format(item.igstAmount)}';
          } else {
            taxAmountText =
                'CGST: ₹${NumberFormatter.format(item.cgstAmount)}\nSGST: ₹${NumberFormatter.format(item.sgstAmount)}';
          }

          return pw.TableRow(
            children: [
              // Item & Description
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.name,
                        style: pw.TextStyle(font: boldFont, fontSize: 10)),
                    if (item.description.isNotEmpty)
                      pw.Text(item.description,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                  ],
                ),
              ),

              // HSN/SAC
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  item.hsnSacCode,
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              // Qty
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${item.quantity} ${item.unit}',
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              // Rate
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '₹${NumberFormatter.format(item.unitPrice)}',
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),

              // Discount
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '₹${NumberFormatter.format(item.discount)}',
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),

              // Taxable Value
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '₹${NumberFormatter.format(item.taxableValue)}',
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),

              // Tax Rate
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  taxRateText,
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              // Tax Amount
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  taxAmountText,
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),

              // Total
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '₹${NumberFormatter.format(item.totalAfterTax)}',
                  style: pw.TextStyle(font: boldFont, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildInvoiceSummary(
      Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left section - HSN/SAC Summary (would be implemented in a real app)
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            height: 120,
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('HSN/SAC Summary',
                    style: pw.TextStyle(font: boldFont, fontSize: 10)),
                pw.SizedBox(height: 5),
                // In a real app, you would generate HSN/SAC summary here
                pw.Text('HSN/SAC summary would appear here',
                    style: pw.TextStyle(
                        font: font, fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 10),

        // Right section - Invoice Total
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:',
                        style: pw.TextStyle(font: font, fontSize: 10)),
                    pw.Text('₹${NumberFormatter.format(invoice.subtotal)}',
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 5),

                // Tax details
                if (invoice.isInterState) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('IGST:',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('₹${NumberFormatter.format(invoice.igstTotal)}',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ] else ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('CGST:',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('₹${NumberFormatter.format(invoice.cgstTotal)}',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('SGST:',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('₹${NumberFormatter.format(invoice.sgstTotal)}',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],

                if (invoice.cessTotal > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Cess:',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('₹${NumberFormatter.format(invoice.cessTotal)}',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],

                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Tax:',
                        style: pw.TextStyle(font: font, fontSize: 10)),
                    pw.Text('₹${NumberFormatter.format(invoice.totalTax)}',
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  color: PdfColors.grey200,
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Grand Total:',
                          style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      pw.Text('₹${NumberFormatter.format(invoice.grandTotal)}',
                          style: pw.TextStyle(font: boldFont, fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Amount in words: ${_convertNumberToWords(invoice.grandTotal)} only',
                  style: pw.TextStyle(
                      font: font, fontSize: 9, fontStyle: pw.FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
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
            pw.Text(
                'E. & O.E. This is a computer-generated invoice, no signature required.',
                style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(font: font, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  // Function to print a PDF document
  Future<void> printInvoicePdf(Invoice invoice) async {
    final pdfData = await generateInvoicePdf(invoice, format: PdfPageFormat.a4);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  // Function to save PDF to file and return the file path
  Future<String> saveInvoicePdf(Invoice invoice) async {
    final pdfData = await generateInvoicePdf(invoice, format: PdfPageFormat.a4);
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'Invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file.path;
  }

  // Function to share PDF file
  Future<void> shareInvoicePdf(Invoice invoice) async {
    final pdfData = await generateInvoicePdf(invoice, format: PdfPageFormat.a4);
    final output = await getTemporaryDirectory();
    final fileName = 'Invoice_${invoice.invoiceNumber}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfData);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Sharing invoice ${invoice.invoiceNumber}');
  }

  // Function to view PDF file
  Future<void> viewInvoicePdf(Invoice invoice) async {
    final filePath = await saveInvoicePdf(invoice);
    await OpenFile.open(filePath);
  }

  // Helper function to convert number to words
  String _convertNumberToWords(double number) {
    // This is a simplified version. In a real app, you would implement a more complete converter
    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    int rupees = number.toInt();
    int paise = ((number - rupees) * 100).round();

    String result = '';

    // Handle crores
    if (rupees >= 10000000) {
      result += '${_convertNumberToWords(rupees / 10000000)} Crore ';
      rupees %= 10000000;
    }

    // Handle lakhs
    if (rupees >= 100000) {
      result += '${_convertNumberToWords(rupees / 100000)} Lakh ';
      rupees %= 100000;
    }

    // Handle thousands
    if (rupees >= 1000) {
      result += '${_convertNumberToWords(rupees / 1000)} Thousand ';
      rupees %= 1000;
    }

    // Handle hundreds
    if (rupees >= 100) {
      result += '${units[rupees ~/ 100]} Hundred ';
      rupees %= 100;
    }

    // Handle tens and units
    if (rupees > 0) {
      if (result.isNotEmpty) {
        result += 'and ';
      }

      if (rupees < 20) {
        result += units[rupees];
      } else {
        result += tens[rupees ~/ 10];
        if (rupees % 10 > 0) {
          result += ' ${units[rupees % 10]}';
        }
      }
    }

    result += ' Rupees';

    // Handle paise
    if (paise > 0) {
      result += ' and ';
      if (paise < 20) {
        result += units[paise];
      } else {
        result += tens[paise ~/ 10];
        if (paise % 10 > 0) {
          result += ' ${units[paise % 10]}';
        }
      }
      result += ' Paise';
    }

    return result;
  }
}
