import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/services/connectivity/connectivity_service.dart';
import 'package:flutter_invoice_app/services/sync/sync_service.dart';

class OfflineStatusWidget extends StatelessWidget {
  final VoidCallback? onSyncPressed;
  
  const OfflineStatusWidget({
    Key? key,
    this.onSyncPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    final syncService = SyncService();
    
    return StreamBuilder<bool>(
      stream: connectivityService.connectionStatus,
      builder: (context, connectionSnapshot) {
        final isConnected = connectionSnapshot.data ?? false;
        
        return StreamBuilder<int>(
          stream: syncService.pendingChangesCount,
          builder: (context, pendingSnapshot) {
            final pendingChanges = pendingSnapshot.data ?? 0;
            
            return StreamBuilder<bool>(
              stream: syncService.isSyncing,
              builder: (context, syncingSnapshot) {
                final isSyncing = syncingSnapshot.data ?? false;
                
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isConnected ? Colors.green.shade200 : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: isConnected ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pendingChanges > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$pendingChanges pending',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (isConnected && pendingChanges > 0) ...[
                        const SizedBox(width: 8),
                        isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.sync),
                                tooltip: 'Sync now',
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: Colors.blue,
                                onPressed: onSyncPressed ?? syncService.forceSyncNow,
                              ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
