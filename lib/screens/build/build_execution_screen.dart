import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tools/build_executor.dart';

class BuildExecutionScreen extends StatefulWidget {
  const BuildExecutionScreen({Key? key}) : super(key: key);

  @override
  State<BuildExecutionScreen> createState() => _BuildExecutionScreenState();
}

class _BuildExecutionScreenState extends State<BuildExecutionScreen> {
  final BuildExecutor _buildExecutor = BuildExecutor();
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isBuilding = false;
  bool _buildCompleted = false;
  bool _buildSuccess = false;

  @override
  void initState() {
    super.initState();
    _buildExecutor.logStream.listen((log) {
      setState(() {
        _logs.add(log);
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _buildExecutor.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startBuild() async {
    setState(() {
      _isBuilding = true;
      _buildCompleted = false;
      _logs.clear();
    });

    try {
      final success = await _buildExecutor.executeCompleteBuild();
      setState(() {
        _buildSuccess = success;
        _buildCompleted = true;
        _isBuilding = false;
      });

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
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Build Successful!'),
          ],
        ),
        content: const Text(
          'The complete release build process has finished successfully. '
          'Check the release/ directory for your APK and App Bundle files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openReleaseDirectory();
            },
            child: const Text('Open Release Folder'),
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
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Build Failed'),
          ],
        ),
        content: const Text(
          'The build process encountered errors. Please check the logs above '
          'for details and resolve any issues before trying again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyLogsToClipboard();
            },
            child: const Text('Copy Logs'),
          ),
        ],
      ),
    );
  }

  void _openReleaseDirectory() {
    // In a real app, you would open the file manager to the release directory
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Release directory: ./release/'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _copyLogsToClipboard() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release Build Execution'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_buildCompleted)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyLogsToClipboard,
              tooltip: 'Copy Logs',
            ),
          if (_buildCompleted && _buildSuccess)
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _openReleaseDirectory,
              tooltip: 'Open Release Folder',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                                  : Icons.play_circle_outline,
                          color: _isBuilding
                              ? Colors.orange
                              : _buildCompleted
                                  ? (_buildSuccess ? Colors.green : Colors.red)
                                  : Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isBuilding
                                    ? 'Building...'
                                    : _buildCompleted
                                        ? (_buildSuccess ? 'Build Successful' : 'Build Failed')
                                        : 'Ready to Build',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                _isBuilding
                                    ? 'Complete release build process in progress'
                                    : _buildCompleted
                                        ? (_buildSuccess 
                                            ? 'APK and App Bundle ready for distribution'
                                            : 'Check logs for error details')
                                        : 'Execute the complete Flutter release build process',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isBuilding) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Build Controls
          if (!_isBuilding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startBuild,
                      icon: const Icon(Icons.build),
                      label: const Text('Start Complete Build'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                        _buildCompleted = false;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Build Process Steps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Process Steps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(label: Text('Environment Check')),
                        Chip(label: Text('Project Validation')),
                        Chip(label: Text('Clean Builds')),
                        Chip(label: Text('Dependencies')),
                        Chip(label: Text('Code Generation')),
                        Chip(label: Text('Analysis')),
                        Chip(label: Text('Tests')),
                        Chip(label: Text('Migration Tests')),
                        Chip(label: Text('Keystore Check')),
                        Chip(label: Text('Build APK')),
                        Chip(label: Text('Build Bundle')),
                        Chip(label: Text('Organize Files')),
                        Chip(label: Text('Generate Info')),
                        Chip(label: Text('APK Analysis')),
                        Chip(label: Text('Installation Test')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Logs Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal),
                          const SizedBox(width: 8),
                          Text(
                            'Build Logs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${_logs.length} entries',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                'Build logs will appear here...',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                  child: SelectableText(
                                    log,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
