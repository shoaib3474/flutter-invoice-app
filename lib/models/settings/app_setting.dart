class AppSetting {
  final String key;
  final String value;
  final DateTime lastModified;

  const AppSetting({
    required this.key,
    required this.value,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? const Duration().inMilliseconds != 0 ? DateTime.now() : DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified']) 
          : DateTime.now(),
    );
  }

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

  @override
  String toString() {
    return 'AppSetting(key: $key, value: $value, lastModified: $lastModified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSetting && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
