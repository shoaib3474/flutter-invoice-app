import 'package:flutter/material.dart';
import '../../services/installation/device_installation_service.dart';

class QuickInstallWidget extends StatefulWidget {
  const QuickInstallWidget({Key? key}) : super(key: key);

  @override
  State<QuickInstallWidget> createState() => _QuickInstallWidgetState();
}

class _QuickInstallWidgetState extends State<QuickInstallWidget> {
  final DeviceInstallationService _installationService = DeviceInstallationService();
  int _deviceCount = 0;
  int _apkCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final devices = await _installationService.getConnectedDevices();
      final apks = await _installationService.getAvailableApks();
      
      setState(() {
        _deviceCount = devices.length;
        _apkCount = apks.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceCount = 0;
        _apkCount = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final canInstall = _deviceCount > 0 && _apkCount > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canInstall ? Icons.install_mobile : Icons.phone_android,
                  color: canInstall ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canInstall ? 'Ready to Install' : 'Installation Setup',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        canInstall 
                            ? '$_deviceCount device(s), $_apkCount APK(s) available'
                            : _deviceCount == 0 
                                ? 'No devices connected'
                                : 'No APK files available',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/apk-installation');
                    },
                    icon: Icon(canInstall ? Icons.install_mobile : Icons.settings),
                    label: Text(canInstall ? 'Install APK' : 'Setup Installation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadStatus,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            if (!canInstall) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_deviceCount == 0) ...[
                      const Row(
                        children: [
                          Icon(Icons.usb, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Connect Android device via USB'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.developer_mode, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Enable USB debugging'),
                        ],
                      ),
                    ],
                    if (_apkCount == 0) ...[
                      const Row(
                        children: [
                          Icon(Icons.build, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Generate APK files first'),
                        ],
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
}
