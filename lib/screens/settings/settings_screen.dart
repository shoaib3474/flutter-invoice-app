import 'package:flutter/material.dart';
// Add Firebase setup option to the settings screen

// Import the Firebase setup screen
import '../firebase/firebase_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSettingsOptions(context),
        ],
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle, color: Colors.blue),
          title: const Text('Account'),
          subtitle: const Text('Manage your account details'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to account settings screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.green),
          title: const Text('Notifications'),
          subtitle: const Text('Configure notification preferences'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to notification settings screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.security, color: Colors.red),
          title: const Text('Privacy'),
          subtitle: const Text('Manage privacy settings'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to privacy settings screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.cloud, color: Colors.orange),
          title: const Text('Firebase Setup'),
          subtitle: const Text('Configure Firebase services'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FirebaseSetupScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report, color: Colors.purple),
          title: const Text('Test Screens'),
          subtitle: const Text('Firebase, OCR, and Stripe testing'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestScreensMenuScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
