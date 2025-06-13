// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr1_model.dart';
import 'package:flutter_invoice_app/services/export/gstr1_json_service.dart';
import 'package:flutter_invoice_app/services/gstr1_service.dart';
import 'package:flutter_invoice_app/utils/error_handler.dart';
import 'package:flutter_invoice_app/widgets/error_boundary_widget.dart';
import 'package:flutter_invoice_app/widgets/import/marg_import_widget.dart';
import 'package:flutter_invoice_app/widgets/import/tally_import_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GSTR1ImportExportWidget extends StatefulWidget {
  const GSTR1ImportExportWidget({
    required this.onImportSuccess,
    required this.gstin,
    required this.returnPeriod,
    Key? key,
  }) : super(key: key);
  final Function(GSTR1Model) onImportSuccess;
  final String gstin;
  final String returnPeriod;

  @override
  _GSTR1ImportExportWidgetState createState() =>
      _GSTR1ImportExportWidgetState();
}

class _GSTR1ImportExportWidgetState extends State<GSTR1ImportExportWidget> {
  final GSTR1Service _gstr1Service = GSTR1Service();
  final GSTR1JsonService _gstr1JsonService = GSTR1JsonService();
  bool _isImporting = false;
  bool _isExporting = false;
  GSTR1Model? _previewData;
  String? _importFilePath;
  String? _importError;
  int _selectedTab = 0;

  Future<void> _importGSTR1() async {
    setState(() {
      _isImporting = true;
      _importError = null;
      _previewData = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        _importFilePath = result.files.single.path;
        if (_importFilePath != null) {
          final file = File(_importFilePath!);
          final jsonString = await file.readAsString();

          // Parse and validate the JSON data
          final importedData = await _gstr1Service.parseGSTR1Json(jsonString);

          setState(() {
            _previewData = importedData;
          });
        }
      }
    } catch (e) {
      setState(() {
        _importError = 'Failed to import GSTR-1 data: ${e.toString()}';
      });
      ErrorHandler.logError('GSTR1 Import Error', e);
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_previewData != null) {
      try {
        // Validate the imported data
        await _gstr1Service.validateGSTR1(_previewData!);

        // Call the callback with the imported data
        widget.onImportSuccess(_previewData!);

        // Clear the preview
        setState(() {
          _previewData = null;
          _importFilePath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GSTR-1 data imported successfully')),
        );
      } catch (e) {
        setState(() {
          _importError = 'Validation failed: ${e.toString()}';
        });
        ErrorHandler.logError('GSTR1 Import Validation Error', e);
      }
    }
  }

  Future<void> _exportGSTR1(GSTR1Model data) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Convert the data to GST portal compatible JSON
      final jsonString = await _gstr1JsonService.convertToGstPortalJson(data);

      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'GSTR1_${data.gstin}_${data.returnPeriod.replaceAll(' ', '_')}.json';
      final filePath = '${directory.path}/$fileName';

      // Write the JSON to a file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareFiles(
        [filePath],
        text: 'GSTR-1 Data for ${data.gstin} - ${data.returnPeriod}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GSTR-1 data exported successfully')),
      );
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to export GSTR-1 data', e);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWidget(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import/Export GSTR-1 Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Tabs for different import options
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'JSON Import'),
                      Tab(text: 'Tally Import'),
                      Tab(text: 'Marg Import'),
                    ],
                    onTap: (index) {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  [
                    // JSON Import Tab
                    _buildJsonImportSection(),

                    // Tally Import Tab
                    TallyImportWidget(
                      onImportSuccess: widget.onImportSuccess,
                      gstin: widget.gstin,
                      returnPeriod: widget.returnPeriod,
                    ),

                    // Marg Import Tab
                    MargImportWidget(
                      onImportSuccess: widget.onImportSuccess,
                      gstin: widget.gstin,
                      returnPeriod: widget.returnPeriod,
                    ),
                  ][_selectedTab],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Export Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export GSTR-1 Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Export your GSTR-1 data to a JSON file. You can use this file to import the data into the GST portal or share it with your tax consultant.',
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<GSTR1Model>>(
                      future: _gstr1Service.getAllGSTR1Returns(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        final returns = snapshot.data ?? [];

                        if (returns.isEmpty) {
                          return const Text(
                              'No GSTR-1 returns available for export.');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select a return to export:'),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: returns.length,
                              itemBuilder: (context, index) {
                                final returnData = returns[index];
                                return ListTile(
                                  title: Text(
                                      '${returnData.gstin} - ${returnData.returnPeriod}'),
                                  subtitle: Text(
                                      'Financial Year: ${returnData.financialYear}'),
                                  trailing: ElevatedButton(
                                    onPressed: _isExporting
                                        ? null
                                        : () => _exportGSTR1(returnData),
                                    child: const Text('Export'),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import GSTR-1 Data from JSON',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import GSTR-1 data from a JSON file. The file should contain valid GSTR-1 data in the correct format.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importGSTR1,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_isImporting ? 'Importing...' : 'Import JSON'),
                ),
                if (_importFilePath != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File: ${_importFilePath!.split('/').last}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Error message
            if (_importError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _importError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Preview data
            if (_previewData != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Preview Imported Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPreviewInfo('GSTIN', _previewData!.gstin),
              _buildPreviewInfo(
                  'Financial Year', _previewData!.financialYear ?? 'N/A'),
              _buildPreviewInfo('Tax Period', _previewData!.returnPeriod),
              _buildPreviewInfo(
                  'B2B Invoices', _previewData!.b2bInvoices.length.toString()),
              _buildPreviewInfo('B2C Large Invoices',
                  _previewData!.b2clInvoices.length.toString()),
              _buildPreviewInfo('B2C Small Invoices',
                  _previewData!.b2csInvoices.length.toString()),
              _buildPreviewInfo('HSN Summary Items',
                  _previewData!.hsnSummary.length.toString()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _previewData = null;
                        _importFilePath = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _confirmImport,
                    child: const Text('Confirm Import'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
}
