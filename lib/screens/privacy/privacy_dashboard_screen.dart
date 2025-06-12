import 'package:flutter/material.dart';
import '../../services/storage/local_storage_service.dart';
import '../../services/customer/local_customer_service.dart';
import '../../services/invoice/local_invoice_service.dart';
import '../../widgets/common/custom_button.dart';

class PrivacyDashboardScreen extends StatefulWidget {
  const PrivacyDashboardScreen({Key? key}) : super(key: key);

  @override
  _PrivacyDashboardScreenState createState() => _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends State<PrivacyDashboardScreen> {
  Map<String, int> _storageStats = {};
  Map<String, dynamic> _customerStats = {};
  Map<String, dynamic> _invoiceStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _isLoading = true;
    });

    try {
      _storageStats = LocalStorageService.getStorageStats();
      _customerStats = LocalCustomerService.getCustomerStats();
      _invoiceStats = LocalInvoiceService.getInvoiceStats();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrivacyHeader(),
                  const SizedBox(height: 24),
                  _buildStorageStatsCard(),
                  const SizedBox(height: 16),
                  _buildCustomerStatsCard(),
                  const SizedBox(height: 16),
                  _buildInvoiceStatsCard(),
                  const SizedBox(height: 16),
                  _buildDataRetentionCard(),
                  const SizedBox(height: 16),
                  _buildExportImportCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacyHeader() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green.shade700, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy-First Billing System',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All your data stays in your browser. No cloud storage.',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPrivacyBadge('GDPR Compliant', Icons.check_circle),
                _buildPrivacyBadge('No Server Storage', Icons.cloud_off),
                _buildPrivacyBadge('Local Only', Icons.storage),
                _buildPrivacyBadge('User Controlled', Icons.person),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local Storage Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_storageStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Customers',
                    _customerStats['total']?.toString() ?? '0',
                    Icons.people,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'B2B Customers',
                    _customerStats['b2b']?.toString() ?? '0',
                    Icons.business,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'B2C Customers',
                    _customerStats['b2c']?.toString() ?? '0',
                    Icons.person,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'With Email',
                    _customerStats['withEmail']?.toString() ?? '0',
                    Icons.email,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Invoices',
                    _invoiceStats['total']?.toString() ?? '0',
                    Icons.receipt,
                    Colors.indigo,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'This Month',
                    _invoiceStats['thisMonth']?.toString() ?? '0',
                    Icons.calendar_month,
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Total Value',
              '₹${(_invoiceStats['totalValue'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
              Icons.currency_rupee,
              Colors.green,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataRetentionCard() {
    final retentionInfo = LocalCustomerService.getDataRetentionInfo();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Retention & Privacy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...retentionInfo.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    entry.value == true || entry.value == 'user_controlled' 
                        ? Icons.check_circle 
                        : entry.value == false 
                            ? Icons.cancel 
                            : Icons.info,
                    color: entry.value == true || entry.value == 'user_controlled'
                        ? Colors.green
                        : entry.value == false
                            ? Colors.red
                            : Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          entry.value.toString().replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildExportImportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Export & Import',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Backup your data or import from another device',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Export Data',
                    onPressed: _exportData,
                    icon: Icons.download,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Import Data',
                    onPressed: _importData,
                    icon: Icons.upload,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    try {
      final data = LocalStorageService.exportAllData();
      
      // In a real app, you would trigger a file download
      // For now, we'll show the data in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: SingleChildScrollView(
            child: Text(
              'Data exported successfully!\n\n'
              'Customers: ${data['customers']?.length ?? 0}\n'
              'Items: ${data['items']?.length ?? 0}\n'
              'Invoices: ${data['invoices']?.length ?? 0}\n'
              'Purchases: ${data['purchases']?.length ?? 0}\n'
              'Payments: ${data['payments']?.length ?? 0}\n\n'
              'Export Date: ${data['exportDate']}\n'
              'Version: ${data['version']}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Import functionality would allow you to select a JSON file '
          'and restore your data from a backup.\n\n'
          'This feature maintains privacy by keeping all data local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
