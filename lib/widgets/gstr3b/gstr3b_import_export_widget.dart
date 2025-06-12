import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr3b_model.dart';
import 'package:flutter_invoice_app/services/gstr3b_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GSTR3BImportExportWidget extends StatefulWidget {
  const GSTR3BImportExportWidget({
    super.key,
    required this.onImportSuccess,
  });

  final Function(GSTR3BModel) onImportSuccess;

  @override
  State<GSTR3BImportExportWidget> createState() => _GSTR3BImportExportWidgetState();
}

class _GSTR3BImportExportWidgetState extends State<GSTR3BImportExportWidget> {
  final GSTR3BService _gstr3bService = GSTR3BService();
  bool _isImporting = false;
  GSTR3BModel? _previewData;
  String? _importFilePath;
  String? _importError;

  Future<void> _importGSTR3B() async {
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
          final importedData = GSTR3BModel.fromJson(jsonDecode(jsonString));
          
          setState(() {
            _previewData = importedData;
          });
        }
      }
    } catch (e) {
      setState(() {
        _importError = 'Failed to import GSTR-3B data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_previewData != null) {
      try {
        // Call the callback with the imported data
        widget.onImportSuccess(_previewData!);
        
        // Clear the preview
        setState(() {
          _previewData = null;
          _importFilePath = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GSTR-3B data imported successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _importError = 'Validation failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import/Export GSTR-3B Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Import Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import GSTR-3B Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Import GSTR-3B data from a JSON file. The file should contain valid GSTR-3B data in the correct format.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isImporting ? null : _importGSTR3B,
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
                    Text('GSTIN: ${_previewData!.gstin}'),
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
          ),
        ],
      ),
    );
  }
}
