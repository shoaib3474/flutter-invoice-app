import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firebase/firebase_setup_checker.dart';
import '../../services/logger_service.dart';
import 'firebase_project_creation_guide.dart';

class FirebaseSetupScreen extends StatefulWidget {
  const FirebaseSetupScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseSetupScreen> createState() => _FirebaseSetupScreenState();
}

class _FirebaseSetupScreenState extends State<FirebaseSetupScreen> {
  final LoggerService _logger = LoggerService();
  FirebaseSetupStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseSetup();
  }

  Future<void> _checkFirebaseSetup() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await FirebaseSetupChecker.checkSetup();
      setState(() => _status = status);
    } catch (e) {
      _logger.error('Failed to check Firebase setup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkFirebaseSetup,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_status == null) {
      return const Center(
        child: Text('Unable to check Firebase setup'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          if (_status!.needsConfiguration) ...[
            _buildConfigurationGuide(),
            const SizedBox(height: 16),
          ],
          _buildServicesStatus(),
          const SizedBox(height: 16),
          _buildSetupInstructions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _status!;
    final isConfigured = status.isFullyConfigured;
    
    return Card(
      color: isConfigured ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConfigured 
                            ? 'Firebase Fully Configured' 
                            : 'Firebase Needs Configuration',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isConfigured
                            ? 'All Firebase services are ready to use'
                            : 'Some configuration steps are required',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItems() {
    final status = _status!;
    
    return Column(
      children: [
        _buildStatusItem(
          'Firebase Initialized',
          status.isInitialized,
          'Firebase SDK is loaded and ready',
        ),
        _buildStatusItem(
          'Configuration Files',
          status.hasConfigFiles,
          'google-services.json and firebase_options.dart exist',
        ),
        _buildStatusItem(
          'Valid Configuration',
          status.hasValidConfig,
          'Configuration contains real Firebase project values',
        ),
        if (status.error != null)
          _buildStatusItem(
            'Error',
            false,
            status.error!,
          ),
      ],
    );
  }

  Widget _buildStatusItem(String title, bool isValid, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 Configuration Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'To use Firebase features, you need to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildConfigStep(
              '1. Create Firebase Project',
              'Go to https://console.firebase.google.com',
            ),
            _buildConfigStep(
              '2. Add Android App',
              'Package name: com.example.flutter_invoice_app',
            ),
            _buildConfigStep(
              '3. Download google-services.json',
              'Place in android/app/ directory',
            ),
            _buildConfigStep(
              '4. Update firebase_options.dart',
              'Replace placeholder values with real config',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _copyPackageName(),
              icon: const Icon(Icons.copy),
              label: const Text('Copy Package Name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesStatus() {
    final services = _status!.servicesStatus;
    
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Firebase Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...services.entries.map((entry) => _buildServiceItem(
              entry.key,
              entry.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.error,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            service.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Setup Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Detailed Firebase setup guide:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Visit Firebase Console (console.firebase.google.com)\n'
              '2. Create new project or select existing\n'
              '3. Add Android app with package name: com.example.flutter_invoice_app\n'
              '4. Download google-services.json to android/app/\n'
              '5. Copy configuration to firebase_options.dart\n'
              '6. Enable Firestore, Authentication, and Storage\n'
              '7. Rebuild and test the app',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirebaseProjectCreationGuide(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Firebase Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _openFirebaseConsole(),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Console'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _checkFirebaseSetup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recheck'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyPackageName() {
    Clipboard.setData(const ClipboardData(text: 'com.example.flutter_invoice_app'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Package name copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openFirebaseConsole() {
    // In a real app, you'd use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open https://console.firebase.google.com in your browser'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
