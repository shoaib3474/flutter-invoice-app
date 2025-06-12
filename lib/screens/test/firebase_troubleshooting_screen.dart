import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseTroubleshootingScreen extends StatefulWidget {
  final List<String> failedTests;
  
  const FirebaseTroubleshootingScreen({
    Key? key,
    this.failedTests = const [],
  }) : super(key: key);

  @override
  State<FirebaseTroubleshootingScreen> createState() => _FirebaseTroubleshootingScreenState();
}

class _FirebaseTroubleshootingScreenState extends State<FirebaseTroubleshootingScreen> {
  final Map<String, TroubleshootingStep> _troubleshootingSteps = {
    'Firebase Core': TroubleshootingStep(
      title: 'Firebase Core Configuration',
      problem: 'Firebase is not properly initialized or configured',
      symptoms: [
        'App crashes on startup',
        'Firebase services unavailable',
        'Project ID not found',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Run FlutterFire Configure',
          description: 'Set up Firebase configuration for your Flutter app',
          commands: ['flutterfire configure'],
          steps: [
            'Open terminal in your project root',
            'Run: flutterfire configure',
            'Select your Firebase project',
            'Choose platforms (Android/iOS)',
            'Confirm configuration',
          ],
        ),
        TroubleshootingSolution(
          title: 'Verify Firebase Project',
          description: 'Check if Firebase project exists and is accessible',
          commands: ['firebase projects:list'],
          steps: [
            'Login to Firebase: firebase login',
            'List projects: firebase projects:list',
            'Select project: firebase use YOUR_PROJECT_ID',
          ],
        ),
        TroubleshootingSolution(
          title: 'Check google-services.json',
          description: 'Ensure Android configuration file is present',
          commands: [],
          steps: [
            'Check if android/app/google-services.json exists',
            'Download from Firebase Console if missing',
            'Place in android/app/ directory',
            'Run: flutter clean && flutter pub get',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/overview',
    ),
    
    'Firebase Auth': TroubleshootingStep(
      title: 'Firebase Authentication Setup',
      problem: 'Authentication service is not properly configured',
      symptoms: [
        'Cannot sign in users',
        'Auth methods not available',
        'Permission denied errors',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Enable Authentication',
          description: 'Enable Authentication in Firebase Console',
          commands: [],
          steps: [
            'Go to Firebase Console',
            'Select your project',
            'Navigate to Authentication',
            'Click "Get started"',
            'Enable sign-in methods (Email/Password)',
          ],
        ),
        TroubleshootingSolution(
          title: 'Configure Sign-in Methods',
          description: 'Set up email/password authentication',
          commands: [],
          steps: [
            'Firebase Console → Authentication → Sign-in method',
            'Enable "Email/Password"',
            'Enable "Email link (passwordless sign-in)" if needed',
            'Save configuration',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/auth/usage',
    ),
    
    'Cloud Firestore': TroubleshootingStep(
      title: 'Cloud Firestore Database Setup',
      problem: 'Database connection or permission issues',
      symptoms: [
        'Permission denied errors',
        'Cannot read/write data',
        'Connection timeouts',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Create Firestore Database',
          description: 'Initialize Firestore database in your project',
          commands: [],
          steps: [
            'Go to Firebase Console',
            'Navigate to Firestore Database',
            'Click "Create database"',
            'Choose "Start in test mode"',
            'Select location',
          ],
        ),
        TroubleshootingSolution(
          title: 'Update Security Rules',
          description: 'Configure Firestore security rules for development',
          commands: [
            'firebase deploy --only firestore:rules',
          ],
          steps: [
            'Create/update firestore.rules file',
            'Use test rules for development',
            'Deploy rules: firebase deploy --only firestore:rules',
            'Test access in Firebase Console',
          ],
        ),
        TroubleshootingSolution(
          title: 'Test Mode Rules',
          description: 'Temporarily use open rules for testing',
          commands: [],
          steps: [
            'Firebase Console → Firestore → Rules',
            'Replace rules with test mode rules',
            'Publish rules',
            'Note: Change to secure rules for production',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/firestore/usage',
    ),
    
    'Firebase Storage': TroubleshootingStep(
      title: 'Firebase Storage Configuration',
      problem: 'File storage access or upload issues',
      symptoms: [
        'Cannot upload files',
        'Storage bucket not found',
        'Permission denied on file operations',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Enable Firebase Storage',
          description: 'Set up Firebase Storage in your project',
          commands: [],
          steps: [
            'Go to Firebase Console',
            'Navigate to Storage',
            'Click "Get started"',
            'Choose security rules mode',
            'Select storage location',
          ],
        ),
        TroubleshootingSolution(
          title: 'Configure Storage Rules',
          description: 'Set up storage security rules',
          commands: [
            'firebase deploy --only storage',
          ],
          steps: [
            'Create/update storage.rules file',
            'Configure rules for your use case',
            'Deploy rules: firebase deploy --only storage',
            'Test file upload in console',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/storage/usage',
    ),
    
    'Firebase Analytics': TroubleshootingStep(
      title: 'Firebase Analytics Integration',
      problem: 'Analytics not tracking events or users',
      symptoms: [
        'No analytics data in console',
        'Events not being logged',
        'User properties not set',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Enable Google Analytics',
          description: 'Link Google Analytics to your Firebase project',
          commands: [],
          steps: [
            'Go to Firebase Console',
            'Navigate to Analytics',
            'Enable Google Analytics',
            'Create or link Analytics account',
            'Configure data sharing settings',
          ],
        ),
        TroubleshootingSolution(
          title: 'Verify Integration',
          description: 'Check if analytics is properly integrated',
          commands: [],
          steps: [
            'Check Firebase Console → Analytics',
            'Look for real-time events',
            'Verify app is sending data',
            'Check debug mode if needed',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/analytics/usage',
    ),
    
    'Firebase Crashlytics': TroubleshootingStep(
      title: 'Firebase Crashlytics Setup',
      problem: 'Crash reporting not working properly',
      symptoms: [
        'Crashes not reported',
        'No crash data in console',
        'Crashlytics not initialized',
      ],
      solutions: [
        TroubleshootingSolution(
          title: 'Enable Crashlytics',
          description: 'Set up Crashlytics in your project',
          commands: [],
          steps: [
            'Go to Firebase Console',
            'Navigate to Crashlytics',
            'Enable Crashlytics',
            'Follow setup instructions',
            'Force a test crash to verify',
          ],
        ),
        TroubleshootingSolution(
          title: 'Verify Gradle Configuration',
          description: 'Check Android Gradle setup for Crashlytics',
          commands: [],
          steps: [
            'Check android/build.gradle has crashlytics plugin',
            'Verify android/app/build.gradle configuration',
            'Run: flutter clean && flutter build apk',
            'Test crash reporting',
          ],
        ),
      ],
      documentation: 'https://firebase.flutter.dev/docs/crashlytics/usage',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Troubleshooting'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showGeneralHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Firebase Configuration Issues',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.failedTests.isEmpty 
                    ? 'General troubleshooting guide for Firebase setup'
                    : 'Found ${widget.failedTests.length} configuration issues that need attention',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runQuickFix,
                    icon: const Icon(Icons.build),
                    label: const Text('Quick Fix'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openFirebaseConsole,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Firebase Console'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Troubleshooting Steps
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.failedTests.isEmpty 
                ? _troubleshootingSteps.length 
                : widget.failedTests.length,
              itemBuilder: (context, index) {
                final testName = widget.failedTests.isEmpty 
                  ? _troubleshootingSteps.keys.elementAt(index)
                  : widget.failedTests[index];
                final step = _troubleshootingSteps[testName];
                
                if (step == null) return const SizedBox.shrink();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Icon(Icons.error, color: Colors.red.shade600),
                    ),
                    title: Text(
                      step.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(step.problem),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Symptoms
                            const Text(
                              'Common Symptoms:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...step.symptoms.map((symptom) => Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(symptom)),
                                ],
                              ),
                            )),
                            
                            const SizedBox(height: 16),
                            
                            // Solutions
                            const Text(
                              'Solutions:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            
                            ...step.solutions.map((solution) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.blue.shade50,
                              child: ExpansionTile(
                                title: Text(
                                  solution.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(solution.description),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Commands
                                        if (solution.commands.isNotEmpty) ...[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Commands:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextButton.icon(
                                                onPressed: () => _copyCommands(solution.commands),
                                                icon: const Icon(Icons.copy, size: 16),
                                                label: const Text('Copy All'),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade900,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: solution.commands.map((command) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 4),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        '\$ ',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontFamily: 'monospace',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          command,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'monospace',
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.copy,
                                                          size: 16,
                                                          color: Colors.white70,
                                                        ),
                                                        onPressed: () => _copyCommand(command),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        
                                        // Steps
                                        const Text(
                                          'Steps:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        ...solution.steps.asMap().entries.map((entry) {
                                          final index = entry.key + 1;
                                          final step = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: Colors.blue.shade600,
                                                  child: Text(
                                                    '$index',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(child: Text(step)),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            
                            // Documentation Link
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _openDocumentation(step.documentation),
                              icon: const Icon(Icons.book),
                              label: const Text('View Documentation'),
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
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retestConfiguration,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retest Configuration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportTroubleshootingLog,
                        icon: const Icon(Icons.download),
                        label: const Text('Export Log'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _contactSupport,
                        icon: const Icon(Icons.support),
                        label: const Text('Get Help'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyCommand(String command) {
    Clipboard.setData(ClipboardData(text: command));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Command copied: $command')),
    );
  }

  void _copyCommands(List<String> commands) {
    final commandText = commands.join('\n');
    Clipboard.setData(ClipboardData(text: commandText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${commands.length} commands copied to clipboard')),
    );
  }

  void _runQuickFix() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Fix'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Run these commands in order:'),
            SizedBox(height: 8),
            Text('1. flutterfire configure'),
            Text('2. flutter clean'),
            Text('3. flutter pub get'),
            Text('4. firebase deploy --only firestore:rules,storage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyCommands([
                'flutterfire configure',
                'flutter clean',
                'flutter pub get',
                'firebase deploy --only firestore:rules,storage',
              ]);
            },
            child: const Text('Copy Commands'),
          ),
        ],
      ),
    );
  }

  void _openFirebaseConsole() async {
    const url = 'https://console.firebase.google.com/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openDocumentation(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _retestConfiguration() {
    Navigator.pop(context); // Go back to test screen
    // The test screen should automatically rerun tests
  }

  void _exportTroubleshootingLog() {
    final log = _generateTroubleshootingLog();
    Clipboard.setData(ClipboardData(text: log));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Troubleshooting log copied to clipboard')),
    );
  }

  String _generateTroubleshootingLog() {
    final buffer = StringBuffer();
    buffer.writeln('Firebase Troubleshooting Log');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Failed Tests: ${widget.failedTests.join(', ')}');
    buffer.writeln('\n--- Recommended Actions ---');
    
    for (final testName in widget.failedTests) {
      final step = _troubleshootingSteps[testName];
      if (step != null) {
        buffer.writeln('\n$testName:');
        buffer.writeln('Problem: ${step.problem}');
        for (final solution in step.solutions) {
          buffer.writeln('\nSolution: ${solution.title}');
          for (final command in solution.commands) {
            buffer.writeln('Command: $command');
          }
        }
      }
    }
    
    return buffer.toString();
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need additional help? Try these resources:'),
            SizedBox(height: 12),
            Text('• Firebase Documentation'),
            Text('• FlutterFire GitHub Issues'),
            Text('• Stack Overflow'),
            Text('• Firebase Support'),
            SizedBox(height: 12),
            Text('Export your troubleshooting log and include it when asking for help.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportTroubleshootingLog();
            },
            child: const Text('Export Log'),
          ),
        ],
      ),
    );
  }

  void _showGeneralHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use this troubleshooting guide:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Expand the failed test sections'),
              Text('2. Read the symptoms to confirm the issue'),
              Text('3. Try solutions in order'),
              Text('4. Copy and run the provided commands'),
              Text('5. Follow the step-by-step instructions'),
              Text('6. Retest your configuration'),
              SizedBox(height: 12),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Run commands in your project root directory'),
              Text('• Make sure you\'re logged into Firebase CLI'),
              Text('• Check Firebase Console for additional info'),
              Text('• Export logs if you need to ask for help'),
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

class TroubleshootingStep {
  final String title;
  final String problem;
  final List<String> symptoms;
  final List<TroubleshootingSolution> solutions;
  final String documentation;

  TroubleshootingStep({
    required this.title,
    required this.problem,
    required this.symptoms,
    required this.solutions,
    required this.documentation,
  });
}

class TroubleshootingSolution {
  final String title;
  final String description;
  final List<String> commands;
  final List<String> steps;

  TroubleshootingSolution({
    required this.title,
    required this.description,
    required this.commands,
    required this.steps,
  });
}
