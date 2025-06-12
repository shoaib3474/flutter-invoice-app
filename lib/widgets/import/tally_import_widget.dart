import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/gstr1_model.dart';
import '../../services/import/tally_import_service.dart';
import '../../utils/error_handler.dart';

class TallyImportWidget extends StatefulWidget {
  final Function(GSTR1Model) onImportSuccess;
  final String gstin;
  final String returnPeriod;

  const TallyImportWidget({
    Key? key,
    required this.onImportSuccess,
    required this.gstin,
    required this.returnPeriod,
  }) : super(key: key);

  @override
  _TallyImportWidgetState createState() => _TallyImportWidgetState();
}

class _TallyImportWidgetState extends State<TallyImportWidget> {
  final TallyImportService _tallyImportService = TallyImportService();
  bool _isImporting = false;
  String? _importFilePath;
  String? _importError;

  Future<void> _importTallyData() async {
    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );

      if (result != null) {
        _importFilePath = result.files.single.path;
        if (_importFilePath != null) {
          final file = File(_importFilePath!);
          
          // Import Tally data
          final gstr1Data = await _tallyImportService.importFromFile(
            file,
            widget.gstin,
            widget.returnPeriod,
          );
          
          // Call the callback with the imported data
          widget.onImportSuccess(gstr1Data);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tally data imported successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _importError = 'Failed to import Tally data: ${e.toString()}';
      });
      ErrorHandler.logError('Tally Import Error', e);
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Tally Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import Tally data from an XML file. The file should be exported from Tally in XML format.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importTallyData,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_isImporting ? 'Importing...' : 'Import Tally XML'),
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
          ],
        ),
      ),
    );
  }
}
