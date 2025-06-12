import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import '../models/converter/batch_conversion_result.dart';
import '../models/converter/conversion_job.dart';
import '../services/converter/batch_invoice_converter_service.dart';
import '../services/converter/invoice_converter_service.dart';
import '../services/detector/file_format_detector.dart';
import '../widgets/converter/batch_conversion_progress_widget.dart';
import '../widgets/converter/batch_results_widget.dart';

class BatchInvoiceConverterScreen extends StatefulWidget {
  const BatchInvoiceConverterScreen({Key? key}) : super(key: key);

  @override
  _BatchInvoiceConverterScreenState createState() => _BatchInvoiceConverterScreenState();
}

class _BatchInvoiceConverterScreenState extends State<BatchInvoiceConverterScreen> {
  final BatchInvoiceConverterService _batchConverterService = BatchInvoiceConverterService();
  
  List<ConversionJob> _conversionJobs = [];
  InvoiceFormat? _targetFormat;
  bool _isConverting = false;
  BatchConversionResult? _conversionResult;
  String? _errorMessage;
  
  final List<DropdownMenuItem<InvoiceFormat>> _formatItems = [
    const DropdownMenuItem(value: InvoiceFormat.billShill, child: Text('Bill-Shill')),
    const DropdownMenuItem(value: InvoiceFormat.tally, child: Text('Tally')),
    const DropdownMenuItem(value: InvoiceFormat.zoho, child: Text('Zoho')),
    const DropdownMenuItem(value: InvoiceFormat.quickbooks, child: Text('QuickBooks')),
    const DropdownMenuItem(value: InvoiceFormat.json, child: Text('JSON')),
    const DropdownMenuItem(value: InvoiceFormat.xml, child: Text('XML')),
    const DropdownMenuItem(value: InvoiceFormat.csv, child: Text('CSV')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Invoice Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFileSelector(),
            const SizedBox(height: 24),
            _buildSelectedFiles(),
            const SizedBox(height: 24),
            _buildTargetFormatSelector(),
            const SizedBox(height: 24),
            _buildConvertButton(),
            if (_isConverting) 
              StreamBuilder<BatchConversionProgress>(
                stream: _batchConverterService.progressStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return BatchConversionProgressWidget(progress: snapshot.data!);
                  }
                  return const SizedBox.shrink();
                },
              ),
            if (_errorMessage != null) _buildErrorMessage(),
            if (_conversionResult != null) 
              BatchResultsWidget(
                result: _conversionResult!,
                onShare: _shareResults,
                onOpen: _openResultsFolder,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Invoice Files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _conversionJobs.isEmpty 
                        ? 'No files selected' 
                        : '${_conversionJobs.length} files selected',
                    style: TextStyle(
                      color: _conversionJobs.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFiles() {
    if (_conversionJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Files',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _conversionJobs.clear();
                      _conversionResult = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _conversionJobs.length,
              itemBuilder: (context, index) {
                final job = _conversionJobs[index];
                final fileName = path.basename(job.sourceFilePath);
                
                return ListTile(
                  leading: _getFormatIcon(job.sourceFormat),
                  title: Text(fileName),
                  subtitle: Text(_getFormatName(job.sourceFormat)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _conversionJobs.removeAt(index);
                        if (_conversionJobs.isEmpty) {
                          _conversionResult = null;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetFormatSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Target Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InvoiceFormat>(
              decoration: const InputDecoration(
                labelText: 'Target Format',
                border: OutlineInputBorder(),
              ),
              value: _targetFormat,
              items: _formatItems,
              onChanged: (value) {
                setState(() {
                  _targetFormat = value;
                  _errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canConvert() ? _convertFiles : null,
        icon: _isConverting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.swap_horiz),
        label: Text(_isConverting ? 'Converting...' : 'Convert All Files'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFormatIcon(InvoiceFormat format) {
    IconData iconData;
    Color iconColor;
    
    switch (format) {
      case InvoiceFormat.billShill:
        iconData = Icons.receipt;
        iconColor = Colors.blue;
        break;
      case InvoiceFormat.tally:
        iconData = Icons.account_balance;
        iconColor = Colors.red;
        break;
      case InvoiceFormat.zoho:
        iconData = Icons.cloud;
        iconColor = Colors.green;
        break;
      case InvoiceFormat.quickbooks:
        iconData = Icons.book;
        iconColor = Colors.purple;
        break;
      case InvoiceFormat.json:
        iconData = Icons.code;
        iconColor = Colors.orange;
        break;
      case InvoiceFormat.xml:
        iconData = Icons.code;
        iconColor = Colors.teal;
        break;
      case InvoiceFormat.csv:
        iconData = Icons.table_chart;
        iconColor = Colors.brown;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  String _getFormatName(InvoiceFormat format) {
    switch (format) {
      case InvoiceFormat.billShill:
        return 'Bill-Shill';
      case InvoiceFormat.tally:
        return 'Tally';
      case InvoiceFormat.zoho:
        return 'Zoho';
      case InvoiceFormat.quickbooks:
        return 'QuickBooks';
      case InvoiceFormat.json:
        return 'JSON';
      case InvoiceFormat.xml:
        return 'XML';
      case InvoiceFormat.csv:
        return 'CSV';
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xml', 'csv'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _conversionResult = null;
          _errorMessage = null;
        });
        
        // Process each selected file
        for (var file in result.files) {
          if (file.path != null) {
            // Try to detect the source format
            final detectedFormat = await FileFormatDetector.detectFormat(file.path!);
            
            InvoiceFormat sourceFormat;
            if (detectedFormat != null) {
              sourceFormat = detectedFormat;
            } else {
              // If detection fails, try to determine from extension
              final extension = path.extension(file.name).toLowerCase();
              switch (extension) {
                case '.json':
                  sourceFormat = InvoiceFormat.json;
                  break;
                case '.xml':
                  sourceFormat = InvoiceFormat.xml;
                  break;
                case '.csv':
                  sourceFormat = InvoiceFormat.csv;
                  break;
                default:
                  // Skip files with unsupported extensions
                  continue;
              }
            }
            
            // Add to conversion jobs
            setState(() {
              _conversionJobs.add(ConversionJob(
                sourceFilePath: file.path!,
                sourceFormat: sourceFormat,
              ));
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting files: ${e.toString()}';
      });
    }
  }

  bool _canConvert() {
    return !_isConverting &&
        _conversionJobs.isNotEmpty &&
        _targetFormat != null;
  }

  Future<void> _convertFiles() async {
    if (!_canConvert()) return;

    setState(() {
      _isConverting = true;
      _conversionResult = null;
      _errorMessage = null;
    });

    try {
      final result = await _batchConverterService.convertInvoices(
        jobs: _conversionJobs,
        targetFormat: _targetFormat!,
      );

      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error converting files: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> _shareResults() async {
    if (_conversionResult == null) return;
    
    try {
      // Create a list of files to share
      List<XFile> files = [];
      
      // Add all successfully converted files
      for (var result in _conversionResult!.convertedFiles) {
        files.add(XFile(result.convertedFilePath));
      }
      
      // Share the files
      await Share.shareXFiles(files);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sharing files: ${e.toString()}';
      });
    }
  }

  Future<void> _openResultsFolder() async {
    if (_conversionResult == null || _conversionResult!.convertedFiles.isEmpty) return;
    
    try {
      // Get the directory of the first converted file
      final firstFile = _conversionResult!.convertedFiles.first.convertedFilePath;
      final directory = path.dirname(firstFile);
      
      // Open the directory using platform-specific method
      // This is a simplified example
      // You might want to use a package like open_file or path_provider
    } catch (e) {
      setState(() {
        _errorMessage = 'Error opening folder: ${e.toString()}';
      });
    }
  }
}
