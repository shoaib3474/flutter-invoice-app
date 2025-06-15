// ignore_for_file: always_declare_return_types

import 'package:flutter/material.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  offline,
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
    }
  }

  static fromString(String json) {}
}
