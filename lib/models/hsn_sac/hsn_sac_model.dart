import 'dart:convert';

class HsnSacCode {
  final String code;
  final String description;
  final String type; // 'HSN' or 'SAC'
  final double? gstRate;
  final String? unit;
  final bool isActive;

  const HsnSacCode({
    required this.code,
    required this.description,
    required this.type,
    this.gstRate,
    this.unit,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'type': type,
      'gst_rate': gstRate,
      'unit': unit,
      'is_active': isActive,
    };
  }

  factory HsnSacCode.fromMap(Map<String, dynamic> map) {
    return HsnSacCode(
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      gstRate: map['gst_rate']?.toDouble(),
      unit: map['unit'],
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory HsnSacCode.fromJson(String source) =>
      HsnSacCode.fromMap(json.decode(source));

  HsnSacCode copyWith({
    String? code,
    String? description,
    String? type,
    double? gstRate,
    String? unit,
    bool? isActive,
  }) {
    return HsnSacCode(
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      gstRate: gstRate ?? this.gstRate,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
    );
  }
}
