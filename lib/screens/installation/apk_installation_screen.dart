import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/installation/device_installation_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ApkInstallationScreen extends StatefulWidget {
  const ApkInstallationScreen({Key? key}) : super(key: key);

  @override
  State<ApkInstallationScreen> createState() => _ApkInstallationScreenState();
}

class _ApkInstallationScreenState extends State<ApkInstallationScreen> {
  final DeviceInstallationService _installationService = DeviceInstallationService();
  
  List<AndroidDevice> _devices = [];
  List<String> _availableApks = [];
  bool _isScanning = false;
  bool _isInstalling = false;
  String? _selectedApk;
  AndroidDevice? _selectedDevice;
  List<String> _installationLogs = [];
  InstallationResult? _lastInstallResult;

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
        if (apks.isNotEmpty && _selectedApk == null) {
          // Prefer universal release APK
          _selectedApk = apks.firstWhere(
            (apk) => apk.contains('release') && !apk.contains('arm') && !apk.contains('x86'),
            orElse: () => apks.first,
          );
        }
      });
    } catch (e) {
      _showErrorDialog('APK Loading Failed', e.toString());
    }
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
            Text('🎉 APK installed successfully on ${_selectedDevice!.displayName}'),
            const SizedBox(height: 16),
            Text('Package: ${result.packageName ?? 'Unknown'}'),
            Text('Device: ${_selectedDevice!.id}'),
            Text('APK: ${path.basename(_selectedApk!)}'),
            const SizedBox(height: 16),
            const Text('The app is now ready to use on your device!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (result.packageName != null)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchApp(result.packageName!);
              },
              child: const Text('Launch App'),
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
          const SnackBar(content: Text('App launched successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch app automatically. Please open it manually.')),
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
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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
    
    if (fileName.contains('debug')) {
      apkType = 'Debug';
      typeColor = Colors.orange;
    } else if (fileName.contains('release')) {
      apkType = 'Release';
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

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          Icons.android,
          color: isSelected ? Theme.of(context).primaryColor : typeColor,
          size: 32,
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
          ],
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          setState(() {
            _selectedApk = apkPath;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Install APK on Device'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                ? 'Installing APK...'
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
                        'Make sure your Android device is connected via USB and USB debugging is enabled.',
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
            Text(
              'Available APK Files (${_availableApks.length})',
              style: Theme.of(context).textTheme.titleLarge,
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
                          Navigator.pushNamed(context, '/real-build');
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

            // Installation Button
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
                      : 'Install APK on Device',
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

            // Installation Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installation Requirements:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Android device connected via USB'),
                    const Text('• USB debugging enabled in Developer Options'),
                    const Text('• ADB (Android Debug Bridge) installed'),
                    const Text('• Device authorized for debugging'),
                    const SizedBox(height: 12),
                    Text(
                      'Troubleshooting:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Check USB cable connection'),
                    const Text('• Enable "Unknown Sources" if needed'),
                    const Text('• Grant installation permissions'),
                    const Text('• Try different USB port or cable'),
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
