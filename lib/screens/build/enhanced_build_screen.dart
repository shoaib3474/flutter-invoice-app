import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/build/enhanced_build_service.dart';
import 'dart:io';

class EnhancedBuildScreen extends StatefulWidget {
  const EnhancedBuildScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedBuildScreen> createState() => _EnhancedBuildScreenState();
}

class _EnhancedBuildScreenState extends State<EnhancedBuildScreen> {
  final EnhancedBuildService _buildService = EnhancedBuildService();
  bool _isBuilding = false;
  bool _buildCompleted = false;
  bool _buildSuccess = false;
  List<String> _buildLog = [];
  Map<String, dynamic>? _buildResult;
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  Future<void> _startEnhancedBuild() async {
    setState(() {
      _isBuilding = true;
      _buildCompleted = false;
      _buildLog = [];
      _buildResult = null;
    });

    try {
      final result = await _buildService.executeCompleteBuild();
      
      setState(() {
        _buildSuccess = result['success'] ?? false;
        _buildCompleted = true;
        _isBuilding = false;
        _buildLog = List<String>.from(result['buildLog'] ?? []);
        _buildResult = result;
      });

      // Auto-scroll to bottom of log
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logScrollController.hasClients) {
          _logScrollController.animateTo(
            _logScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      if (_buildSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _buildSuccess = false;
        _buildCompleted = true;
        _isBuilding = false;
        _buildLog = [..._buildLog, 'Fatal error: $e'];
      });
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    final apkCount = _buildResult?['apkFiles']?.length ?? 0;
    final buildDuration = _buildResult?['buildDuration'] ?? 0;
    
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎉 APK and App Bundle generated successfully!'),
            const SizedBox(height: 16),
            Text('Build completed in ${buildDuration}s'),
            const SizedBox(height: 8),
            Text('Generated $apkCount APK files + 1 App Bundle'),
            const SizedBox(height: 16),
            const Text('Files ready for:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('✓ Direct installation on Android devices'),
            const Text('✓ Google Play Store upload'),
            const Text('✓ Enterprise distribution'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'All files are in the release/ directory with installation scripts and documentation.',
                style: TextStyle(fontSize: 12),
              ),
            ),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/apk-installation');
            },
            child: const Text('Install APK'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The build process encountered an error.'),
            const SizedBox(height: 16),
            const Text('Common solutions:'),
            const Text('• Check your development environment'),
            const Text('• Ensure sufficient disk space'),
            const Text('• Verify Flutter and Android SDK installation'),
            const Text('• Review the build log for specific errors'),
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
              _copyLogToClipboard();
            },
            child: const Text('Copy Log'),
          ),
        ],
      ),
    );
  }

  void _openReleaseFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Build Files Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your APK and App Bundle files are located at:'),
            const SizedBox(height: 12),
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
            const Text('Generated files:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_buildResult?['apkFiles'] != null) ...[
              for (final apk in _buildResult!['apkFiles'])
                Text('• ${apk['name']} (${apk['sizeFormatted']})'),
            ],
            if (_buildResult?['bundleFile'] != null)
              Text('• ${_buildResult!['bundleFile']['name']} (${_buildResult!['bundleFile']['sizeFormatted']})'),
            const SizedBox(height: 16),
            const Text('Installation:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Run install.sh (Linux/Mac) or install.bat (Windows)'),
            const Text('• Or use the APK Installation screen in this app'),
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

  void _copyLogToClipboard() {
    final logText = _buildLog.join('\n');
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Build log copied to clipboard')),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    IconData icon;
    Color iconColor;
    
    switch (file['type']) {
      case 'debug':
        icon = Icons.bug_report;
        iconColor = Colors.orange;
        break;
      case 'release':
        icon = Icons.android;
        iconColor = Colors.green;
        break;
      case 'bundle':
        icon = Icons.archive;
        iconColor = Colors.blue;
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${file['sizeFormatted']} • ${file['architecture'] ?? 'bundle'}'),
            if (file['description'] != null)
              Text(
                file['description'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
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
        title: const Text('Create APK Files'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_buildCompleted && _buildSuccess)
            IconButton(
              icon: const Icon(Icons.install_mobile),
              onPressed: () => Navigator.pushNamed(context, '/apk-installation'),
              tooltip: 'Install APK',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buildCompleted && !_isBuilding ? _startEnhancedBuild : null,
            tooltip: 'Rebuild',
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
                                    ? 'Creating APK Files...'
                                    : _buildCompleted
                                        ? (_buildSuccess ? 'APK Files Ready!' : 'Build Failed')
                                        : 'Ready to Create APK Files',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isBuilding
                                    ? 'Building APK and App Bundle files with all optimizations...'
                                    : _buildCompleted
                                        ? (_buildSuccess 
                                            ? 'Production-ready APK and App Bundle files generated successfully'
                                            : 'Build process encountered errors - check log for details')
                                        : 'Generate optimized APK files for Android devices and App Bundle for Play Store',
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
                      const Text('This process includes code optimization, resource shrinking, and signing...'),
                    ],
                    if (_buildCompleted && _buildSuccess && _buildResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Build completed in ${_buildResult!['buildDuration']}s',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Generated ${(_buildResult!['apkFiles'] as List).length} APK files + 1 App Bundle'),
                            const Text('All files include security optimizations and are ready for distribution'),
                          ],
                        ),
                      ),
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
                  onPressed: _startEnhancedBuild,
                  icon: const Icon(Icons.build, size: 24),
                  label: Text(_buildCompleted ? 'Rebuild APK Files' : 'Create APK Files'),
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
                      'What will be created:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.android, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text('Universal APK (~18MB) - Works on all Android devices')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.architecture, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(child: Text('Architecture-specific APKs - Optimized for ARM64, ARM32, x86_64')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.archive, color: Colors.purple),
                        SizedBox(width: 8),
                        Expanded(child: Text('App Bundle (~12MB) - For Google Play Store upload')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(child: Text('Installation scripts - Automated deployment tools')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.security, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text('Security features - Code obfuscation, resource shrinking, signing')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(child: Text('Documentation - Build info, checksums, installation guides')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Build Log
            if (_buildLog.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Build Log',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyLogToClipboard,
                    tooltip: 'Copy Log',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  controller: _logScrollController,
                  child: ListView.builder(
                    controller: _logScrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _buildLog.length,
                    itemBuilder: (context, index) {
                      final logLine = _buildLog[index];
                      Color textColor = Colors.white;
                      
                      if (logLine.contains('✓') || logLine.contains('✅')) {
                        textColor = Colors.green;
                      } else if (logLine.contains('❌') || logLine.contains('Failed')) {
                        textColor = Colors.red;
                      } else if (logLine.contains('🚀') || logLine.contains('Step')) {
                        textColor = Colors.blue;
                      } else if (logLine.contains('⚠') || logLine.contains('Warning')) {
                        textColor = Colors.orange;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          logLine,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Generated Files
            if (_buildResult != null && _buildSuccess) ...[
              Text(
                'Generated Files',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              
              // APK Files
              if (_buildResult!['apkFiles'] != null) ...[
                Text(
                  'APK Files (${(_buildResult!['apkFiles'] as List).length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...(_buildResult!['apkFiles'] as List<dynamic>)
                    .map((file) => _buildFileCard(file as Map<String, dynamic>))
                    .toList(),
                const SizedBox(height: 16),
              ],
              
              // App Bundle
              if (_buildResult!['bundleFile'] != null) ...[
                Text(
                  'App Bundle',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildFileCard(_buildResult!['bundleFile'] as Map<String, dynamic>),
                const SizedBox(height: 16),
              ],
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/apk-installation'),
                      icon: const Icon(Icons.install_mobile),
                      label: const Text('Install APK'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openReleaseFolder,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('View Files'),
                    ),
                  ),
                ],
              ),
            ] else if (_buildCompleted && !_buildSuccess) ...[
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Build Failed',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The build process encountered errors. Please check the build log above for details and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _copyLogToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Error Log'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!_buildCompleted) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        size: 48,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ready to Build',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Click the button above to start creating your APK files. The process will generate optimized APK files for different device architectures and an App Bundle for Google Play Store.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Features Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Features Included:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.receipt_long, size: 16),
                          label: Text('GST Returns'),
                        ),
                        Chip(
                          avatar: Icon(Icons.description, size: 16),
                          label: Text('Invoice Management'),
                        ),
                        Chip(
                          avatar: Icon(Icons.sync_alt, size: 16),
                          label: Text('Database Migration'),
                        ),
                        Chip(
                          avatar: Icon(Icons.picture_as_pdf, size: 16),
                          label: Text('PDF Export'),
                        ),
                        Chip(
                          avatar: Icon(Icons.cloud_sync, size: 16),
                          label: Text('Cloud Sync'),
                        ),
                        Chip(
                          avatar: Icon(Icons.offline_bolt, size: 16),
                          label: Text('Offline Support'),
                        ),
                        Chip(
                          avatar: Icon(Icons.payment, size: 16),
                          label: Text('Payment Integration'),
                        ),
                        Chip(
                          avatar: Icon(Icons.analytics, size: 16),
                          label: Text('Analytics & Reports'),
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
