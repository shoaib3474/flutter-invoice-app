import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../models/converter/batch_conversion_result.dart';

class BatchResultsWidget extends StatelessWidget {
  final BatchConversionResult result;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  const BatchResultsWidget({
    Key? key,
    required this.result,
    required this.onShare,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Batch Conversion Complete',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummary(),
          const SizedBox(height: 16),
          _buildSuccessfulConversions(),
          if (result.failedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFailedConversions(),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Folder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: const Text('Share All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total',
            result.totalJobs.toString(),
            Icons.summarize,
            Colors.blue,
          ),
          _buildSummaryItem(
            'Successful',
            result.successfulJobs.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildSummaryItem(
            'Failed',
            result.failedJobs.toString(),
            Icons.error,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessfulConversions() {
    if (result.convertedFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Successful Conversions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          height: 150,
          child: ListView.builder(
            itemCount: result.convertedFiles.length,
            itemBuilder: (context, index) {
              final conversion = result.convertedFiles[index];
              return ListTile(
                dense: true,
                title: Text(
                  conversion.originalFileName,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'Converted to: ${conversion.convertedFileName}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFailedConversions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Failed Conversions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          height: 150,
          child: ListView.builder(
            itemCount: result.failedFiles.length,
            itemBuilder: (context, index) {
              final failure = result.failedFiles[index];
              return ListTile(
                dense: true,
                title: Text(
                  failure.fileName,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'Error: ${failure.error}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 16,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
