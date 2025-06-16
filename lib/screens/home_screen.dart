import 'package:flutter/material.dart';

import '../widgets/home/gst_return_card_widget.dart';
import '../widgets/home/quick_actions_widget.dart';
import '../widgets/home/quick_build_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Invoice App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () => Navigator.pushNamed(context, '/build-apk'),
            tooltip: 'Build APK',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome to GST Invoice App',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your GST returns, invoices, and compliance',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Quick Build Widget
              const QuickBuildWidget(),
              const SizedBox(height: 16),

              // Quick Actions
              const QuickActionsWidget(),
              const SizedBox(height: 16),

              // GST Returns Section
              Text(
                'GST Returns',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // GST Return Cards
              const GstReturnCardWidget(
                title: 'GSTR-1',
                subtitle: 'Outward supplies',
                icon: Icons.upload,
                color: Color.fromARGB(255, 234, 245, 234),
              ),
              const SizedBox(height: 8),
              const GstReturnCardWidget(
                title: 'GSTR-3B',
                subtitle: 'Monthly summary',
                icon: Icons.summarize,
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              const GstReturnCardWidget(
                title: 'GSTR-9',
                subtitle: 'Annual return',
                icon: Icons.calendar_today,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/build-apk'),
        icon: const Icon(Icons.build),
        label: const Text('Build APK'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
