// ignore_for_file: avoid_redundant_argument_values, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/apk_build_service.dart';

class EnhancedApkBuildScreen extends StatefulWidget {
  const EnhancedApkBuildScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedApkBuildScreen> createState() => _EnhancedApkBuildScreenState();
}

class _EnhancedApkBuildScreenState extends State<EnhancedApkBuildScreen>
    with TickerProviderStateMixin {
  final ApkBuildService _buildService = ApkBuildService();

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _successController;
  late Animation<double> _progressAnimation;
  late Animation<double> _successAnimation;

  // Build state
  bool _isBuilding = false;
  bool _buildCompleted = false;
  ApkBuildResult? _buildResult;
  BuildInfo? _buildInfo;

  // Build configuration
  bool _splitPerAbi = true;
  bool _obfuscate = true;
  bool _shrinkResources = true;
  String _buildType = 'release';

  // Progress tracking
  int _currentStep = 0;
  Timer? _progressTimer;

  final List<BuildStep> _buildSteps = [
    BuildStep(
        'Initializing', 'Setting up build environment...', Icons.settings),
    BuildStep(
        'Cleaning', 'Cleaning previous builds...', Icons.cleaning_services),
    BuildStep('Dependencies', 'Getting dependencies...', Icons.download),
    BuildStep('Code Generation', 'Generating code...', Icons.code),
    BuildStep('Compiling', 'Compiling Dart code...', Icons.build),
    BuildStep('Optimizing', 'Optimizing resources...', Icons.tune),
    BuildStep('Signing', 'Signing APK...', Icons.verified),
    BuildStep('Finalizing', 'Finalizing build...', Icons.check_circle),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBuildInfo();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _successController.dispose();
    _progressTimer?.cancel();
    super.dispose();
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

  Future<void> _startBuild() async {
    setState(() {
      _isBuilding = true;
      _buildCompleted = false;
      _buildResult = null;
      _currentStep = 0;
    });

    await _progressController.forward();
    _simulateBuildProgress();

    try {
      final result = await _buildService.buildProductionApk(
        splitPerAbi: _splitPerAbi,
        obfuscate: _obfuscate,
        shrinkResources: _shrinkResources,
      );

      setState(() {
        _buildResult = result;
        _buildCompleted = true;
      });

      if (result.success) {
        await _successController.forward();
        _showSuccess('🎉 APK built successfully!');
        _showBuildCompletionDialog();
      } else {
        _showError('❌ Build failed: ${result.error}');
      }
    } catch (e) {
      _showError('🚨 Build error: $e');
    } finally {
      setState(() {
        _isBuilding = false;
      });
      _progressTimer?.cancel();
    }
  }

  void _simulateBuildProgress() {
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStep < _buildSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showBuildCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _successAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _successAnimation.value,
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text('Build Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Your APK has been built successfully with the following optimizations:'),
            const SizedBox(height: 12),
            if (_splitPerAbi)
              _buildFeatureChip('Split per ABI', Icons.architecture),
            if (_obfuscate)
              _buildFeatureChip('Code Obfuscation', Icons.security),
            if (_shrinkResources)
              _buildFeatureChip('Resource Shrinking', Icons.compress),
            const SizedBox(height: 12),
            if (_buildResult?.fileSize != null)
              Text('APK Size: ${_formatFileSize(_buildResult!.fileSize!)}'),
            if (_buildResult?.buildDuration != null)
              Text(
                  'Build Time: ${_formatDuration(_buildResult!.buildDuration!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Details'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareApk();
            },
            icon: const Icon(Icons.share),
            label: const Text('Share APK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
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
        _showSuccess('APK installation started!');
      } catch (e) {
        _showError('Failed to install APK: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Info Card
              _buildAppInfoCard(),
              const SizedBox(height: 16),

              // Build Configuration
              _buildConfigurationCard(),
              const SizedBox(height: 16),

              // Build Progress (when building)
              if (_isBuilding) ...[
                _buildProgressCard(),
                const SizedBox(height: 16),
              ],

              // Build Button
              _buildActionButton(),
              const SizedBox(height: 16),

              // Build Result (when completed)
              if (_buildCompleted && _buildResult != null) ...[
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.android, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GST Invoice App',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Production APK Builder',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_buildInfo != null) ...[
              _buildInfoRow('Version',
                  '${_buildInfo!.version} (${_buildInfo!.buildNumber})'),
              _buildInfoRow('Package', _buildInfo!.packageName),
              _buildInfoRow('Target SDK', 'API ${_buildInfo!.sdkVersion}'),
              _buildInfoRow('Device', _buildInfo!.deviceModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Build Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Build Type Selector
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build_circle, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text('Build Type:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _buildType,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'debug', child: Text('Debug')),
                      DropdownMenuItem(
                          value: 'profile', child: Text('Profile')),
                      DropdownMenuItem(
                          value: 'release', child: Text('Release')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _buildType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Optimization Options
            _buildOptimizationTile(
              'Split per ABI',
              'Create separate APKs for different CPU architectures',
              Icons.architecture,
              _splitPerAbi,
              (value) => setState(() => _splitPerAbi = value),
              'Reduces APK size by ~60%',
            ),

            _buildOptimizationTile(
              'Code Obfuscation',
              'Obfuscate Dart code to prevent reverse engineering',
              Icons.security,
              _obfuscate,
              (value) => setState(() => _obfuscate = value),
              'Enhances app security',
            ),

            _buildOptimizationTile(
              'Resource Shrinking',
              'Remove unused resources to reduce APK size',
              Icons.compress,
              _shrinkResources,
              (value) => setState(() => _shrinkResources = value),
              'Reduces APK size by ~20%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    String benefit,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: value ? Colors.green : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: value ? Colors.green.withOpacity(0.05) : null,
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              benefit,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        secondary: Icon(icon, color: value ? Colors.green : Colors.grey),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _progressAnimation.value * 2 * 3.14159,
                      child: const Icon(
                        Icons.build,
                        color: Colors.blue,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Building APK...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: (_currentStep + 1) /
                      _buildSteps.length *
                      _progressAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                );
              },
            ),
            const SizedBox(height: 8),

            Text(
              'Step ${_currentStep + 1} of ${_buildSteps.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Current step
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buildSteps[_currentStep].title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _buildSteps[_currentStep].message,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _buildSteps[_currentStep].icon,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _isBuilding
            ? LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[500]!],
              )
            : const LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
        boxShadow: [
          BoxShadow(
            color: (_isBuilding ? Colors.grey : Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isBuilding ? null : _startBuild,
        icon: _isBuilding
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.build, size: 24),
        label: Text(
          _isBuilding ? 'Building APK...' : 'Build Production APK',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _successAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _successAnimation.value,
                      child: Icon(
                        _buildResult!.success
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            _buildResult!.success ? Colors.green : Colors.red,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  _buildResult!.success ? 'Build Successful!' : 'Build Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color:
                            _buildResult!.success ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_buildResult!.success) ...[
              // Success details
              _buildDetailRow(
                  'APK Location', _buildResult!.apkPath ?? 'Unknown'),
              _buildDetailRow(
                  'File Size', _formatFileSize(_buildResult!.fileSize ?? 0)),
              _buildDetailRow(
                  'Build Time',
                  _formatDuration(
                      _buildResult!.buildDuration ?? Duration.zero)),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareApk,
                      icon: const Icon(Icons.share),
                      label: const Text('Share APK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _installApk,
                      icon: const Icon(Icons.install_mobile),
                      label: const Text('Install'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Error details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(_buildResult!.error ?? 'Unknown error'),
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
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('APK Build Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Build Types:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Debug: For development and testing'),
              Text('• Profile: For performance testing'),
              Text('• Release: For production distribution'),
              SizedBox(height: 12),
              Text('Optimizations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '• Split per ABI: Creates smaller APKs for each device type'),
              Text(
                  '• Code Obfuscation: Protects your code from reverse engineering'),
              Text(
                  '• Resource Shrinking: Removes unused resources to reduce size'),
              SizedBox(height: 12),
              Text(
                  'The build process typically takes 2-5 minutes depending on your device performance.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class BuildStep {
  BuildStep(this.title, this.message, this.icon);
  final String title;
  final String message;
  final IconData icon;
}
