import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../services/converter/batch_invoice_converter_service.dart';

class BatchConversionProgressWidget extends StatelessWidget {
  final BatchConversionProgress progress;

  const BatchConversionProgressWidget({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Converting Files',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.percentage / 100,
            backgroundColor: Colors.blue.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.percentage}%',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.currentJob} of ${progress.totalJobs}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          if (progress.currentFile.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Current file: ${path.basename(progress.currentFile)}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
