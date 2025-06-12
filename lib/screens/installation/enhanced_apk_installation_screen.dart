import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/installation/enhanced_device_installation_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EnhancedApkInstallationScreen extends StatefulWidget {
  const EnhancedApkInstallationScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedApkInstallationScreen> createState() => _EnhancedApkInstallationScreenState();
}

class _EnhancedApkInstallationScreenState extends State<EnhancedApkInstallationScreen> {
  final EnhancedDeviceInstallationService _installationService = EnhancedDeviceInstallationService();
  
  List<AndroidDevice> _devices = [];
  List<String> _availableApks = [];
  bool _isScanning = false;
  bool _isInstalling = false;
  String? _selectedApk;
  AndroidDevice? _selectedDevice;
  List<String> _installationLogs = [];
  InstallationResult? _lastInstallResult;
  bool _autoSelectApk = true;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
    _loadAvailableApks();
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      final devices = await _installationService.getConnectedDevices();
      setState(() {
        _devices = devices;
        if (devices.isNotEmpty && _selectedDevice == null) {
          _selectedDevice = devices.first;
          _updateApkSelection();
        }
      });
    } catch (e) {
      _showErrorDialog('Device Scan Failed', e.toString());
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _loadAvailableApks() async {
    try {
      final apks = await _installationService.getAvailableApks();
      setState(() {
        _availableApks = apks;
        _updateApkSelection();
      });
    } catch (e) {
      _showErrorDialog('APK Loading Failed', e.toString());
    }
  }

  void _updateApkSelection() {
    if (_autoSelectApk && _selectedDevice != null && _availableApks.isNotEmpty) {
      final bestApk = _installationService.getBestApkForDevice(_selectedDevice!, _availableApks);
      setState(() {
        _selectedApk = bestApk;
      });
    }
  }

  Future<void> _quickInstall() async {
    if (_selectedDevice == null || _availableApks.isEmpty) {
      _showErrorDialog('Setup Required', 'Please connect a device and generate APK files first.');
      return;
    }

    // Auto-select best APK if none selected
    if (_selectedApk == null) {
      _selectedApk = _installationService.getBestApkForDevice(_selectedDevice!, _availableApks);
    }

    if (_selectedApk == null) {
      _showErrorDialog('No APK Available', 'No compatible APK found for this device.');
      return;
    }

    await _installApk();
  }

  Future<void> _installApk() async {
    if (_selectedDevice == null || _selectedApk == null) {
      _showErrorDialog('Selection Required', 'Please select both a device and an APK file.');
      return;
    }

    setState(() {
      _isInstalling = true;
      _installationLogs.clear();
      _lastInstallResult = null;
    });

    try {
      final result = await _installationService.installApk(
        _selectedDevice!.id,
        _selectedApk!,
        onProgress: (message) {
          setState(() {
            _installationLogs.add(message);
          });
        },
      );

      setState(() {
        _lastInstallResult = result;
      });

      if (result.success) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog('Installation Failed', result.message);
      }
    } catch (e) {
      _showErrorDialog('Installation Error', e.toString());
    } finally {
      setState(() {
        _isInstalling = false;
      });
    }
  }

  void _showSuccessDialog(InstallationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Installation Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Flutter Invoice App installed successfully!'),
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
                  Text('📱 Device: ${_selectedDevice!.displayName}'),
                  Text('📦 Package: ${result.packageName ?? 'com.example.flutter_invoice_app'}'),
                  Text('🏗️ APK: ${path.basename(_selectedApk!)}'),
                  Text('🔧 Architecture: ${_selectedDevice!.architectureDisplayName}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('The Flutter Invoice App is now ready to use on your device!'),
            const SizedBox(height: 8),
            const Text('Features available:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• GST Returns (GSTR-1, GSTR-3B, GSTR-4, GSTR-9, GSTR-9C)'),
            const Text('• Invoice Management'),
            const Text('• Data Migration & Sync'),
            const Text('• PDF Export & Sharing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (result.packageName != null)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchApp(result.packageName!);
              },
              icon: const Icon(Icons.launch),
              label: const Text('Launch App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchApp(String packageName) async {
    if (_selectedDevice != null) {
      final launched = await _installationService.launchApp(_selectedDevice!.id, packageName);
      if (launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Flutter Invoice App launched successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Could not launch app automatically. Please open it manually from your device.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('Troubleshooting Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Ensure USB debugging is enabled'),
            const Text('• Check USB cable connection'),
            const Text('• Allow installation from unknown sources'),
            const Text('• Try a different USB port'),
          ],
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

  Widget _buildQuickInstallCard() {
    final canQuickInstall = _devices.isNotEmpty && _availableApks.isNotEmpty;
    final recommendedApk = _selectedDevice != null 
        ? _installationService.getBestApkForDevice(_selectedDevice!, _availableApks)
        : null;

    return Card(
      elevation: 4,
      color: canQuickInstall ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  canQuickInstall ? Icons.flash_on : Icons.warning,
                  color: canQuickInstall ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canQuickInstall ? 'Quick Install Ready!' : 'Setup Required',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        canQuickInstall 
                            ? 'Optimal APK selected for your device'
                            : 'Connect device and generate APK files',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canQuickInstall && recommendedApk != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📱 ${_selectedDevice!.displayName}'),
                    Text('🏗️ ${path.basename(recommendedApk)}'),
                    Text('🔧 ${_selectedDevice!.architectureDisplayName}'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canQuickInstall && !_isInstalling ? _quickInstall : null,
                icon: _isInstalling 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(canQuickInstall ? Icons.install_mobile : Icons.settings),
                label: Text(
                  _isInstalling 
                      ? 'Installing...'
                      : canQuickInstall 
                          ? 'Quick Install'
                          : 'Setup Required',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: canQuickInstall ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(AndroidDevice device) {
    final isSelected = _selectedDevice?.id == device.id;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          device.isEmulator ? Icons.computer : Icons.phone_android,
          color: isSelected ? Theme.of(context).primaryColor : null,
          size: 32,
        ),
        title: Text(
          device.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.id}'),
            if (device.detailsText.isNotEmpty) Text(device.detailsText),
            Text('Architecture: ${device.architectureDisplayName}'),
            if (device.isEmulator) 
              const Text('Emulator', style: TextStyle(color: Colors.orange)),
          ],
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          setState(() {
            _selectedDevice = device;
            _updateApkSelection();
          });
        },
      ),
    );
  }

  Widget _buildApkCard(String apkPath) {
    final isSelected = _selectedApk == apkPath;
    final fileName = path.basename(apkPath);
    final file = File(apkPath);
    final sizeInMB = file.existsSync() 
        ? (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)
        : 'Unknown';

    String apkType = 'Unknown';
    Color typeColor = Colors.grey;
    bool isRecommended = false;
    
    if (fileName.contains('debug')) {
      apkType = 'Debug Build';
      typeColor = Colors.orange;
    } else if (fileName.contains('release')) {
      apkType = 'Release Build';
      typeColor = Colors.green;
      
      if (fileName.contains('arm64')) {
        apkType = 'Release (ARM64)';
      } else if (fileName.contains('armeabi')) {
        apkType = 'Release (ARM32)';
      } else if (fileName.contains('x86_64')) {
        apkType = 'Release (x86_64)';
      } else if (!fileName.contains('arm') && !fileName.contains('x86')) {
        apkType = 'Release (Universal)';
      }
    }

    // Check if this is the recommended APK for the selected device
    if (_selectedDevice != null) {
      final recommendedApk = _installationService.getBestApkForDevice(_selectedDevice!, _availableApks);
      isRecommended = recommendedApk == apkPath;
    }

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              Icons.android,
              color: isSelected ? Theme.of(context).primaryColor : typeColor,
              size: 32,
            ),
            if (isRecommended)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          fileName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $apkType'),
            Text('Size: ${sizeInMB}MB'),
            if (isRecommended)
              const Text(
                '⭐ Recommended for this device',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          setState(() {
            _selectedApk = apkPath;
            _autoSelectApk = false; // Disable auto-selection when user manually selects
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Install Flutter Invoice App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : () {
              _scanForDevices();
              _loadAvailableApks();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Install Section
            _buildQuickInstallCard(),
            
            const SizedBox(height: 20),

            // Installation Status
            if (_isInstalling || _lastInstallResult != null) ...[
              Card(
                color: _lastInstallResult?.success == true 
                    ? Colors.green.withOpacity(0.1)
                    : _lastInstallResult?.success == false
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isInstalling)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              _lastInstallResult!.success 
                                  ? Icons.check_circle 
                                  : Icons.error,
                              color: _lastInstallResult!.success 
                                  ? Colors.green 
                                  : Colors.red,
                              size: 24,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            _isInstalling 
                                ? 'Installing Flutter Invoice App...'
                                : _lastInstallResult!.success
                                    ? 'Installation Successful!'
                                    : 'Installation Failed',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      if (_installationLogs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _installationLogs.length,
                            itemBuilder: (context, index) {
                              return Text(
                                _installationLogs[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Connected Devices Section
            Text(
              'Connected Devices (${_devices.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            if (_isScanning)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Scanning for devices...'),
                    ],
                  ),
                ),
              )
            else if (_devices.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.phone_android, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No devices found'),
                      const SizedBox(height: 8),
                      const Text(
                        'Connect your Android device via USB and enable USB debugging.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _scanForDevices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._devices.map((device) => _buildDeviceCard(device)).toList(),

            const SizedBox(height: 24),

            // Available APKs Section
            Row(
              children: [
                Text(
                  'Available APK Files (${_availableApks.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Switch(
                  value: _autoSelectApk,
                  onChanged: (value) {
                    setState(() {
                      _autoSelectApk = value;
                      if (value) _updateApkSelection();
                    });
                  },
                ),
                const Text('Auto-select'),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_availableApks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.android, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No APK files found'),
                      const SizedBox(height: 8),
                      const Text(
                        'Generate APK files first using the build system.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/enhanced-build');
                        },
                        icon: const Icon(Icons.build),
                        label: const Text('Generate APK'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._availableApks.map((apk) => _buildApkCard(apk)).toList(),

            const SizedBox(height: 24),

            // Manual Installation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedDevice != null && 
                           _selectedApk != null && 
                           !_isInstalling)
                    ? _installApk
                    : null,
                icon: _isInstalling 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.install_mobile, size: 24),
                label: Text(
                  _isInstalling 
                      ? 'Installing...'
                      : 'Manual Install Selected APK',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Installation Guide
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Installation Guide:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text('1️⃣ Connect your Android device via USB'),
                    const Text('2️⃣ Enable "USB Debugging" in Developer Options'),
                    const Text('3️⃣ Allow "Install from Unknown Sources" if prompted'),
                    const Text('4️⃣ Click "Quick Install" for automatic setup'),
                    const Text('5️⃣ Launch the app and start using GST features!'),
                    const SizedBox(height: 12),
                    Text(
                      '🔧 Troubleshooting:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Check USB cable and try different ports'),
                    const Text('• Restart ADB: adb kill-server && adb start-server'),
                    const Text('• Enable "File Transfer" mode on device'),
                    const Text('• Grant installation permissions when prompted'),
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
