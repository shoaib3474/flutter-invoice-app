import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_invoice_app/database/database_helper.dart';
import 'package:flutter_invoice_app/models/sync/sync_operation.dart';
import 'package:flutter_invoice_app/models/sync/sync_queue_item.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';
import 'package:flutter_invoice_app/services/connectivity/connectivity_service.dart';
import 'package:flutter_invoice_app/services/notification/local_notification_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:workmanager/workmanager.dart';

// Define callback for background sync
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncData':
        // Initialize services
        final dbHelper = DatabaseHelper();
        
        // Get pending sync items
        final pendingItems = await dbHelper.getPendingSyncItems();
        
        if (pendingItems.isNotEmpty) {
          // Process sync items
          for (var item in pendingItems) {
            try {
              // Implement sync logic here
              // This is a simplified example
              await Future.delayed(Duration(seconds: 1));
              
              // Update sync status
              await dbHelper.updateSyncQueueItemStatus(item['id'], 'completed');
            } catch (e) {
              // Update attempts count
              int attempts = item['attempts'] + 1;
              await dbHelper.updateSyncQueueItemStatus(
                item['id'],
                attempts > 3 ? 'failed' : 'pending',
                attempts: attempts,
              );
            }
          }
        }
        break;
    }
    
    return true;
  });
}

class SyncService {
  // Singleton instance
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  
  // Dependencies
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocalNotificationService _notificationService = LocalNotificationService();
  
  // Lock for synchronization
  final Lock _syncLock = Lock();
  
  // Stream controllers
  final BehaviorSubject<bool> _syncingController = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<int> _pendingChangesController = BehaviorSubject<int>.seeded(0);
  
  // Streams
  Stream<bool> get isSyncing => _syncingController.stream;
  Stream<int> get pendingChangesCount => _pendingChangesController.stream;
  
  // Current values
  bool get isSyncingNow => _syncingController.value;
  int get pendingChanges => _pendingChangesController.value;
  
  // Subscription to connectivity changes
  StreamSubscription<bool>? _connectivitySubscription;
  
  // Timer for periodic sync
  Timer? _syncTimer;
  
  // Last sync time
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  SyncService._internal();
  
  // Initialize the service
  Future<void> initialize() async {
    // Initialize Workmanager for background sync
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    // Schedule periodic background sync
    await Workmanager().registerPeriodicTask(
      'syncData',
      'syncData',
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
    
    // Load last sync time
    String? lastSyncTimeStr = await _dbHelper.getSetting('last_sync_time');
    if (lastSyncTimeStr != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastSyncTimeStr));
    }
    
    // Subscribe to connectivity changes
    _connectivitySubscription = _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected) {
        // Trigger sync when connection is restored
        syncData();
      }
    });
    
    // Start periodic sync timer
    _startSyncTimer();
    
    // Update pending changes count
    _updatePendingChangesCount();
  }
  
  // Start periodic sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      if (_connectivityService.isConnected) {
        syncData();
      }
    });
  }
  
  // Update pending changes count
  Future<void> _updatePendingChangesCount() async {
    final pendingItems = await _dbHelper.getPendingSyncItems();
    _pendingChangesController.add(pendingItems.length);
  }
  
  // Add entity to sync queue
  Future<void> addToSyncQueue(
    String entityType,
    String entityId,
    SyncOperation operation,
    Map<String, dynamic>? data,
  ) async {
    await _dbHelper.addToSyncQueue(
      entityType,
      entityId,
      operation.toString(),
      data,
    );
    
    // Update pending changes count
    _updatePendingChangesCount();
    
    // Trigger sync if connected
    if (_connectivityService.isConnected) {
      syncData();
    }
  }
  
  // Sync data with server
  Future<bool> syncData() async {
    // Use lock to prevent multiple syncs at the same time
    return await _syncLock.synchronized(() async {
      if (isSyncingNow) {
        return false;
      }
      
      // Check connectivity
      if (!await _connectivityService.checkConnectivity()) {
        return false;
      }
      
      try {
        // Set syncing state
        _syncingController.add(true);
        
        // Get pending sync items
        final pendingItems = await _dbHelper.getPendingSyncItems();
        
        if (pendingItems.isEmpty) {
          // No items to sync
          _syncingController.add(false);
          return true;
        }
        
        // Process sync items
        for (var item in pendingItems) {
          try {
            final syncItem = SyncQueueItem.fromMap(item);
            
            // Process based on entity type and operation
            bool success = await _processSyncItem(syncItem);
            
            if (success) {
              // Update sync status
              await _dbHelper.updateSyncQueueItemStatus(syncItem.id, 'completed');
            } else {
              // Update attempts count
              int attempts = syncItem.attempts + 1;
              await _dbHelper.updateSyncQueueItemStatus(
                syncItem.id,
                attempts > 3 ? 'failed' : 'pending',
                attempts: attempts,
              );
            }
          } catch (e) {
            // Handle error for individual item
            print('Error syncing item ${item['id']}: $e');
            
            // Update attempts count
            int attempts = item['attempts'] + 1;
            await _dbHelper.updateSyncQueueItemStatus(
              item['id'],
              attempts > 3 ? 'failed' : 'pending',
              attempts: attempts,
            );
          }
        }
        
        // Update last sync time
        _lastSyncTime = DateTime.now();
        await _dbHelper.saveSetting(
          'last_sync_time',
          _lastSyncTime!.millisecondsSinceEpoch.toString(),
        );
        
        // Show notification
        _notificationService.showNotification(
          'Sync Completed',
          'Your data has been synchronized with the server.',
        );
        
        return true;
      } catch (e) {
        print('Error during sync: $e');
        return false;
      } finally {
        // Reset syncing state
        _syncingController.add(false);
        
        // Update pending changes count
        _updatePendingChangesCount();
      }
    });
  }
  
  // Process a sync item
  Future<bool> _processSyncItem(SyncQueueItem item) async {
    // This is where you would implement the actual sync logic
    // For each entity type and operation
    
    // For demonstration purposes, we'll just simulate a successful sync
    await Future.delayed(Duration(milliseconds: 500));
    
    // In a real implementation, you would:
    // 1. Send the data to the server
    // 2. Handle the response
    // 3. Update the local database
    // 4. Handle conflicts
    
    return true;
  }
  
  // Force sync now
  Future<bool> forceSyncNow() async {
    return await syncData();
  }

  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    // Mock implementation
    return [];
  }

  Future<List<SyncQueueItem>> getCompletedSyncItems() async {
    // Mock implementation
    return [];
  }

  Future<List<SyncQueueItem>> getFailedSyncItems() async {
    // Mock implementation
    return [];
  }

  Future<SyncStatus> getSyncStatus() async {
    // Mock implementation
    return SyncStatus.idle;
  }

  @override
  Future<void> forceSyncNow() async {
    await syncData();
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> retryFailedItems() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }
  
  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _syncingController.close();
    _pendingChangesController.close();
  }
}
