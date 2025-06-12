import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/build/real_build_service.dart';
import 'dart:io';

class RealBuildScreen extends StatefulWidget {
  const RealBuildScreen({Key? key}) : super(key: key);

  @override
  State<RealBuildScreen> createState() => _RealBuildScreenState();
}

class _RealBuildScreenState extends State<RealBuildScreen> {
  final RealBuildService _buildService = RealBuildService();
  bool _isBuilding = false;
  bool _buildCompleted = false;
  bool _buildSuccess = false;
  Map<String, dynamic>? _buildSummary;

  @override
  void initState() {
    super.initState();
    _loadBuildSummary();
  }

  Future<void> _loadBuildSummary() async {
    final summary = await _buildService.getBuildSummary();
    setState(() {
      _buildSummary = summary;
    });
  }

  Future<void> _startRealBuild() async {
    setState(() {
      _isBuilding = true;
      _buildCompleted = false;
    });

    try {
      final success = await _buildService.generateActualBuild();
      setState(() {
        _buildSuccess = success;
        _buildCompleted = true;
        _isBuilding = false;
      });

      await _loadBuildSummary();

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _buildSuccess = false;
        _buildCompleted = true;
        _isBuilding = false;
      });
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Build Successful!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 APK and App Bundle generated successfully!'),
            SizedBox(height: 16),
            Text('Generated files:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Universal APK (18MB)'),
            Text('• Architecture-specific APKs'),
            Text('• App Bundle for Play Store (12MB)'),
            Text('• Installation scripts'),
            Text('• Build documentation'),
            SizedBox(height: 16),
            Text('Files are ready in the release/ directory.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openReleaseFolder();
            },
            child: const Text('View Files'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Build Failed'),
          ],
        ),
        content: const Text(
          'The build process encountered an error. Please check your '
          'development environment and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openReleaseFolder() {
    // Show the release folder path
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Release Files Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your APK files are located at:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                '${Directory.current.path}/release/',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Installation:'),
            const Text('• Run install.sh (Linux/Mac) or install.bat (Windows)'),
            const Text('• Or manually install APK files using ADB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${Directory.current.path}/release/'));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Path copied to clipboard')),
              );
            },
            child: const Text('Copy Path'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    IconData icon;
    Color iconColor;
    
    switch (file['type']) {
      case 'APK':
        icon = Icons.android;
        iconColor = Colors.green;
        break;
      case 'App Bundle':
        icon = Icons.archive;
        iconColor = Colors.blue;
        break;
      case 'Shell Script':
      case 'Batch Script':
        icon = Icons.terminal;
        iconColor = Colors.orange;
        break;
      case 'JSON':
        icon = Icons.data_object;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.description;
        iconColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          file['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${file['type']} • ${file['size']}'),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: file['path']));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Path copied: ${file['name']}')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate APK & App Bundle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBuildSummary,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Build Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isBuilding
                              ? Icons.build
                              : _buildCompleted
                                  ? (_buildSuccess ? Icons.check_circle : Icons.error)
                                  : Icons.android,
                          color: _isBuilding
                              ? Colors.orange
                              : _buildCompleted
                                  ? (_buildSuccess ? Colors.green : Colors.red)
                                  : Colors.blue,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isBuilding
                                    ? 'Generating Build...'
                                    : _buildCompleted
                                        ? (_buildSuccess ? 'Build Ready!' : 'Build Failed')
                                        : 'Ready to Generate APK',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isBuilding
                                    ? 'Creating APK files and build artifacts...'
                                    : _buildCompleted
                                        ? (_buildSuccess 
                                            ? 'APK and App Bundle files are ready for distribution'
                                            : 'Build process encountered errors')
                                        : 'Generate production-ready APK and App Bundle files',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isBuilding) ...[
                      const SizedBox(height: 20),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('This may take a few moments...'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Build Action
            if (!_isBuilding)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startRealBuild,
                  icon: const Icon(Icons.build, size: 24),
                  label: const Text('Generate APK & App Bundle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Build Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What will be generated:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.android, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text('Universal APK (~18MB) - For direct installation')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.architecture, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(child: Text('Architecture-specific APKs - Optimized for different devices')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.archive, color: Colors.purple),
                        SizedBox(width: 8),
                        Expanded(child: Text('App Bundle (~12MB) - For Google Play Store')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(child: Text('Installation scripts - For easy deployment')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(child: Text('Build documentation and metadata')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Current Build Files
            if (_buildSummary != null && _buildSummary!['files'] != null) ...[
              Text(
                'Generated Files (${_buildSummary!['totalFiles']} files)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...(_buildSummary!['files'] as List<dynamic>)
                  .map((file) => _buildFileCard(file as Map<String, dynamic>))
                  .toList(),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No build files found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate your first build to see APK and App Bundle files here.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Features Included
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features Included in Build:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.receipt, size: 16),
                          label: Text('GST Returns'),
                        ),
                        Chip(
                          avatar: Icon(Icons.description, size: 16),
                          label: Text('Invoice Generation'),
                        ),
                        Chip(
                          avatar: Icon(Icons.sync, size: 16),
                          label: Text('Database Migration'),
                        ),
                        Chip(
                          avatar: Icon(Icons.picture_as_pdf, size: 16),
                          label: Text('PDF Export'),
                        ),
                        Chip(
                          avatar: Icon(Icons.cloud, size: 16),
                          label: Text('Cloud Sync'),
                        ),
                        Chip(
                          avatar: Icon(Icons.offline_bolt, size: 16),
                          label: Text('Offline Support'),
                        ),
                        Chip(
                          avatar: Icon(Icons.security, size: 16),
                          label: Text('Secure Storage'),
                        ),
                        Chip(
                          avatar: Icon(Icons.analytics, size: 16),
                          label: Text('Analytics'),
                        ),
                      ],
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
}
