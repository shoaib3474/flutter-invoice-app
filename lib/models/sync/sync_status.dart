// ignore_for_file: always_declare_return_types

import 'package:flutter/material.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  offline,
  pending, // <-- You added this
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.pending:
        return 'Pending'; // <-- FIXED
    }
  }

  Color get color {
    switch (this) {
      case SyncStatus.idle:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.pending:
        return Colors.grey; // <-- FIXED
    }
  }

  static SyncStatus fromString(String json) {
    switch (json.toLowerCase()) {
      case 'idle':
        return SyncStatus.idle;
      case 'syncing':
        return SyncStatus.syncing;
      case 'error':
        return SyncStatus.error;
      case 'offline':
        return SyncStatus.offline;
      case 'pending':
        return SyncStatus.pending;
      default:
        throw ArgumentError('Invalid SyncStatus string: $json');
    }
  }

  String get value {
    switch (this) {
      case SyncStatus.idle:
        return 'idle';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.error:
        return 'error';
      case SyncStatus.offline:
        return 'offline';
      case SyncStatus.pending:
        return 'pending';
    }
  }
}
