import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_invoice_app/widgets/common/copy_command_widget.dart';

class CopyCommandsGuideScreen extends StatefulWidget {
  const CopyCommandsGuideScreen({Key? key}) : super(key: key);

  @override
  State<CopyCommandsGuideScreen> createState() => _CopyCommandsGuideScreenState();
}

class _CopyCommandsGuideScreenState extends State<CopyCommandsGuideScreen> {
  final Map<String, List<CommandStep>> _commandCategories = {
    'Essential Setup': [
      CommandStep(
        title: 'Install Firebase CLI',
        command: 'npm install -g firebase-tools',
        description: 'Install Firebase command line tools globally',
        platform: 'All',
        estimatedTime: '2-3 minutes',
        prerequisites: ['Node.js installed'],
      ),
      CommandStep(
        title: 'Login to Firebase',
        command: 'firebase login',
        description: 'Authenticate with your Google account',
        platform: 'All',
        estimatedTime: '1 minute',
        prerequisites: ['Firebase CLI installed'],
      ),
      CommandStep(
        title: 'Install FlutterFire CLI',
        command: 'dart pub global activate flutterfire_cli',
        description: 'Install FlutterFire configuration tool',
        platform: 'All',
        estimatedTime: '1-2 minutes',
        prerequisites: ['Flutter SDK installed'],
      ),
    ],
    
    'Project Configuration': [
      CommandStep(
        title: 'Configure FlutterFire',
        command: 'flutterfire configure',
        description: 'Set up Firebase configuration for your Flutter app',
        platform: 'All',
        estimatedTime: '2-3 minutes',
        prerequisites: ['Firebase project created', 'Logged into Firebase'],
      ),
      CommandStep(
        title: 'Select Firebase Project',
        command: 'firebase use YOUR_PROJECT_ID',
        description: 'Select your Firebase project for CLI commands',
        platform: 'All',
        estimatedTime: '10 seconds',
        prerequisites: ['Firebase project exists'],
      ),
      CommandStep(
        title: 'Initialize Firebase Services',
        command: 'firebase init firestore functions hosting',
        description: 'Initialize required Firebase services',
        platform: 'All',
        estimatedTime: '3-5 minutes',
        prerequisites: ['Firebase project selected'],
      ),
    ],
    
    'Flutter Project Cleanup': [
      CommandStep(
        title: 'Clean Flutter Build',
        command: 'flutter clean',
        description: 'Clean build cache and generated files',
        platform: 'All',
        estimatedTime: '30 seconds',
        prerequisites: ['Flutter project'],
      ),
      CommandStep(
        title: 'Get Dependencies',
        command: 'flutter pub get',
        description: 'Download and install Flutter dependencies',
        platform: 'All',
        estimatedTime: '1-2 minutes',
        prerequisites: ['pubspec.yaml exists'],
      ),
      CommandStep(
        title: 'Upgrade Dependencies',
        command: 'flutter pub upgrade',
        description: 'Update dependencies to latest versions',
        platform: 'All',
        estimatedTime: '2-3 minutes',
        prerequisites: ['Internet connection'],
      ),
    ],
    
    'Security Rules Deployment': [
      CommandStep(
        title: 'Deploy Firestore Rules',
        command: 'firebase deploy --only firestore:rules',
        description: 'Deploy database security rules',
        platform: 'All',
        estimatedTime: '1 minute',
        prerequisites: ['firestore.rules file exists'],
      ),
      CommandStep(
        title: 'Deploy Storage Rules',
        command: 'firebase deploy --only storage',
        description: 'Deploy file storage security rules',
        platform: 'All',
        estimatedTime: '1 minute',
        prerequisites: ['storage.rules file exists'],
      ),
      CommandStep(
        title: 'Deploy All Rules',
        command: 'firebase deploy --only firestore:rules,storage',
        description: 'Deploy both Firestore and Storage rules',
        platform: 'All',
        estimatedTime: '1-2 minutes',
        prerequisites: ['Rules files exist'],
      ),
    ],
    
    'Cloud Functions': [
      CommandStep(
        title: 'Install Function Dependencies',
        command: 'cd functions && npm install',
        description: 'Install Node.js dependencies for Cloud Functions',
        platform: 'All',
        estimatedTime: '2-3 minutes',
        prerequisites: ['functions directory exists'],
      ),
      CommandStep(
        title: 'Deploy Functions',
        command: 'firebase deploy --only functions',
        description: 'Deploy Cloud Functions to Firebase',
        platform: 'All',
        estimatedTime: '3-5 minutes',
        prerequisites: ['Functions code ready'],
      ),
      CommandStep(
        title: 'Set Function Config',
        command: 'firebase functions:config:set stripe.secret_key="sk_test_your_key"',
        description: 'Configure environment variables for functions',
        platform: 'All',
        estimatedTime: '10 seconds',
        prerequisites: ['Stripe account'],
      ),
    ],
    
    'Build & Test': [
      CommandStep(
        title: 'Build Android APK',
        command: 'flutter build apk --release',
        description: 'Build release APK for Android',
        platform: 'Android',
        estimatedTime: '5-10 minutes',
        prerequisites: ['Android SDK configured'],
      ),
      CommandStep(
        title: 'Build iOS App',
        command: 'flutter build ios --release',
        description: 'Build release app for iOS',
        platform: 'iOS',
        estimatedTime: '10-15 minutes',
        prerequisites: ['Xcode installed', 'iOS certificates'],
      ),
      CommandStep(
        title: 'Run Tests',
        command: 'flutter test',
        description: 'Run unit and widget tests',
        platform: 'All',
        estimatedTime: '1-2 minutes',
        prerequisites: ['Test files exist'],
      ),
    ],
    
    'Troubleshooting': [
      CommandStep(
        title: 'Check Firebase Status',
        command: 'firebase projects:list',
        description: 'List all accessible Firebase projects',
        platform: 'All',
        estimatedTime: '5 seconds',
        prerequisites: ['Firebase CLI logged in'],
      ),
      CommandStep(
        title: 'Check Function Logs',
        command: 'firebase functions:log',
        description: 'View Cloud Functions execution logs',
        platform: 'All',
        estimatedTime: '10 seconds',
        prerequisites: ['Functions deployed'],
      ),
      CommandStep(
        title: 'Doctor Check',
        command: 'flutter doctor -v',
        description: 'Check Flutter installation and dependencies',
        platform: 'All',
        estimatedTime: '30 seconds',
        prerequisites: ['Flutter SDK installed'],
      ),
    ],
  };

