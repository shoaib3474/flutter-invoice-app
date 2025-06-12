import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseSetupChecklistScreen extends StatefulWidget {
  const FirebaseSetupChecklistScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseSetupChecklistScreen> createState() => _FirebaseSetupChecklistScreenState();
}

class _FirebaseSetupChecklistScreenState extends State<FirebaseSetupChecklistScreen> {
  final Map<String, bool> _checklist = {
    'install_cli': false,
    'login_firebase': false,
    'configure_flutterfire': false,
    'install_dependencies': false,
    'init_firebase': false,
    'deploy_rules': false,
    'configure_stripe': false,
    'deploy_functions': false,
    'test_configuration': false,
    'create_test_invoice': false,
  };

  final Map<String, ChecklistItem> _items = {
    'install_cli': ChecklistItem(
      title: 'Install Firebase CLI',
      description: 'Install Firebase CLI and FlutterFire CLI',
      commands: [
        'npm install -g firebase-tools',
        'dart pub global activate flutterfire_cli',
      ],
      verification: 'Run: firebase --version && flutterfire --version',
    ),
    'login_firebase': ChecklistItem(
      title: 'Login to Firebase',
      description: 'Authenticate with your Google account',
      commands: ['firebase login'],
      verification: 'Run: firebase projects:list',
    ),
    'configure_flutterfire': ChecklistItem(
      title: 'Configure FlutterFire',
      description: 'Set up Firebase for your Flutter app',
      commands: ['flutterfire configure'],
      verification: 'Check if firebase_options.dart was created',
    ),
    'install_dependencies': ChecklistItem(
      title: 'Install Dependencies',
      description: 'Install Flutter and Firebase dependencies',
      commands: ['flutter pub get'],
      verification: 'Check if packages are installed without errors',
    ),
    'init_firebase': ChecklistItem(
      title: 'Initialize Firebase Project',
      description: 'Set up Firestore, Functions, and Hosting',
      commands: ['firebase init firestore functions hosting'],
      verification: 'Check if firebase.json was created',
    ),
    'deploy_rules': ChecklistItem(
      title: 'Deploy Security Rules',
      description: 'Deploy Firestore and Storage security rules',
      commands: ['firebase deploy --only firestore:rules,storage'],
      verification: 'Check Firebase Console for updated rules',
    ),
    'configure_stripe': ChecklistItem(
      title: 'Configure Stripe',
      description: 'Set up Stripe API keys for payments',
      commands: [
        'firebase functions:config:set stripe.secret_key="sk_test_..."',
        'firebase functions:config:set stripe.webhook_secret="whsec_..."',
      ],
      verification: 'Run: firebase functions:config:get',
    ),
    'deploy_functions': ChecklistItem(
      title: 'Deploy Cloud Functions',
      description: 'Deploy payment and business logic functions',
      commands: ['./scripts/deploy_functions.sh'],
      verification: 'Check Firebase Console Functions tab',
    ),
    'test_configuration': ChecklistItem(
      title: 'Test Configuration',
      description: 'Run configuration tests in the app',
      commands: ['Go to Settings → Test Screens → Firebase Setup Test'],
      verification: 'All tests should pass',
    ),
    'create_test_invoice': ChecklistItem(
      title: 'Create Test Invoice',
      description: 'Test end-to-end functionality',
      commands: ['Create invoice → Add items → Generate PDF → Process payment'],
      verification: 'Invoice created and payment processed successfully',
    ),
  };

  void _toggleItem(String key) {
    setState(() {
      _checklist[key] = !_checklist[key]!;
    });
  }

  void _copyCommands(List<String> commands) {
    final commandText = commands.join('\n');
    Clipboard.setData(ClipboardData(text: commandText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commands copied to clipboard')),
    );
  }

  int get _completedItems => _checklist.values.where((v) => v).length;
  int get _totalItems => _checklist.length;
  double get _progress => _completedItems / _totalItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSetupInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup Progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completedItems of $_totalItems steps completed',
                  style: TextStyle(
                    color: _progress == 1.0 ? Colors.green : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Checklist Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checklist.length,
              itemBuilder: (context, index) {
                final key = _checklist.keys.elementAt(index);
                final isCompleted = _checklist[key]!;
                final item = _items[key]!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleItem(key),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(item.description),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.commands.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Commands:',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _copyCommands(item.commands),
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text('Copy'),
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: item.commands.map((command) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        command,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              'Verification: ${item.verification}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Action Buttons
          if (_progress == 1.0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/test-screens');
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Go to Test Screens'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSetupInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Information'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This checklist guides you through setting up Firebase for your GST Invoice App.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Prerequisites:'),
              Text('• Node.js installed'),
              Text('• Flutter SDK installed'),
              Text('• Google account for Firebase'),
              Text('• Stripe account for payments'),
              SizedBox(height: 16),
              Text('Important Notes:'),
              Text('• Complete steps in order'),
              Text('• Check each step before proceeding'),
              Text('• Use test keys during development'),
              Text('• Keep your API keys secure'),
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

class ChecklistItem {
  final String title;
  final String description;
  final List<String> commands;
  final String verification;

  ChecklistItem({
    required this.title,
    required this.description,
    required this.commands,
    required this.verification,
  });
}
