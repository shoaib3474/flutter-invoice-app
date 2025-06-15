class MigrationResult {
  MigrationResult({
    required this.success,
    required this.message,
    required this.details,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MigrationResult.fromJson(Map<String, dynamic> json) {
    return MigrationResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      details: json['details'] ?? '',
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
  final bool success;
  final String message;
  final String details;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'details': details,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MigrationResult(success: $success, message: $message, details: $details)';
  }
}
