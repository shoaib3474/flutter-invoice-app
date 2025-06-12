import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/sync/sync_queue_item.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';
import 'package:flutter_invoice_app/services/sync/sync_service.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({Key? key}) : super(key: key);

  @override
  _SyncStatusScreenState createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final SyncService _syncService = SyncService();
  List<SyncQueueItem> _pendingItems = [];
  List<SyncQueueItem> _completedItems = [];
  List<SyncQueueItem> _failedItems = [];
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncData();
  }

  Future<void> _loadSyncData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pendingItems = await _syncService.getPendingSyncItems();
      final completedItems = await _syncService.getCompletedSyncItems();
      final failedItems = await _syncService.getFailedSyncItems();
      final syncStatus = await _syncService.getSyncStatus();

      setState(() {
        _pendingItems = pendingItems;
        _completedItems = completedItems;
        _failedItems = failedItems;
        _syncStatus = syncStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading sync data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceSyncNow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _syncService.forceSyncNow();
      await _loadSyncData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during sync: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _retryFailedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _syncService.retryFailedItems();
      await _loadSyncData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retry completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrying failed items: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Sync Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadSyncData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSyncStatusCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildSyncItemsSection('Pending Items', _pendingItems, Colors.orange),
                  const SizedBox(height: 16),
                  _buildSyncItemsSection('Failed Items', _failedItems, Colors.red),
                  const SizedBox(height: 16),
                  _buildSyncItemsSection('Completed Items', _completedItems, Colors.green),
                ],
              ),
            ),
    );
  }

  Widget _buildSyncStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_syncStatus) {
      case SyncStatus.syncing:
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'Syncing';
        break;
      case SyncStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Error';
        break;
      case SyncStatus.offline:
        statusColor = Colors.orange;
        statusIcon = Icons.cloud_off;
        statusText = 'Offline';
        break;
      case SyncStatus.idle:
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Idle';
        break;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Last sync: ${DateTime.now().toString().substring(0, 19)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem('Pending', _pendingItems.length.toString(), Colors.orange),
                _buildStatusItem('Failed', _failedItems.length.toString(), Colors.red),
                _buildStatusItem('Completed', _completedItems.length.toString(), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _forceSyncNow,
          icon: const Icon(Icons.sync),
          label: const Text('Sync Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _failedItems.isEmpty ? null : _retryFailedItems,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry Failed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncItemsSection(String title, List<SyncQueueItem> items, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No items',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.entityType),
                    subtitle: Text(
                      'Operation: ${item.operation}, ID: ${item.entityId}',
                    ),
                    trailing: Text(
                      item.timestamp.toString().substring(0, 19),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
