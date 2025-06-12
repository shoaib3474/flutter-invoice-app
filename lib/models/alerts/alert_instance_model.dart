import 'alert_severity.dart';

enum AlertMetricType {
  taxMismatch,
  filingDelay,
  complianceIssue,
  dataInconsistency,
  systemError;

  String get displayName {
    switch (this) {
      case AlertMetricType.taxMismatch:
        return 'Tax Mismatch';
      case AlertMetricType.filingDelay:
        return 'Filing Delay';
      case AlertMetricType.complianceIssue:
        return 'Compliance Issue';
      case AlertMetricType.dataInconsistency:
        return 'Data Inconsistency';
      case AlertMetricType.systemError:
        return 'System Error';
    }
  }
}

class AlertInstance {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertMetricType metricType;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const AlertInstance({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.metricType,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory AlertInstance.fromJson(Map<String, dynamic> json) {
    return AlertInstance(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.fromString(json['severity'] as String),
      metricType: AlertMetricType.values.firstWhere(
        (e) => e.name == json['metricType'],
        orElse: () => AlertMetricType.systemError,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity.name,
      'metricType': metricType.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  AlertInstance copyWith({
    String? id,
    String? title,
    String? message,
    AlertSeverity? severity,
    AlertMetricType? metricType,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return AlertInstance(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      metricType: metricType ?? this.metricType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertInstance &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.severity == severity &&
        other.metricType == metricType &&
        other.createdAt == createdAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, message, severity, metricType, createdAt, isRead);
  }

  @override
  String toString() {
    return 'AlertInstance(id: $id, title: $title, severity: $severity, metricType: $metricType, createdAt: $createdAt, isRead: $isRead)';
  }
}
