// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

class AppSetting {
  // Constructor (non-const, to allow DateTime.now())
  AppSetting({
    required this.key,
    required this.value,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  // Create from JSON
  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : DateTime.now(),
    );
  }
  final String key;
  final String value;
  final DateTime lastModified;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  // Create a copy with optional overrides
  AppSetting copyWith({
    String? key,
    String? value,
    DateTime? lastModified,
  }) {
    return AppSetting(
      key: key ?? this.key,
      value: value ?? this.value,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // String representation
  @override
  String toString() {
    return 'AppSetting(key: $key, value: $value, lastModified: $lastModified)';
  }

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSetting &&
        other.key == key &&
        other.value == value &&
        other.lastModified == lastModified;
  }

  // Hashcode
  @override
  int get hashCode => key.hashCode ^ value.hashCode ^ lastModified.hashCode;
}
