import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseQuickFixScreen extends StatefulWidget {
  const FirebaseQuickFixScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseQuickFixScreen> createState() => _FirebaseQuickFixScreenState();
}

class _FirebaseQuickFixScreenState extends State<FirebaseQuickFixScreen> {
  final List<FixCommand> _fixCommands = [
    FixCommand(
      title: '1. Configure FlutterFire',
      description: 'Set up Firebase configuration for your Flutter app',
      command: 'flutterfire configure',
      category: 'Setup',
      estimatedTime: '2-3 minutes',
      prerequisites: ['Firebase CLI installed', 'Logged into Firebase'],
    ),
    FixCommand(
      title: '2. Clean Flutter Project',
      description: 'Clean build cache and dependencies',
      command: 'flutter clean',
      category: 'Cleanup',
      estimatedTime: '30 seconds',
      prerequisites: ['Flutter SDK installed'],
    ),
    FixCommand(
      title: '3. Get Dependencies',
      description: 'Install/update Flutter dependencies',
      command: 'flutter pub get',
      category: 'Dependencies',
      estimatedTime: '1-2 minutes',
      prerequisites: ['Internet connection'],
    ),
    FixCommand(
      title: '4. Deploy Security Rules',
      description: 'Deploy Firestore and Storage security rules',
      command: 'firebase deploy --only firestore:rules,storage',
      category: 'Security',
      estimatedTime: '1-2 minutes',
      prerequisites: ['Firebase project initialized', 'Rules files exist'],
    ),
    FixCommand(
      title: '5. Initialize Firebase Services',
      description: 'Initialize Firebase project with required services',
      command: 'firebase init firestore functions hosting',
      category: 'Initialization',
      estimatedTime: '3-5 minutes',
      prerequisites: ['Firebase CLI logged in', 'Project selected'],
    ),
    FixCommand(
      title: '6. Deploy Cloud Functions',
      description: 'Deploy payment and business logic functions',
      command: 'firebase deploy --only functions',
      category: 'Functions',
      estimatedTime: '2-4 minutes',
      prerequisites: ['Functions directory exists', 'Node.js installed'],
    ),
  ];

  final Map<String, bool> _completedCommands = {};
  bool _isRunningAll = false;

  @override
  void initState() {
    super.initState();
    for (final command in _fixCommands) {
      _completedCommands[command.command] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedCommands.values.where((v) => v).length;
    final totalCount = _fixCommands.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Quick Fix'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.build, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Firebase Configuration Fix',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow these commands in order to fix common Firebase issues',
                  style: TextStyle(color: Colors.orange.shade600),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completedCount / totalCount,
                  backgroundColor: Colors.orange.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount of $totalCount commands completed',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
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
                    onPressed: _isRunningAll ? null : _copyAllCommands,
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copy All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunningAll ? null : _markAllCompleted,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark All Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Commands List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _fixCommands.length,
              itemBuilder: (context, index) {
                final command = _fixCommands[index];
                final isCompleted = _completedCommands[command.command] ?? false;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _completedCommands[command.command] = value ?? false;
                        });
                      },
                    ),
                    title: Text(
                      command.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(command.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(command.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                command.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              command.estimatedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prerequisites
                            if (command.prerequisites.isNotEmpty) ...[
                              const Text(
                                'Prerequisites:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...command.prerequisites.map((prereq) => Padding(
                                padding: const EdgeInsets.only(left: 16, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, 
                                         size: 16, color: Colors.green.shade600),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(prereq)),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 16),
                            ],
                            
                            // Command
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Command:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _copyCommand(command.command),
                                      icon: const Icon(Icons.copy, size: 16),
                                      label: const Text('Copy'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _runCommand(command),
                                      icon: const Icon(Icons.play_arrow, size: 16),
                                      label: const Text('Run'),
                                    ),
                                  ],
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
                              child: Row(
                                children: [
                                  const Text(
                                    '\$ ',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      command.command,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Status
                            Row(
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isCompleted ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCompleted ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    color: isCompleted ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.bold,
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
              },
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (completedCount == totalCount) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All commands completed!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                'Your Firebase configuration should now be working.',
                                style: TextStyle(color: Colors.green.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Setup': return Colors.blue;
      case 'Cleanup': return Colors.orange;
      case 'Dependencies': return Colors.purple;
      case 'Security': return Colors.red;
      case 'Initialization': return Colors.green;
      case 'Functions': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  void _copyCommand(String command) {
    Clipboard.setData(ClipboardData(text: command));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Command copied: $command')),
    );
  }

  void _copyAllCommands() {
    final allCommands = _fixCommands.map((cmd) => cmd.command).join('\n');
    Clipboard.setData(ClipboardData(text: allCommands));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All commands copied to clipboard')),
    );
  }

  void _runCommand(FixCommand command) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Run ${command.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Command: ${command.command}'),
            const SizedBox(height: 8),
            Text('Estimated time: ${command.estimatedTime}'),
            const SizedBox(height: 12),
            const Text('Make sure to run this command in your project root directory.'),
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
              _copyCommand(command.command);
              setState(() {
                _completedCommands[command.command] = true;
              });
            },
            child: const Text('Copy & Mark Done'),
          ),
        ],
      ),
    );
  }

  void _markAllCompleted() {
    setState(() {
      for (final command in _fixCommands) {
        _completedCommands[command.command] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All commands marked as completed')),
    );
  }

  void _retestConfiguration() {
    Navigator.pop(context); // Go back to test screen
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Fix Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use Quick Fix:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Run commands in the order shown'),
              Text('2. Copy each command and run it in your terminal'),
              Text('3. Check off completed commands'),
              Text('4. Retest your configuration when done'),
              SizedBox(height: 12),
              Text(
                'Important Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Run commands in your project root directory'),
              Text('• Make sure you have internet connection'),
              Text('• Some commands may take several minutes'),
              Text('• Check prerequisites before running'),
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

class FixCommand {
  final String title;
  final String description;
  final String command;
  final String category;
  final String estimatedTime;
  final List<String> prerequisites;

  FixCommand({
    required this.title,
    required this.description,
    required this.command,
    required this.category,
    required this.estimatedTime,
    required this.prerequisites,
  });
}
