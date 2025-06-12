import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/dashboard/reconciliation_dashboard_model.dart';
import '../logger_service.dart';

class DashboardPdfService {
  static final DashboardPdfService _instance = DashboardPdfService._internal();
  final LoggerService _logger = LoggerService();

  factory DashboardPdfService() {
    return _instance;
  }

  DashboardPdfService._internal();

  // Generate PDF for Reconciliation Dashboard
  Future<Uint8List> generateDashboardPdf(ReconciliationDashboardModel dashboard) async {
    _logger.info('Generating dashboard PDF');
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final percentFormat = NumberFormat.percentPattern();

    try {
      // Load logo image if available
      pw.MemoryImage? logoImage;
      try {
        final ByteData data = await rootBundle.load('assets/images/logo.png');
        final Uint8List bytes = data.buffer.asUint8List();
        logoImage = pw.MemoryImage(bytes);
      } catch (e) {
        _logger.warning('Logo image not found: $e');
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader(
            'GST Reconciliation Dashboard',
            'Generated on: ${dateFormat.format(DateTime.now())}',
            logoImage,
            boldFont,
          ),
          footer: (context) => _buildFooter(context, font),
          build: (context) => [
            pw.SizedBox(height: 20),
            
            // Compliance Score
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Compliance Score', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      _buildComplianceScoreIndicator(dashboard.complianceScore),
                      pw.SizedBox(width: 20),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Score: ${dashboard.complianceScore.toStringAsFixed(1)}%', 
                            style: pw.TextStyle(font: boldFont, fontSize: 20)),
                          pw.SizedBox(height: 5),
                          pw.Text(_getComplianceRating(dashboard.complianceScore), 
                            style: pw.TextStyle(font: font, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary Metrics
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary Metrics', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricBox('Total Reconciliations', 
                        dashboard.totalReconciliations.toString(), font, boldFont),
                      _buildMetricBox('Pending Issues', 
                        dashboard.pendingIssues.toString(), font, boldFont),
                      _buildMetricBox('Tax Difference', 
                        currencyFormat.format(dashboard.totalTaxDifference), font, boldFont),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Reconciliation Type Metrics
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Reconciliation Type Metrics', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell('Type', boldFont, isHeader: true),
                          _buildTableCell('Count', boldFont, isHeader: true, align: pw.TextAlign.right),
                          _buildTableCell('Success Rate', boldFont, isHeader: true, align: pw.TextAlign.right),
                          _buildTableCell('Avg. Discrepancy', boldFont, isHeader: true, align: pw.TextAlign.right),
                        ],
                      ),
                      ...dashboard.reconciliationTypeMetrics.map((metric) => pw.TableRow(
                        children: [
                          _buildTableCell(metric.type, font),
                          _buildTableCell(metric.count.toString(), font, align: pw.TextAlign.right),
                          _buildTableCell(percentFormat.format(metric.successRate / 100), font, align: pw.TextAlign.right),
                          _buildTableCell(currencyFormat.format(metric.averageDiscrepancy), font, align: pw.TextAlign.right),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Monthly Metrics
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Monthly Trend', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell('Month', boldFont, isHeader: true),
                          _buildTableCell('Reconciliations', boldFont, isHeader: true, align: pw.TextAlign.right),
                          _buildTableCell('Success Rate', boldFont, isHeader: true, align: pw.TextAlign.right),
                          _buildTableCell('Tax Difference', boldFont, isHeader: true, align: pw.TextAlign.right),
                        ],
                      ),
                      ...dashboard.monthlyMetrics.map((metric) => pw.TableRow(
                        children: [
                          _buildTableCell(metric.month, font),
                          _buildTableCell(metric.reconciliationCount.toString(), font, align: pw.TextAlign.right),
                          _buildTableCell(percentFormat.format(metric.successRate / 100), font, align: pw.TextAlign.right),
                          _buildTableCell(currencyFormat.format(metric.taxDifference), font, align: pw.TextAlign.right),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Top Discrepancies
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Top Discrepancies', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell('Invoice', boldFont, isHeader: true),
                          _buildTableCell('GSTIN', boldFont, isHeader: true),
                          _buildTableCell('Type', boldFont, isHeader: true),
                          _buildTableCell('Difference', boldFont, isHeader: true, align: pw.TextAlign.right),
                        ],
                      ),
                      ...dashboard.topDiscrepancies.map((discrepancy) => pw.TableRow(
                        children: [
                          _buildTableCell(discrepancy.invoiceNumber, font),
                          _buildTableCell(discrepancy.gstin, font),
                          _buildTableCell(discrepancy.discrepancyType, font),
                          _buildTableCell(currencyFormat.format(discrepancy.amount), font, align: pw.TextAlign.right),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Recent Reconciliations
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Recent Reconciliations', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell('Date', boldFont, isHeader: true),
                          _buildTableCell('Type', boldFont, isHeader: true),
                          _buildTableCell('Status', boldFont, isHeader: true),
                          _buildTableCell('Issues', boldFont, isHeader: true, align: pw.TextAlign.right),
                        ],
                      ),
                      ...dashboard.recentReconciliations.map((reconciliation) => pw.TableRow(
                        children: [
                          _buildTableCell(dateFormat.format(reconciliation.date), font),
                          _buildTableCell(reconciliation.type, font),
                          _buildTableCell(reconciliation.status, font),
                          _buildTableCell(reconciliation.issueCount.toString(), font, align: pw.TextAlign.right),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      _logger.info('Dashboard PDF generated successfully');
      return pdf.save();
    } catch (e, stackTrace) {
      _logger.error('Error generating dashboard PDF', e, stackTrace);
      throw Exception('Failed to generate dashboard PDF: $e');
    }
  }

  // Print a PDF document
  Future<void> printDashboardPdf(ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Printing dashboard PDF');
      final pdfData = await generateDashboardPdf(dashboard);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'GST_Reconciliation_Dashboard_${DateTime.now().millisecondsSinceEpoch}',
      );
      _logger.info('Dashboard PDF printed successfully');
    } catch (e, stackTrace) {
      _logger.error('Error printing dashboard PDF', e, stackTrace);
      throw Exception('Failed to print dashboard PDF: $e');
    }
  }

  // Save PDF to file and return the file path
  Future<String> saveDashboardPdf(ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Saving dashboard PDF');
      final pdfData = await generateDashboardPdf(dashboard);
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'GST_Reconciliation_Dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pdfData);
      _logger.info('Dashboard PDF saved successfully at: ${file.path}');
      return file.path;
    } catch (e, stackTrace) {
      _logger.error('Error saving dashboard PDF', e, stackTrace);
      throw Exception('Failed to save dashboard PDF: $e');
    }
  }

  // Share PDF file
  Future<void> shareDashboardPdf(ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Sharing dashboard PDF');
      final pdfData = await generateDashboardPdf(dashboard);
      final output = await getTemporaryDirectory();
      final fileName = 'GST_Reconciliation_Dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)], text: 'GST Reconciliation Dashboard Report');
      _logger.info('Dashboard PDF shared successfully');
    } catch (e, stackTrace) {
      _logger.error('Error sharing dashboard PDF', e, stackTrace);
      throw Exception('Failed to share dashboard PDF: $e');
    }
  }

  // Open PDF file
  Future<void> openDashboardPdf(ReconciliationDashboardModel dashboard) async {
    try {
      _logger.info('Opening dashboard PDF');
      final filePath = await saveDashboardPdf(dashboard);
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _logger.warning('Could not open PDF: ${result.message}');
        throw Exception('Could not open PDF: ${result.message}');
      }
      _logger.info('Dashboard PDF opened successfully');
    } catch (e, stackTrace) {
      _logger.error('Error opening dashboard PDF', e, stackTrace);
      throw Exception('Failed to open dashboard PDF: $e');
    }
  }

  // Helper methods for building PDF components
  pw.Widget _buildHeader(String title, String subtitle, pw.MemoryImage? logoImage, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 24)),
            pw.SizedBox(height: 5),
            pw.Text(subtitle, style: pw.TextStyle(font: boldFont, fontSize: 14)),
          ],
        ),
        if (logoImage != null)
          pw.Container(
            height: 50,
            width: 50,
            child: pw.Image(logoImage),
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
            pw.Text('GST Invoice App - Confidential',
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

  pw.Widget _buildMetricBox(String title, String value, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 16)),
        ],
      ),
    );
  }

  pw.Widget _buildComplianceScoreIndicator(double score) {
    final color = _getScoreColor(score);
    return pw.Container(
      width: 100,
      height: 100,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        color: PdfColors.white,
        border: pw.Border.all(color: color, width: 5),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        '${score.toStringAsFixed(1)}%',
        style: pw.TextStyle(
          fontSize: 20,
          color: color,
        ),
      ),
    );
  }

  PdfColor _getScoreColor(double score) {
    if (score >= 90) return PdfColors.green;
    if (score >= 75) return PdfColors.lightGreen;
    if (score >= 60) return PdfColors.orange;
    return PdfColors.red;
  }

  String _getComplianceRating(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Needs Improvement';
    return 'Critical Issues';
  }
}
