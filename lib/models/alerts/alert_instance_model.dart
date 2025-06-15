import 'package:flutter/foundation.dart';

@immutable
class AlertInstance {
  const AlertInstance({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.metricType,
    required this.createdAt,
    required this.isRead,
    required this.acknowledged,
    this.acknowledgedAt,
    this.metadata,
  });

  factory AlertInstance.fromMap(Map<String, dynamic> map) {
    return AlertInstance(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      severity: AlertSeverityExtension.fromString(map['severity'] as String),
      metricType: AlertMetricType.values.firstWhere(
        (e) => e.name == map['metricType'],
        orElse: () => AlertMetricType.systemError,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isRead: (map['isRead'] ?? 0) == 1,
      acknowledged: (map['acknowledged'] ?? 0) == 1,
      acknowledgedAt: map['acknowledgedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['acknowledgedAt'] as int)
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertMetricType metricType;
  final DateTime createdAt;
  final bool isRead;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final Map<String, dynamic>? metadata;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.name,
      'metricType': metricType.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead ? 1 : 0,
      'acknowledged': acknowledged ? 1 : 0,
      'acknowledgedAt': acknowledgedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }
}

enum AlertSeverity { info, warning, critical }

extension AlertSeverityExtension on AlertSeverity {
  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertSeverity.info,
    );
  }
}

enum AlertMetricType { usage, limit, systemError }
