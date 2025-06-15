import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../services/logger_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen>
    with SingleTickerProviderStateMixin {
  final LoggerService _logger = LoggerService();
  late TabController _tabController;
  String _logs = 'Loading logs...';
  String _appInfo = 'Loading app info...';
  String _deviceInfo = 'Loading device info...';
  String _storageInfo = 'Loading storage info...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load logs
      _logs = await _logger.getLogContent();

      // Load app info
      final packageInfo = await PackageInfo.fromPlatform();
      _appInfo = '''
App Name: ${packageInfo.appName}
Package Name: ${packageInfo.packageName}
Version: ${packageInfo.version}
Build Number: ${packageInfo.buildNumber}
''';

      // Load device info
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo = '''
Brand: ${androidInfo.brand}
Model: ${androidInfo.model}
Android Version: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})
Manufacturer: ${androidInfo.manufacturer}
Hardware: ${androidInfo.hardware}
''';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = '''
Model: ${iosInfo.model}
System Name: ${iosInfo.systemName}
System Version: ${iosInfo.systemVersion}
Name: ${iosInfo.name}
''';
      } else {
        _deviceInfo = 'Unsupported platform';
      }

      // Load storage info
      final appDocDir = await getApplicationDocumentsDirectory();
      final appSupportDir = await getApplicationSupportDirectory();
      final tempDir = await getTemporaryDirectory();

      int appDocSize = await _calculateDirSize(appDocDir);
      int appSupportSize = await _calculateDirSize(appSupportDir);
      int tempSize = await _calculateDirSize(tempDir);

      _storageInfo = '''
App Documents Directory: ${appDocDir.path}
Size: ${_formatBytes(appDocSize)}

App Support Directory: ${appSupportDir.path}
Size: ${_formatBytes(appSupportSize)}

Temporary Directory: ${tempDir.path}
Size: ${_formatBytes(tempSize)}

Total App Storage: ${_formatBytes(appDocSize + appSupportSize + tempSize)}
''';
    } catch (e, stackTrace) {
      _logger.error('Error loading debug information', e, stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _calculateDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      _logger.warning('Error calculating directory size: $e');
    }
    return totalSize;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Information'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Logs'),
            Tab(text: 'App Info'),
            Tab(text: 'Device'),
            Tab(text: 'Storage'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_logs') {
                await _logger.clearLogs();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs cleared')),
                );
                _loadData();
              } else if (value == 'copy_logs') {
                await Clipboard.setData(ClipboardData(text: _logs));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs copied to clipboard')),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear_logs',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Clear Logs'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'copy_logs',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy Logs'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLogsTab(),
                _buildInfoTab(_appInfo, 'App Information'),
                _buildInfoTab(_deviceInfo, 'Device Information'),
                _buildInfoTab(_storageInfo, 'Storage Information'),
              ],
            ),
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _logs,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Clear Logs'),
                onPressed: () async {
                  await _logger.clearLogs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs cleared')),
                  );
                  _loadData();
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Logs'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _logs));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(String content, String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Information'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Information copied to clipboard')),
              );
            },
          ),
        ),
      ],
    );
  }
}
