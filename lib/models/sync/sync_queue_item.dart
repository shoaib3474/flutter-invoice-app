import 'package:flutter_invoice_app/models/sync/sync_operation.dart';
import 'package:flutter_invoice_app/models/sync/sync_status.dart';

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    required this.status,
    this.data,
    this.attempts = 0,
    this.lastAttempt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final int attempts;
  final DateTime? lastAttempt;
  final SyncStatus status;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      operation: SyncOperationExtension.fromString(json['operation'] as String),
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      attempts: json['attempts'] as int? ?? 0,
      lastAttempt: json['last_attempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_attempt'] as int)
          : null,
      status: SyncStatusExtension.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation.value,
      'data': data,
      'created_at': createdAt.millisecondsSinceEpoch,
      'attempts': attempts,
      'last_attempt': lastAttempt?.millisecondsSinceEpoch,
      'status': status,
    };
  }

  SyncQueueItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? attempts,
    DateTime? lastAttempt,
    SyncStatus? status,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      status: status ?? this.status,
    );
  }
}
