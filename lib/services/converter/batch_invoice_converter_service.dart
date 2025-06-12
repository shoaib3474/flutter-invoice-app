import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/converter/batch_conversion_result.dart';
import '../../models/converter/conversion_job.dart';
import 'invoice_converter_service.dart';

class BatchInvoiceConverterService {
  static final BatchInvoiceConverterService _instance = BatchInvoiceConverterService._internal();
  final InvoiceConverterService _converterService = InvoiceConverterService();

  factory BatchInvoiceConverterService() {
    return _instance;
  }

  BatchInvoiceConverterService._internal();

  // Stream controller for progress updates
  final StreamController<BatchConversionProgress> _progressController = 
      StreamController<BatchConversionProgress>.broadcast();

  // Get the stream for progress updates
  Stream<BatchConversionProgress> get progressStream => _progressController.stream;

  // Convert multiple invoices at once
  Future<BatchConversionResult> convertInvoices({
    required List<ConversionJob> jobs,
    required InvoiceFormat targetFormat,
  }) async {
    final results = BatchConversionResult(
      totalJobs: jobs.length,
      successfulJobs: 0,
      failedJobs: 0,
      convertedFiles: [],
      failedFiles: [],
    );

    // Create a directory for batch results
    final directory = await getApplicationDocumentsDirectory();
    final batchDirName = 'batch_conversion_${DateTime.now().millisecondsSinceEpoch}';
    final batchDir = Directory('${directory.path}/$batchDirName');
    await batchDir.create();

    // Process each job
    for (int i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      
      // Update progress
      _updateProgress(
        currentJob: i + 1,
        totalJobs: jobs.length,
        currentFile: job.sourceFilePath,
        status: 'Converting',
      );

      try {
        // Detect source format if not provided
        InvoiceFormat sourceFormat = job.sourceFormat;
        
        // Convert the file
        final convertedFilePath = await _converterService.convertInvoiceFile(
          sourceFilePath: job.sourceFilePath,
          sourceFormat: sourceFormat,
          targetFormat: targetFormat,
        );

        // Copy the converted file to the batch directory with original name but new extension
        final originalFileName = path.basenameWithoutExtension(job.sourceFilePath);
        String extension;
        switch (targetFormat) {
          case InvoiceFormat.json:
          case InvoiceFormat.billShill:
            extension = '.json';
            break;
          case InvoiceFormat.xml:
          case InvoiceFormat.tally:
            extension = '.xml';
            break;
          case InvoiceFormat.csv:
            extension = '.csv';
            break;
          default:
            extension = '.json';
        }
        
        final newFileName = '$originalFileName$extension';
        final newFilePath = '${batchDir.path}/$newFileName';
        
        await File(convertedFilePath).copy(newFilePath);
        
        // Add to successful results
        results.convertedFiles.add(ConversionResult(
          originalFilePath: job.sourceFilePath,
          convertedFilePath: newFilePath,
          originalFileName: path.basename(job.sourceFilePath),
          convertedFileName: newFileName,
        ));
        
        results.successfulJobs++;
      } catch (e) {
        // Add to failed results
        results.failedFiles.add(FailedConversion(
          filePath: job.sourceFilePath,
          fileName: path.basename(job.sourceFilePath),
          error: e.toString(),
        ));
        
        results.failedJobs++;
      }
    }

    // Update final progress
    _updateProgress(
      currentJob: jobs.length,
      totalJobs: jobs.length,
      currentFile: '',
      status: 'Completed',
    );

    // Create a summary file
    await _createSummaryFile(batchDir.path, results);

    return results;
  }

  // Create a summary file for the batch conversion
  Future<void> _createSummaryFile(String dirPath, BatchConversionResult results) async {
    final summaryFile = File('$dirPath/conversion_summary.txt');
    final buffer = StringBuffer();
    
    buffer.writeln('Batch Conversion Summary');
    buffer.writeln('=======================');
    buffer.writeln('Date: ${DateTime.now()}');
    buffer.writeln('Total Files: ${results.totalJobs}');
    buffer.writeln('Successful: ${results.successfulJobs}');
    buffer.writeln('Failed: ${results.failedJobs}');
    buffer.writeln();
    
    if (results.convertedFiles.isNotEmpty) {
      buffer.writeln('Successful Conversions:');
      buffer.writeln('-----------------------');
      for (var result in results.convertedFiles) {
        buffer.writeln('${result.originalFileName} -> ${result.convertedFileName}');
      }
      buffer.writeln();
    }
    
    if (results.failedFiles.isNotEmpty) {
      buffer.writeln('Failed Conversions:');
      buffer.writeln('------------------');
      for (var failure in results.failedFiles) {
        buffer.writeln('${failure.fileName}: ${failure.error}');
      }
    }
    
    await summaryFile.writeAsString(buffer.toString());
  }

  // Update progress
  void _updateProgress({
    required int currentJob,
    required int totalJobs,
    required String currentFile,
    required String status,
  }) {
    _progressController.add(BatchConversionProgress(
      currentJob: currentJob,
      totalJobs: totalJobs,
      currentFile: currentFile,
      status: status,
      percentage: (currentJob / totalJobs * 100).round(),
    ));
  }

  // Dispose the stream controller
  void dispose() {
    _progressController.close();
  }
}

class BatchConversionProgress {
  final int currentJob;
  final int totalJobs;
  final String currentFile;
  final String status;
  final int percentage;

  BatchConversionProgress({
    required this.currentJob,
    required this.totalJobs,
    required this.currentFile,
    required this.status,
    required this.percentage,
  });
}
