class TemplateColors {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color headerColor;
  final Color borderColor;
  final Color accentColor;

  const TemplateColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.headerColor,
    required this.borderColor,
    required this.accentColor,
  });

  factory TemplateColors.defaultColors() {
    return const TemplateColors(
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF03DAC6),
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF000000),
      headerColor: Color(0xFF1976D2),
      borderColor: Color(0xFFE0E0E0),
      accentColor: Color(0xFFFF5722),
    );
  }

  TemplateColors copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? headerColor,
    Color? borderColor,
    Color? accentColor,
  }) {
    return TemplateColors(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      headerColor: headerColor ?? this.headerColor,
      borderColor: borderColor ?? this.borderColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'headerColor': headerColor.value,
      'borderColor': borderColor.value,
      'accentColor': accentColor.value,
    };
  }

  factory TemplateColors.fromJson(Map<String, dynamic> json) {
    return TemplateColors(
      primaryColor: Color(json['primaryColor'] ?? 0xFF2196F3),
      secondaryColor: Color(json['secondaryColor'] ?? 0xFF03DAC6),
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      textColor: Color(json['textColor'] ?? 0xFF000000),
      headerColor: Color(json['headerColor'] ?? 0xFF1976D2),
      borderColor: Color(json['borderColor'] ?? 0xFFE0E0E0),
      accentColor: Color(json['accentColor'] ?? 0xFFFF5722),
    );
  }
}
