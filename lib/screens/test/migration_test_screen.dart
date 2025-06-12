import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/tests/migration_test_suite.dart';
import 'package:flutter_invoice_app/utils/responsive_helper.dart';

class MigrationTestScreen extends StatefulWidget {
  const MigrationTestScreen({Key? key}) : super(key: key);

  @override
  _MigrationTestScreenState createState() => _MigrationTestScreenState();
}

class _MigrationTestScreenState extends State<MigrationTestScreen> {
  final MigrationTestSuite _testSuite = MigrationTestSuite();
  
  bool _isRunning = false;
  TestResult? _result;
  String _currentTest = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Test Suite'),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestControls(),
            const SizedBox(height: 24),
            if (_isRunning) _buildRunningTests(),
            if (_result != null) _buildTestResults(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migration Test Suite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'This test suite validates the database migration functionality by testing various migration scenarios including SQLite to JSON, JSON to SQLite, Supabase integration, large datasets, partial migrations, and error handling.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runTests,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isRunning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Running Tests...'),
                        ],
                      )
                    : const Text('Run Migration Tests'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRunningTests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running Tests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text('Current Test: $_currentTest'),
            const SizedBox(height: 16),
            const Text(
              'Test Progress:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• SQLite to JSON migration'),
                Text('• JSON to SQLite migration'),
                Text('• SQLite to Supabase migration'),
                Text('• Large dataset migration'),
                Text('• Partial migration'),
                Text('• Error handling'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestResults() {
    return Card(
      color: _result!.success ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _result!.success ? Icons.check_circle : Icons.error,
                  color: _result!.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _result!.success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResultCard(
                    'Total Tests',
                    _result!.totalTests.toString(),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildResultCard(
                    'Passed',
                    _result!.passedTests.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildResultCard(
                    'Failed',
                    _result!.failedTests.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._result!.results.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(
                    entry.value ? Icons.check : Icons.close,
                    color: entry.value ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.key)),
                  if (!entry.value && _result!.errors.containsKey(entry.key))
                    Tooltip(
                      message: _result!.errors[entry.key]!,
                      child: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            )),
            if (_result!.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Error Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._result!.errors.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _result = null;
      _currentTest = 'Initializing...';
    });
    
    try {
      final result = await _testSuite.runAllTests();
      
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = TestResult(
          success: false,
          totalTests: 0,
          passedTests: 0,
          failedTests: 1,
          results: {},
          errors: {'Test Suite': e.toString()},
        );
      });
    } finally {
      setState(() {
        _isRunning = false;
        _currentTest = '';
      });
    }
  }
}
