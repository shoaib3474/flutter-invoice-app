import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/apk_build_service.dart';

class BuildResultWidget extends StatelessWidget {
  final ApkBuildResult buildResult;
  final VoidCallback? onShare;
  final VoidCallback? onInstall;

  const BuildResultWidget({
    Key? key,
    required this.buildResult,
    this.onShare,
    this.onInstall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result header
            Row(
              children: [
                Icon(
                  buildResult.success ? Icons.check_circle : Icons.error,
                  color: buildResult.success ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  buildResult.success ? 'Build Successful!' : 'Build Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: buildResult.success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (buildResult.success) ...[
              // Success details
              _buildDetailRow(
                'APK Location',
                buildResult.apkPath ?? 'Unknown',
                copyable: true,
              ),
              _buildDetailRow(
                'File Size',
                _formatFileSize(buildResult.fileSize ?? 0),
              ),
              _buildDetailRow(
                'Build Time',
                _formatDuration(buildResult.buildDuration ?? Duration.zero),
              ),
              _buildDetailRow(
                'Configuration',
                _getBuildConfigSummary(),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share),
                      label: const Text('Share APK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onInstall,
                      icon: const Icon(Icons.install_mobile),
                      label: const Text('Install'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Build log (expandable)
              ExpansionTile(
                title: const Text('Build Log'),
                leading: const Icon(Icons.description),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Build Output',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () => _copyToClipboard(
                                context,
                                buildResult.buildLog ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          buildResult.buildLog ?? 'No build log available',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Error details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error Details:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(buildResult.error ?? 'Unknown error'),
                    if (buildResult.stackTrace != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Stack Trace:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        buildResult.stackTrace!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(null, value),
                    child: const Icon(Icons.copy, size: 16),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _getBuildConfigSummary() {
    final config = buildResult.buildConfig;
    if (config == null) return 'Unknown';
    
    final features = <String>[];
    if (config.splitPerAbi) features.add('Split ABI');
    if (config.obfuscate) features.add('Obfuscated');
    if (config.shrinkResources) features.add('Shrunk');
    
    return features.isEmpty ? 'Default' : features.join(', ');
  }

  void _copyToClipboard(BuildContext? context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
