import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/apk_build_service.dart';
import '../widgets/build_configuration_widget.dart';
import '../widgets/build_progress_widget.dart';
import '../widgets/build_result_widget.dart';

class ApkBuildScreen extends StatefulWidget {
  const ApkBuildScreen({Key? key}) : super(key: key);

  @override
  State<ApkBuildScreen> createState() => _ApkBuildScreenState();
}

class _ApkBuildScreenState extends State<ApkBuildScreen> {
  final ApkBuildService _buildService = ApkBuildService();
  
  bool _isBuilding = false;
  ApkBuildResult? _buildResult;
  BuildInfo? _buildInfo;
  
  // Build configuration
  bool _splitPerAbi = true;
  bool _obfuscate = true;
  bool _shrinkResources = true;

  @override
  void initState() {
    super.initState();
    _loadBuildInfo();
  }

  Future<void> _loadBuildInfo() async {
    try {
      final buildInfo = await _buildService.getBuildInfo();
      setState(() {
        _buildInfo = buildInfo;
      });
    } catch (e) {
      _showError('Failed to load build info: $e');
    }
  }

  Future<void> _buildApk() async {
    setState(() {
      _isBuilding = true;
      _buildResult = null;
    });

    try {
      final result = await _buildService.buildProductionApk(
        splitPerAbi: _splitPerAbi,
        obfuscate: _obfuscate,
        shrinkResources: _shrinkResources,
      );

      setState(() {
        _buildResult = result;
      });

      if (result.success) {
        _showSuccess('APK built successfully!');
      } else {
        _showError('Build failed: ${result.error}');
      }
    } catch (e) {
      _showError('Build error: $e');
    } finally {
      setState(() {
        _isBuilding = false;
      });
    }
  }

  Future<void> _shareApk() async {
    if (_buildResult?.apkPath != null) {
      try {
        await _buildService.shareApk(_buildResult!.apkPath!);
      } catch (e) {
        _showError('Failed to share APK: $e');
      }
    }
  }

  Future<void> _installApk() async {
    if (_buildResult?.apkPath != null) {
      try {
        await _buildService.installApk(_buildResult!.apkPath!);
      } catch (e) {
        _showError('Failed to install APK: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build APK'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showBuildInfoDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Info Card
            if (_buildInfo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('App Name', _buildInfo!.appName),
                      _buildInfoRow('Version', '${_buildInfo!.version} (${_buildInfo!.buildNumber})'),
                      _buildInfoRow('Package', _buildInfo!.packageName),
                      _buildInfoRow('Device', _buildInfo!.deviceModel),
                      _buildInfoRow('Android', 'API ${_buildInfo!.sdkVersion} (${_buildInfo!.androidVersion})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Build Configuration
            BuildConfigurationWidget(
              splitPerAbi: _splitPerAbi,
              obfuscate: _obfuscate,
              shrinkResources: _shrinkResources,
              onSplitPerAbiChanged: (value) => setState(() => _splitPerAbi = value),
              onObfuscateChanged: (value) => setState(() => _obfuscate = value),
              onShrinkResourcesChanged: (value) => setState(() => _shrinkResources = value),
            ),
            const SizedBox(height: 16),

            // Build Progress
            if (_isBuilding) ...[
              const BuildProgressWidget(),
              const SizedBox(height: 16),
            ],

            // Build Button
            ElevatedButton.icon(
              onPressed: _isBuilding ? null : _buildApk,
              icon: _isBuilding 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.build),
              label: Text(_isBuilding ? 'Building...' : 'Build APK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Build Result
            if (_buildResult != null) ...[
              BuildResultWidget(
                buildResult: _buildResult!,
                onShare: _shareApk,
                onInstall: _installApk,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showBuildInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Build Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Build Configuration:'),
            const SizedBox(height: 8),
            Text('• Split per ABI: ${_splitPerAbi ? 'Enabled' : 'Disabled'}'),
            Text('• Code Obfuscation: ${_obfuscate ? 'Enabled' : 'Disabled'}'),
            Text('• Resource Shrinking: ${_shrinkResources ? 'Enabled' : 'Disabled'}'),
            const SizedBox(height: 16),
            const Text('This will create a production-ready APK optimized for distribution.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