  final Set<String> _copiedCommands = {};
  String _selectedCategory = 'Essential Setup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy Fix Commands'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _copyAllCommands,
            tooltip: 'Copy All Commands',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Row(
        children: [
          // Category Sidebar
          Container(
            width: 200,
            color: Colors.grey.shade100,
            child: ListView(
              children: _commandCategories.keys.map((category) {
                final isSelected = category == _selectedCategory;
                final commandCount = _commandCategories[category]!.length;
                final copiedCount = _commandCategories[category]!
                    .where((cmd) => _copiedCommands.contains(cmd.command))
                    .length;
                
                return ListTile(
                  title: Text(
                    category,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  subtitle: Text('$copiedCount/$commandCount copied'),
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  trailing: copiedCount == commandCount
                    ? Icon(Icons.check_circle, color: Colors.green.shade600)
                    : null,
                );
              }).toList(),
            ),
          ),
          
          // Commands Content
          Expanded(
            child: Column(
              children: [
                // Category Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terminal, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCategory,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Copy and run these commands in your terminal',
                        style: TextStyle(color: Colors.blue.shade600),
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
                          onPressed: () => _copyCategoryCommands(_selectedCategory),
                          icon: const Icon(Icons.copy_all),
                          label: Text('Copy All ${_selectedCategory}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearCopiedStatus,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Commands List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _commandCategories[_selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      final command = _commandCategories[_selectedCategory]![index];
                      final isCopied = _copiedCommands.contains(command.command);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: isCopied 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                            child: Icon(
                              isCopied ? Icons.check : Icons.terminal,
                              color: isCopied ? Colors.green : Colors.blue,
                            ),
                          ),
                          title: Text(
                            command.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(command.description),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, 
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPlatformColor(command.platform),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      command.platform,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.access_time, 
                                       size: 12, 
                                       color: Colors.grey.shade600),
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
                                               size: 16, 
                                               color: Colors.green.shade600),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(prereq)),
                                        ],
                                      ),
                                    )),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Command
                                  const Text(
                                    'Command:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  CopyCommandWidget(
                                    command: command.command,
                                    onCopied: () {
                                      setState(() {
                                        _copiedCommands.add(command.command);
                                      });
                                    },
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Status
                                  Row(
                                    children: [
                                      Icon(
                                        isCopied ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: isCopied ? Colors.green : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isCopied ? 'Copied to clipboard' : 'Ready to copy',
                                        style: TextStyle(
                                          color: isCopied ? Colors.green : Colors.grey,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'All': return Colors.blue;
      case 'Android': return Colors.green;
      case 'iOS': return Colors.grey;
      default: return Colors.purple;
    }
  }

  void _copyCategoryCommands(String category) {
    final commands = _commandCategories[category]!
        .map((cmd) => cmd.command)
        .join('\n');
    
    Clipboard.setData(ClipboardData(text: commands));
    
    setState(() {
      for (final command in _commandCategories[category]!) {
        _copiedCommands.add(command.command);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All $category commands copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copyAllCommands() {
    final allCommands = _commandCategories.values
        .expand((commands) => commands)
        .map((cmd) => '# ${cmd.title}\n${cmd.command}')
        .join('\n\n');
    
    Clipboard.setData(ClipboardData(text: allCommands));
    
    setState(() {
      for (final commands in _commandCategories.values) {
        for (final command in commands) {
          _copiedCommands.add(command.command);
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All commands copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCopiedStatus() {
    setState(() {
      _copiedCommands.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied status cleared')),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use Copy Commands'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Using the Copy Buttons:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Select a category from the left sidebar'),
              Text('2. Expand command cards to see details'),
              Text('3. Click the copy button next to each command'),
              Text('4. Paste and run in your terminal'),
              Text('5. Commands turn green when copied'),
              SizedBox(height: 12),
              Text(
                'Quick Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• "Copy All [Category]" - Copy all commands in category'),
              Text('• "Copy All Commands" - Copy everything at once'),
              Text('• "Clear Status" - Reset copied indicators'),
              SizedBox(height: 12),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Run commands in your project root directory'),
              Text('• Check prerequisites before running'),
              Text('• Commands are organized by setup phase'),
              Text('• Green checkmarks show completed categories'),
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

class CommandStep {
  final String title;
  final String command;
  final String description;
  final String platform;
  final String estimatedTime;
  final List<String> prerequisites;

  CommandStep({
    required this.title,
    required this.command,
    required this.description,
    required this.platform,
    required this.estimatedTime,
    required this.prerequisites,
  });
}
