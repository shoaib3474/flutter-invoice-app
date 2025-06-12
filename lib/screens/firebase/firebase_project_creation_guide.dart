import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/logger_service.dart';

class FirebaseProjectCreationGuide extends StatefulWidget {
  const FirebaseProjectCreationGuide({Key? key}) : super(key: key);

  @override
  State<FirebaseProjectCreationGuide> createState() => _FirebaseProjectCreationGuideState();
}

class _FirebaseProjectCreationGuideState extends State<FirebaseProjectCreationGuide> {
  final LoggerService _logger = LoggerService();
  int _currentStep = 0;
  final List<bool> _completedSteps = List.filled(8, false);

  final List<ProjectCreationStep> _steps = [
    ProjectCreationStep(
      title: 'Open Firebase Console',
      description: 'Navigate to the Firebase Console website',
      action: 'Visit https://console.firebase.google.com',
      details: [
        'Open your web browser',
        'Go to console.firebase.google.com',
        'Sign in with your Google account',
        'You should see the Firebase Console dashboard',
      ],
      copyableText: 'https://console.firebase.google.com',
    ),
    ProjectCreationStep(
      title: 'Create New Project',
      description: 'Start creating a new Firebase project',
      action: 'Click "Create a project" or "Add project"',
      details: [
        'Click the "Create a project" button',
        'If you have existing projects, click "Add project"',
        'You\'ll be taken to the project creation wizard',
      ],
    ),
    ProjectCreationStep(
      title: 'Project Name & ID',
      description: 'Set up your project name and ID',
      action: 'Enter project name: "Flutter Invoice App"',
      details: [
        'Project name: "Flutter Invoice App"',
        'Project ID will be auto-generated (e.g., flutter-invoice-app-12345)',
        'Note down the Project ID - you\'ll need it later',
        'Click "Continue"',
      ],
      copyableText: 'Flutter Invoice App',
    ),
    ProjectCreationStep(
      title: 'Google Analytics',
      description: 'Configure Google Analytics (optional)',
      action: 'Choose whether to enable Google Analytics',
      details: [
        'You can enable or disable Google Analytics',
        'For this app, you can disable it or use default settings',
        'Click "Continue" or "Create project"',
      ],
    ),
    ProjectCreationStep(
      title: 'Wait for Project Creation',
      description: 'Firebase will create your project',
      action: 'Wait for project setup to complete',
      details: [
        'Firebase will set up your project',
        'This usually takes 30-60 seconds',
        'You\'ll see a progress indicator',
        'Click "Continue" when ready',
      ],
    ),
    ProjectCreationStep(
      title: 'Add Android App',
      description: 'Add Android app to your Firebase project',
      action: 'Click the Android icon to add Android app',
      details: [
        'In the project overview, click the Android icon',
        'Or go to Project Settings → General → Your apps',
        'Click "Add app" and select Android',
      ],
    ),
    ProjectCreationStep(
      title: 'Android App Configuration',
      description: 'Configure your Android app settings',
      action: 'Enter the package name and app details',
      details: [
        'Android package name: com.example.flutter_invoice_app',
        'App nickname: Flutter Invoice App (optional)',
        'Debug signing certificate SHA-1: (optional for now)',
        'Click "Register app"',
      ],
      copyableText: 'com.example.flutter_invoice_app',
    ),
    ProjectCreationStep(
      title: 'Download Config File',
      description: 'Download google-services.json',
      action: 'Download and save the configuration file',
      details: [
        'Click "Download google-services.json"',
        'Save the file to your computer',
        'You\'ll need to place this in android/app/ directory',
        'Click "Next" to continue',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Firebase Project'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: _buildStepContent(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Step ${_currentStep + 1} of ${_steps.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= _currentStep 
                      ? Colors.orange 
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    final step = _steps[_currentStep];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '${_currentStep + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              step.description,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.action,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Detailed Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...step.details.map((detail) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(detail)),
                      ],
                    ),
                  )),
                  if (step.copyableText != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.copyableText!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyText(step.copyableText!),
                            tooltip: 'Copy to clipboard',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpCard(),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'If you encounter any issues during this step:',
            ),
            const SizedBox(height: 8),
            _buildHelpItem('📖 Check Firebase documentation'),
            _buildHelpItem('🔄 Refresh the Firebase Console page'),
            _buildHelpItem('🌐 Ensure you have a stable internet connection'),
            _buildHelpItem('👤 Make sure you\'re signed in to Google'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openFirebaseHelp(),
              icon: const Icon(Icons.help),
              label: const Text('Firebase Help Center'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('• $text'),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previousStep(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _markStepComplete(),
              icon: Icon(_completedSteps[_currentStep] 
                  ? Icons.check_circle 
                  : Icons.check),
              label: Text(_completedSteps[_currentStep] 
                  ? 'Step Completed' 
                  : 'Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _completedSteps[_currentStep] 
                    ? Colors.green 
                    : Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (_currentStep < _steps.length - 1) const SizedBox(width: 16),
          if (_currentStep < _steps.length - 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completedSteps[_currentStep] ? () => _nextStep() : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1 && _completedSteps[_currentStep]) {
      setState(() => _currentStep++);
    }
  }

  void _markStepComplete() {
    setState(() {
      _completedSteps[_currentStep] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Step ${_currentStep + 1} marked as complete!'),
        backgroundColor: Colors.green,
        action: _currentStep < _steps.length - 1
            ? SnackBarAction(
                label: 'Next Step',
                textColor: Colors.white,
                onPressed: () => _nextStep(),
              )
            : null,
      ),
    );

    // Auto-advance to next step after a short delay
    if (_currentStep < _steps.length - 1) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _nextStep();
      });
    } else {
      // All steps completed
      _showCompletionDialog();
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openFirebaseHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open https://firebase.google.com/support in your browser'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Project Creation Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This guide will help you create a Firebase project for your Flutter Invoice App.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Text('Key Information:'),
              SizedBox(height: 8),
              Text('• Package Name: com.example.flutter_invoice_app'),
              Text('• Project Name: Flutter Invoice App'),
              Text('• Required Services: Firestore, Authentication, Storage'),
              SizedBox(height: 16),
              Text(
                'Follow each step carefully and mark them as complete when done. The app will guide you through the entire process.',
              ),
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Project Creation Complete!'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You have successfully created your Firebase project.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text('Next Steps:'),
            SizedBox(height: 8),
            Text('1. Enable Firebase services (Firestore, Auth, Storage)'),
            Text('2. Update your app configuration files'),
            Text('3. Test the Firebase integration'),
            SizedBox(height: 16),
            Text(
              'Use the Firebase Setup Screen to continue configuration.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to settings
            },
            child: const Text('Continue Setup'),
          ),
        ],
      ),
    );
  }
}

class ProjectCreationStep {
  final String title;
  final String description;
  final String action;
  final List<String> details;
  final String? copyableText;

  ProjectCreationStep({
    required this.title,
    required this.description,
    required this.action,
    required this.details,
    this.copyableText,
  });
}
