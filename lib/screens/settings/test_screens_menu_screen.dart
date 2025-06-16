// import 'package:flutter/material.dart';
// import '../test/firebase_setup_test_screen.dart';

// import '../setup/firebase_setup_checklist_screen.dart';

// class TestScreensMenuScreen extends StatelessWidget {
//   const TestScreensMenuScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Screens'),
//         backgroundColor: Colors.purple,
//         foregroundColor: Colors.white,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Header
//           Card(
//             color: Colors.purple.shade50,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.science, color: Colors.purple.shade700),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Testing & Validation',
//                         style:
//                             Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                   color: Colors.purple.shade700,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Test and validate your app configuration, Firebase setup, and integrations.',
//                     style: TextStyle(color: Colors.purple.shade600),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Firebase Tests
//           _buildTestCategory(
//             context,
//             'Firebase Configuration',
//             Icons.home,
//             Colors.orange,
//             [
//               TestScreenItem(
//                 title: 'Firebase Setup Test',
//                 subtitle: 'Test Firebase services and connectivity',
//                 icon: Icons.cloud_done,
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FirebaseSetupTestScreen(),
//                   ),
//                 ),
//                 status: TestStatus.ready,
//               ),
//               TestScreenItem(
//                 title: 'Setup Checklist',
//                 subtitle: 'Step-by-step Firebase configuration guide',
//                 icon: Icons.checklist,
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FirebaseSetupChecklistScreen(),
//                   ),
//                 ),
//                 status: TestStatus.ready,
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // OCR Tests
//           _buildTestCategory(
//             context,
//             'Document Processing',
//             Icons.document_scanner,
//             Colors.blue,
//             [
//               TestScreenItem(
//                 title: 'Document Scanner Test',
//                 subtitle: 'Test OCR and invoice data extraction',
//                 icon: Icons.camera_alt,
//                 onTap: () {},
//                 status: TestStatus.ready,
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Payment Tests
//           _buildTestCategory(
//             context,
//             'Payment Integration',
//             Icons.payment,
//             Colors.green,
//             [
//               TestScreenItem(
//                 title: 'Stripe Config Test',
//                 subtitle: 'Test Stripe configuration and payments',
//                 icon: Icons.credit_card,
//                 onTap: () {},
//                 status: TestStatus.ready,
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // Quick Actions
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Quick Actions',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => _runAllTests(context),
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Run All Tests'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.purple,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => _showTestInfo(context),
//                           icon: const Icon(Icons.info_outline),
//                           label: const Text('Test Info'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestCategory(
//     BuildContext context,
//     String title,
//     IconData categoryIcon,
//     Color color,
//     List<TestScreenItem> items,
//   ) {
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Category Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(categoryIcon, color: color),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: color,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//               ],
//             ),
//           ),

//           // Test Items
//           ...items.map((item) => _buildTestItem(context, item, color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestItem(
//       BuildContext context, TestScreenItem item, Color color) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: color.withOpacity(0.1),
//         child: Icon(item.icon, color: color, size: 20),
//       ),
//       title: Text(item.title),
//       subtitle: Text(item.subtitle),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildStatusIndicator(item.status),
//           const SizedBox(width: 8),
//           const Icon(Icons.arrow_forward_ios, size: 16),
//         ],
//       ),
//       onTap: item.onTap,
//     );
//   }

//   Widget _buildStatusIndicator(TestStatus status) {
//     switch (status) {
//       case TestStatus.ready:
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.green.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Text(
//             'Ready',
//             style: TextStyle(
//               color: Colors.green,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       case TestStatus.warning:
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.orange.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Text(
//             'Warning',
//             style: TextStyle(
//               color: Colors.orange,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       case TestStatus.error:
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.red.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Text(
//             'Error',
//             style: TextStyle(
//               color: Colors.red,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//     }
//   }

//   void _runAllTests(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Run All Tests'),
//         content: const Text(
//           'This will run all available tests sequentially. This may take a few minutes.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _executeAllTests(context);
//             },
//             child: const Text('Run Tests'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _executeAllTests(BuildContext context) {
//     // Navigate to Firebase test first
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const FirebaseSetupTestScreen(),
//       ),
//     );
//   }

//   void _showTestInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Test Information'),
//         content: const SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Test Categories:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text('🔥 Firebase Configuration'),
//               Text('• Tests Firebase services connectivity'),
//               Text('• Validates authentication setup'),
//               Text('• Checks Firestore and Storage access'),
//               SizedBox(height: 12),
//               Text('📱 Document Processing'),
//               Text('• Tests OCR functionality'),
//               Text('• Validates invoice data extraction'),
//               Text('• Checks ML Kit integration'),
//               SizedBox(height: 12),
//               Text('💳 Payment Integration'),
//               Text('• Tests Stripe configuration'),
//               Text('• Validates payment processing'),
//               Text('• Checks webhook functionality'),
//               SizedBox(height: 12),
//               Text(
//                 'Tips:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Run tests after configuration changes'),
//               Text('• Check test results for troubleshooting'),
//               Text('• Use test data during development'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DocumentScannerTestScreen {
//   const DocumentScannerTestScreen();
// }

// class TestScreenItem {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;
//   final TestStatus status;

//   TestScreenItem({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//     required this.status,
//   });
// }

// enum TestStatus {
//   ready,
//   warning,
//   error,
// }
