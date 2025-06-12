import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_invoice_app/services/logger_service.dart';

class FirebaseSetupTestScreen extends StatefulWidget {
  const FirebaseSetupTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseSetupTestScreen> createState() => _FirebaseSetupTestScreenState();
}

class _FirebaseSetupTestScreenState extends State<FirebaseSetupTestScreen> {
  final List<TestResult> _testResults = [];
  bool _isRunningTests = false;
  final ScrollController _scrollController = ScrollController();
  final LoggerService _logger = LoggerService();
  
  // Test progress
  int _currentTestIndex = 0;
  final List<String> _testNames = [
    'Firebase Core',
    'Firebase Auth',
    'Cloud Firestore',
    'Firebase Storage',
    'Firebase Analytics',
    'Firebase Crashlytics',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.firebase, color: Colors.orange),
            SizedBox(width: 8),
            Text('Firebase Setup Test'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This test will validate your Firebase configuration and connectivity.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text('Tests include:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Firebase Core initialization'),
            Text('• Authentication service'),
            Text('• Firestore database connectivity'),
            Text('• Storage bucket access'),
            Text('• Analytics integration'),
            Text('• Crashlytics setup'),
            SizedBox(height: 12),
            Text(
              'The test will run automatically and show detailed results.',
              style: TextStyle(color: Colors.grey),
            ),
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
              _runAllTests();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Tests'),
          ),
        ],
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
      _currentTestIndex = 0;
    });

    _logger.info('Starting Firebase setup validation tests');

    // Run tests sequentially with progress updates
    await _testFirebaseCore();
    await _updateProgress(1);
    
    await _testFirebaseAuth();
    await _updateProgress(2);
    
    await _testFirestore();
    await _updateProgress(3);
    
    await _testFirebaseStorage();
    await _updateProgress(4);
    
    await _testFirebaseAnalytics();
    await _updateProgress(5);
    
    await _testFirebaseCrashlytics();
    await _updateProgress(6);

    setState(() {
      _isRunningTests = false;
    });

    _logger.info('Firebase setup validation completed');
    _scrollToBottom();
    _showResultsSummary();
  }

  Future<void> _updateProgress(int index) async {
    setState(() {
      _currentTestIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 500));
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

  Future<void> _testFirebaseCore() async {
    try {
      final app = Firebase.app();
      final projectId = app.options.projectId;
      final appId = app.options.appId;
      final apiKey = app.options.apiKey;
      
      if (projectId == null || projectId.isEmpty) {
        throw Exception('Project ID is not configured');
      }
      
      _addTestResult(
        'Firebase Core',
        true,
        'Firebase initialized successfully\n'
        'Project ID: $projectId\n'
        'App ID: ${appId ?? 'Not configured'}\n'
        'API Key: ${apiKey.isNotEmpty ? '${apiKey.substring(0, 10)}...' : 'Not configured'}',
        recommendation: 'Firebase Core is properly configured.',
      );
    } catch (e) {
      _addTestResult(
        'Firebase Core',
        false,
        'Failed to initialize Firebase: $e',
        recommendation: 'Run "flutterfire configure" to set up Firebase configuration.',
        fixCommand: 'flutterfire configure',
      );
    }
  }

  Future<void> _testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      // Test auth configuration
      await auth.fetchSignInMethodsForEmail('test@example.com').timeout(
        const Duration(seconds: 10),
      );
      
      if (currentUser != null) {
        _addTestResult(
          'Firebase Auth',
          true,
          'Authentication service active\n'
          'Current user: ${currentUser.email ?? 'Anonymous'}\n'
          'UID: ${currentUser.uid}\n'
          'Email verified: ${currentUser.emailVerified}',
          recommendation: 'User is authenticated and ready to use the app.',
        );
      } else {
        _addTestResult(
          'Firebase Auth',
          true,
          'Authentication service available\n'
          'No user currently signed in\n'
          'Service is ready for login/registration',
          recommendation: 'Auth service is working. Users can sign in when needed.',
        );
      }
    } catch (e) {
      _addTestResult(
        'Firebase Auth',
        false,
        'Authentication service error: $e',
        recommendation: 'Check Firebase Auth configuration in Firebase Console.',
        fixCommand: 'Enable Authentication in Firebase Console → Authentication → Sign-in method',
      );
    }
  }

  Future<void> _testFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Test read access
      final testDoc = await firestore
          .collection('test')
          .doc('connection')
          .get()
          .timeout(const Duration(seconds: 15));
      
      // Test write access
      await firestore
          .collection('test')
          .doc('setup_validation')
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Firebase setup validation',
        'version': '1.0.0',
      }).timeout(const Duration(seconds: 15));
      
      _addTestResult(
        'Cloud Firestore',
        true,
        'Firestore connection successful\n'
        'Read access: ✓ Working\n'
        'Write access: ✓ Working\n'
        'Test document created successfully',
        recommendation: 'Firestore is fully functional and ready for data operations.',
      );
    } catch (e) {
      String errorMessage = 'Firestore connection failed: $e';
      String recommendation = 'Check Firestore configuration and security rules.';
      String? fixCommand;
      
      if (e.toString().contains('permission-denied')) {
        recommendation = 'Update Firestore security rules to allow read/write access.';
        fixCommand = 'Update security rules in Firebase Console → Firestore → Rules';
      } else if (e.toString().contains('unavailable')) {
        recommendation = 'Check internet connection and Firebase project status.';
      }
      
      _addTestResult(
        'Cloud Firestore',
        false,
        errorMessage,
        recommendation: recommendation,
        fixCommand: fixCommand,
      );
    }
  }

  Future<void> _testFirebaseStorage() async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('test/setup_validation.txt');
      
      // Test upload
      final testData = 'Firebase setup validation - ${DateTime.now()}';
      final uploadTask = await ref.putString(testData);
      
      // Test download
      final downloadUrl = await ref.getDownloadURL();
      
      // Test metadata
      final metadata = await ref.getMetadata();
      
      _addTestResult(
        'Firebase Storage',
        true,
        'Storage operations successful\n'
        'Upload: ✓ Working\n'
        'Download URL: ✓ Generated\n'
        'File size: ${metadata.size} bytes\n'
        'Content type: ${metadata.contentType}',
        recommendation: 'Firebase Storage is fully functional for file operations.',
      );
    } catch (e) {
      String errorMessage = 'Storage operation failed: $e';
      String recommendation = 'Check Firebase Storage configuration and rules.';
      String? fixCommand;
      
      if (e.toString().contains('permission-denied')) {
        recommendation = 'Update Storage security rules to allow read/write access.';
        fixCommand = 'Update rules in Firebase Console → Storage → Rules';
      } else if (e.toString().contains('storage-bucket-not-configured')) {
        recommendation = 'Enable Firebase Storage in your project.';
        fixCommand = 'Enable Storage in Firebase Console → Storage';
      }
      
      _addTestResult(
        'Firebase Storage',
        false,
        errorMessage,
        recommendation: recommendation,
        fixCommand: fixCommand,
      );
    }
  }

  Future<void> _testFirebaseAnalytics() async {
    try {
      final analytics = FirebaseAnalytics.instance;
      
      // Test analytics by logging events
      await analytics.logEvent(
        name: 'firebase_setup_test',
        parameters: {
          'test_type': 'configuration_validation',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'app_version': '1.0.0',
        },
      );
      
      await analytics.setUserProperty(
        name: 'test_user',
        value: 'setup_validation',
      );
      
      _addTestResult(
        'Firebase Analytics',
        true,
        'Analytics integration successful\n'
        'Event logging: ✓ Working\n'
        'User properties: ✓ Working\n'
        'Test event "firebase_setup_test" logged',
        recommendation: 'Analytics is ready to track user behavior and app performance.',
      );
    } catch (e) {
      _addTestResult(
        'Firebase Analytics',
        false,
        'Analytics integration failed: $e',
        recommendation: 'Analytics may still work but with limited functionality.',
        fixCommand: 'Check Google Analytics configuration in Firebase Console',
      );
    }
  }

  Future<void> _testFirebaseCrashlytics() async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      
      // Test crashlytics functionality
      await crashlytics.setCustomKey('setup_test', 'completed');
      await crashlytics.setUserIdentifier('setup_test_user');
      
      // Log a non-fatal error for testing
      await crashlytics.recordError(
        'Firebase setup test error',
        StackTrace.current,
        fatal: false,
        information: ['This is a test error for setup validation'],
      );
      
      _addTestResult(
        'Firebase Crashlytics',
        true,
        'Crashlytics integration successful\n'
        'Custom keys: ✓ Working\n'
        'User identification: ✓ Working\n'
        'Error reporting: ✓ Working',
        recommendation: 'Crashlytics is ready to monitor app stability and crashes.',
      );
    } catch (e) {
      _addTestResult(
        'Firebase Crashlytics',
        false,
        'Crashlytics integration failed: $e',
        recommendation: 'App will work but crash reporting may be limited.',
        fixCommand: 'Check Crashlytics setup in Firebase Console → Crashlytics',
      );
    }
  }

  void _addTestResult(
    String testName,
    bool success,
    String details, {
    String? recommendation,
    String? fixCommand,
  }) {
    setState(() {
      _testResults.add(TestResult(
        testName: testName,
        success: success,
        details: details,
        timestamp: DateTime.now(),
        recommendation: recommendation,
        fixCommand: fixCommand,
      ));
    });
    _scrollToBottom();
  }

  void _showResultsSummary() {
    final passedTests = _testResults.where((r) => r.success).length;
    final totalTests = _testResults.length;
    final allPassed = passedTests == totalTests;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              allPassed ? Icons.check_circle : Icons.warning,
              color: allPassed ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Test Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$passedTests of $totalTests tests passed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: allPassed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            if (allPassed) ...[
              const Text('🎉 Excellent! Your Firebase setup is complete and working perfectly.'),
              const SizedBox(height: 8),
              const Text('You can now:'),
              const Text('• Create and manage invoices'),
              const Text('• Process payments with Stripe'),
              const Text('• Use document scanning features'),
              const Text('• Sync data across devices'),
            ] else ...[
              const Text('⚠️ Some tests failed. Your app may have limited functionality.'),
              const SizedBox(height: 8),
              const Text('Check the test results below for specific fixes.'),
            ],
          ],
        ),
        actions: [
          if (!allPassed)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showTroubleshootingGuide();
              },
              child: const Text('Troubleshooting'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (allPassed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }

  void _showTroubleshootingGuide() {
    final failedTests = _testResults.where((r) => !r.success).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting Guide'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: failedTests.length,
            itemBuilder: (context, index) {
              final test = failedTests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.testName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (test.recommendation != null) ...[
                        const SizedBox(height: 4),
                        Text(test.recommendation!),
                      ],
                      if (test.fixCommand != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  test.fixCommand!,
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: test.fixCommand!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Command copied')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runAllTests();
            },
            child: const Text('Retest'),
          ),
        ],
      ),
    );
  }

  void _copyTestResults() {
    final results = _testResults.map((result) {
      return '${result.testName}: ${result.success ? 'PASS' : 'FAIL'}\n'
             '${result.details}\n'
             '${result.recommendation ?? ''}\n'
             'Time: ${result.timestamp}\n';
    }).join('\n');
    
    Clipboard.setData(ClipboardData(text: results));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test results copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passedTests = _testResults.where((r) => r.success).length;
    final totalTests = _testResults.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _testResults.isNotEmpty ? _copyTestResults : null,
            tooltip: 'Copy Results',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunningTests ? null : _runAllTests,
            tooltip: 'Rerun Tests',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.orange.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.firebase, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Firebase Configuration Validation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isRunningTests) ...[
                  Text(
                    'Running test ${_currentTestIndex + 1} of ${_testNames.length}: ${_testNames[_currentTestIndex]}',
                    style: TextStyle(color: Colors.orange.shade600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentTestIndex + 1) / _testNames.length,
                    backgroundColor: Colors.orange.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                  ),
                ] else if (_testResults.isNotEmpty) ...[
                  Text(
                    '$passedTests of $totalTests tests passed',
                    style: TextStyle(
                      color: passedTests == totalTests ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Ready to test Firebase configuration',
                    style: TextStyle(color: Colors.orange.shade600),
                  ),
                ],
              ],
            ),
          ),
          
          // Test Results
          Expanded(
            child: _testResults.isEmpty && !_isRunningTests
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.firebase,
                          size: 64,
                          color: Colors.orange.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Firebase Setup Test',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the refresh button to start testing\nyour Firebase configuration',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _runAllTests,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Tests'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: result.success 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            child: Icon(
                              result.success ? Icons.check : Icons.error,
                              color: result.success ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            result.testName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            result.success ? 'Test passed' : 'Test failed',
                            style: TextStyle(
                              color: result.success ? Colors.green : Colors.red,
                            ),
                          ),
                          trailing: Text(
                            '${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Details:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(result.details),
                                  if (result.recommendation != null) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Recommendation:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(result.recommendation!),
                                  ],
                                  if (result.fixCommand != null) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Fix Command:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              result.fixCommand!,
                                              style: const TextStyle(fontFamily: 'monospace'),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 16),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: result.fixCommand!));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Command copied')),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TestResult {
  final String testName;
  final bool success;
  final String details;
  final DateTime timestamp;
  final String? recommendation;
  final String? fixCommand;

  TestResult({
    required this.testName,
    required this.success,
    required this.details,
    required this.timestamp,
    this.recommendation,
    this.fixCommand,
  });
}
