// Simple model without external dependencies
class FilingReminder {
  final String id;
  final String gstin;
  final String returnType;
  final String returnPeriod;
  final DateTime dueDate;
  final List<ReminderAlert> alerts;
  final bool isEnabled;
  final String? notes;
  
  FilingReminder({
    String? id,
    required this.gstin,
    required this.returnType,
    required this.returnPeriod,
    required this.dueDate,
    required this.alerts,
    this.isEnabled = true,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // Convert to and from Map without external JSON libraries
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gstin': gstin,
      'returnType': returnType,
      'returnPeriod': returnPeriod,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'alerts': alerts.map((alert) => alert.toMap()).toList(),
      'isEnabled': isEnabled,
      'notes': notes,
    };
  }
  
  factory FilingReminder.fromMap(Map<String, dynamic> map) {
    return FilingReminder(
      id: map['id'],
      gstin: map['gstin'],
      returnType: map['returnType'],
      returnPeriod: map['returnPeriod'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      alerts: (map['alerts'] as List).map((alertMap) => 
          ReminderAlert.fromMap(alertMap)).toList(),
      isEnabled: map['isEnabled'],
      notes: map['notes'],
    );
  }
  
  FilingReminder copyWith({
    String? gstin,
    String? returnType,
    String? returnPeriod,
    DateTime? dueDate,
    List<ReminderAlert>? alerts,
    bool? isEnabled,
    String? notes,
  }) {
    return FilingReminder(
      id: id,
      gstin: gstin ?? this.gstin,
      returnType: returnType ?? this.returnType,
      returnPeriod: returnPeriod ?? this.returnPeriod,
      dueDate: dueDate ?? this.dueDate,
      alerts: alerts ?? this.alerts,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: notes ?? this.notes,
    );
  }
}

class ReminderAlert {
  final String id;
  final int daysBeforeDue;
  final bool isEnabled;
  final DateTime scheduledDate;
  final bool hasTriggered;
  
  ReminderAlert({
    String? id,
    required this.daysBeforeDue,
    this.isEnabled = true,
    required this.scheduledDate,
    this.hasTriggered = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // Convert to and from Map without external JSON libraries
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daysBeforeDue': daysBeforeDue,
      'isEnabled': isEnabled,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'hasTriggered': hasTriggered,
    };
  }
  
  factory ReminderAlert.fromMap(Map<String, dynamic> map) {
    return ReminderAlert(
      id: map['id'],
      daysBeforeDue: map['daysBeforeDue'],
      isEnabled: map['isEnabled'],
      scheduledDate: DateTime.fromMillisecondsSinceEpoch(map['scheduledDate']),
      hasTriggered: map['hasTriggered'],
    );
  }
  
  ReminderAlert copyWith({
    int? daysBeforeDue,
    bool? isEnabled,
    DateTime? scheduledDate,
    bool? hasTriggered,
  }) {
    return ReminderAlert(
      id: id,
      daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      hasTriggered: hasTriggered ?? this.hasTriggered,
    );
  }
  
  /// Factory method to create an alert based on days before due date
  factory ReminderAlert.fromDaysBeforeDue(int days, DateTime dueDate) {
    final scheduledDate = dueDate.subtract(Duration(days: days));
    return ReminderAlert(
      daysBeforeDue: days,
      scheduledDate: scheduledDate,
    );
  }
}
