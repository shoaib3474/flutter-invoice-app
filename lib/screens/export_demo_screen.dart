import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr1_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gstr3b_model.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:flutter_invoice_app/services/demo/demo_export_service.dart';
import 'package:flutter_invoice_app/services/export/excel_service.dart';
import 'package:flutter_invoice_app/services/export/json_service.dart';
import 'package:flutter_invoice_app/services/export/pdf_service.dart';
import 'package:flutter_invoice_app/widgets/common/export_options_widget.dart';

class ExportDemoScreen extends StatefulWidget {
  const ExportDemoScreen({Key? key}) : super(key: key);

  @override
  _ExportDemoScreenState createState() => _ExportDemoScreenState();
}

class _ExportDemoScreenState extends State<ExportDemoScreen> {
  final DemoExportService _demoService = DemoExportService();
  final PdfService _pdfService = PdfService();
  final ExcelService _excelService = ExcelService();
  final JsonService _jsonService = JsonService();

  GSTR1? _gstr1;
  GSTR3B? _gstr3b;
  ReconciliationResult? _reconciliationResult;

  bool _isLoading = false;
  String _statusMessage = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });

    try {
      final gstr1 = await _demoService.generateDemoGstr1();
      final gstr3b = await _demoService.generateDemoGstr3B();
      final reconciliationResult =
          await _demoService.generateDemoReconciliationResult();

      setState(() {
        _gstr1 = gstr1;
        _gstr3b = gstr3b;
        _reconciliationResult = reconciliationResult;
        _statusMessage = 'Demo data loaded successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading demo data: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Demo Data',
            onPressed: _loadDemoData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status message
                  if (_statusMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _isError
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isError
                              ? Colors.red.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isError ? Icons.error : Icons.check_circle,
                            color: _isError
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _isError
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // GSTR1 Export
                  if (_gstr1 != null)
                    ExportOptionsWidget(
                      title: 'GSTR-1 Export',
                      data: _gstr1!,
                      fileName:
                          'GSTR1_${_gstr1!.gstin}_${_gstr1!.returnPeriod.replaceAll(' ', '_')}',
                      onExport: (exportType) =>
                          _handleExport(exportType, 'gstr1'),
                    ),

                  const SizedBox(height: 16),

                  // GSTR3B Export
                  if (_gstr3b != null)
                    ExportOptionsWidget(
                      title: 'GSTR-3B Export',
                      data: _gstr3b!,
                      fileName:
                          'GSTR3B_${_gstr3b!.gstin}_${_gstr3b!.returnPeriod.replaceAll(' ', '_')}',
                      onExport: (exportType) =>
                          _handleExport(exportType, 'gstr3b'),
                    ),

                  const SizedBox(height: 16),

                  // Reconciliation Export
                  if (_reconciliationResult != null)
                    ExportOptionsWidget(
                      title: 'Reconciliation Export',
                      data: _reconciliationResult!,
                      fileName:
                          'Reconciliation_Report_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}',
                      onExport: (exportType) =>
                          _handleExport(exportType, 'reconciliation'),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _handleExport(ExportType exportType, String dataType) async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isError = false;
    });

    try {
      switch (exportType) {
        case ExportType.pdf:
          await _handlePdfExport(dataType);
          break;
        case ExportType.excel:
          await _handleExcelExport(dataType);
          break;
        case ExportType.json:
          await _handleJsonExport(dataType);
          break;
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting data: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePdfExport(String dataType) async {
    late Uint8List pdfData;
    late String fileName;

    switch (dataType) {
      case 'gstr1':
        pdfData = await _pdfService.generateGstr1Pdf(_gstr1!);
        fileName =
            'GSTR1_${_gstr1!.gstin}_${_gstr1!.returnPeriod.replaceAll(' ', '_')}.pdf';
        break;
      case 'gstr3b':
        pdfData = await _pdfService.generateGstr3bPdf(_gstr3b!);
        fileName =
            'GSTR3B_${_gstr3b!.gstin}_${_gstr3b!.returnPeriod.replaceAll(' ', '_')}.pdf';
        break;
      case 'reconciliation':
        pdfData =
            await _pdfService.generateReconciliationPdf(_reconciliationResult!);
        fileName =
            'Reconciliation_Report_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}.pdf';
        break;
    }

    final filePath = await _pdfService.savePdf(pdfData, fileName);
    await _pdfService.openPdf(pdfData, fileName);

    setState(() {
      _statusMessage = 'PDF exported and opened: $filePath';
    });
  }

  Future<void> _handleExcelExport(String dataType) async {
    late Uint8List excelData;
    late String fileName;

    switch (dataType) {
      case 'gstr1':
        excelData = await _excelService.generateGstr1Excel(_gstr1!);
        fileName =
            'GSTR1_${_gstr1!.gstin}_${_gstr1!.returnPeriod.replaceAll(' ', '_')}.xlsx';
        break;
      case 'gstr3b':
        excelData = await _excelService.generateGstr3bExcel(_gstr3b!);
        fileName =
            'GSTR3B_${_gstr3b!.gstin}_${_gstr3b!.returnPeriod.replaceAll(' ', '_')}.xlsx';
        break;
      case 'reconciliation':
        excelData = await _excelService
            .generateReconciliationExcel(_reconciliationResult!);
        fileName =
            'Reconciliation_Report_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}.xlsx';
        break;
    }

    final filePath = await _excelService.saveExcel(excelData, fileName);
    await _excelService.openExcel(excelData, fileName);

    setState(() {
      _statusMessage = 'Excel exported and opened: $filePath';
    });
  }

  Future<void> _handleJsonExport(String dataType) async {
    late dynamic data;
    late String fileName;

    switch (dataType) {
      case 'gstr1':
        data = _gstr1!;
        fileName =
            'GSTR1_${_gstr1!.gstin}_${_gstr1!.returnPeriod.replaceAll(' ', '_')}.json';
        break;
      case 'gstr3b':
        data = _gstr3b!;
        fileName =
            'GSTR3B_${_gstr3b!.gstin}_${_gstr3b!.returnPeriod.replaceAll(' ', '_')}.json';
        break;
      case 'reconciliation':
        data = _reconciliationResult!;
        fileName =
            'Reconciliation_Report_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}.json';
        break;
    }

    final filePath = await _jsonService.saveJson(data, fileName);
    await _jsonService.openJson(data, fileName);

    setState(() {
      _statusMessage = 'JSON exported and opened: $filePath';
    });
  }
}
