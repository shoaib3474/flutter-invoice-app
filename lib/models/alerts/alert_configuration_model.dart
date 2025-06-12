import 'package:flutter/material.dart';

enum AlertMetricType {
  complianceScore,
  matchPercentage,
  taxDifference,
  issueCount,
  reconciliationCount
}

enum AlertSeverity {
  info,
  warning,
  critical
}

enum AlertOperator {
  lessThan,
  greaterThan,
  equalTo,
  notEqualTo,
  lessThanOrEqual,
  greaterThanOrEqual
}

class AlertConfiguration {
  final String id;
  final String name;
  final AlertMetricType metricType;
  final AlertOperator operator;
  final double threshold;
  final AlertSeverity severity;
  final bool enabled;
  final String? reconciliationType; // Optional, specific to a reconciliation type
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertConfiguration({
    required this.id,
    required this.name,
    required this.metricType,
    required this.operator,
    required this.threshold,
    required this.severity,
    required this.enabled,
    this.reconciliationType,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertConfiguration.create({
    required String name,
    required AlertMetricType metricType,
    required AlertOperator operator,
    required double threshold,
    required AlertSeverity severity,
    String? reconciliationType,
    String? description,
  }) {
    final now = DateTime.now();
    return AlertConfiguration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      metricType: metricType,
      operator: operator,
      threshold: threshold,
      severity: severity,
      enabled: true,
      reconciliationType: reconciliationType,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  AlertConfiguration copyWith({
    String? name,
    AlertMetricType? metricType,
    AlertOperator? operator,
    double? threshold,
    AlertSeverity? severity,
    bool? enabled,
    String? reconciliationType,
    String? description,
  }) {
    return AlertConfiguration(
      id: this.id,
      name: name ?? this.name,
      metricType: metricType ?? this.metricType,
      operator: operator ?? this.operator,
      threshold: threshold ?? this.threshold,
      severity: severity ?? this.severity,
      enabled: enabled ?? this.enabled,
      reconciliationType: reconciliationType ?? this.reconciliationType,
      description: description ?? this.description,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'metricType': metricType.index,
      'operator': operator.index,
      'threshold': threshold,
      'severity': severity.index,
      'enabled': enabled ? 1 : 0,
      'reconciliationType': reconciliationType,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AlertConfiguration.fromMap(Map<String, dynamic> map) {
    return AlertConfiguration(
      id: map['id'],
      name: map['name'],
      metricType: AlertMetricType.values[map['metricType']],
      operator: AlertOperator.values[map['operator']],
      threshold: map['threshold'],
      severity: AlertSeverity.values[map['severity']],
      enabled: map['enabled'] == 1,
      reconciliationType: map['reconciliationType'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  String getMetricTypeDisplayName() {
    switch (metricType) {
      case AlertMetricType.complianceScore:
        return 'Compliance Score';
      case AlertMetricType.matchPercentage:
        return 'Match Percentage';
      case AlertMetricType.taxDifference:
        return 'Tax Difference';
      case AlertMetricType.issueCount:
        return 'Issue Count';
      case AlertMetricType.reconciliationCount:
        return 'Reconciliation Count';
    }
  }

  String getOperatorDisplayName() {
    switch (operator) {
      case AlertOperator.lessThan:
        return 'Less Than';
      case AlertOperator.greaterThan:
        return 'Greater Than';
      case AlertOperator.equalTo:
        return 'Equal To';
      case AlertOperator.notEqualTo:
        return 'Not Equal To';
      case AlertOperator.lessThanOrEqual:
        return 'Less Than or Equal To';
      case AlertOperator.greaterThanOrEqual:
        return 'Greater Than or Equal To';
    }
  }

  String getOperatorSymbol() {
    switch (operator) {
      case AlertOperator.lessThan:
        return '<';
      case AlertOperator.greaterThan:
        return '>';
      case AlertOperator.equalTo:
        return '=';
      case AlertOperator.notEqualTo:
        return '≠';
      case AlertOperator.lessThanOrEqual:
        return '≤';
      case AlertOperator.greaterThanOrEqual:
        return '≥';
    }
  }

  Color getSeverityColor() {
    switch (severity) {
      case AlertSeverity.info:
        return Colors.blue;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  IconData getSeverityIcon() {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.critical:
        return Icons.error_outline;
    }
  }

  String getSeverityDisplayName() {
    switch (severity) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}
