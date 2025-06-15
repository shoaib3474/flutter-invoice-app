import 'package:flutter/material.dart';

class TemplateTypography {
  const TemplateTypography({
    required this.fontFamily,
    required this.headerFontSize,
    required this.bodyFontSize,
    required this.captionFontSize,
    required this.headerFontWeight,
    required this.bodyFontWeight,
    required this.lineHeight,
    required this.letterSpacing,
  });

  factory TemplateTypography.defaultTypography() {
    return const TemplateTypography(
      fontFamily: 'Roboto',
      headerFontSize: 24,
      bodyFontSize: 14,
      captionFontSize: 12,
      headerFontWeight: FontWeight.bold,
      bodyFontWeight: FontWeight.normal,
      lineHeight: 1.5,
      letterSpacing: 0,
    );
  }

  factory TemplateTypography.fromJson(Map<String, dynamic> json) {
    return TemplateTypography(
      fontFamily: json['fontFamily'] ?? 'Roboto',
      headerFontSize: json['headerFontSize']?.toDouble() ?? 24.0,
      bodyFontSize: json['bodyFontSize']?.toDouble() ?? 14.0,
      captionFontSize: json['captionFontSize']?.toDouble() ?? 12.0,
      headerFontWeight:
          FontWeight.values[json['headerFontWeight'] ?? FontWeight.bold.index],
      bodyFontWeight:
          FontWeight.values[json['bodyFontWeight'] ?? FontWeight.normal.index],
      lineHeight: json['lineHeight']?.toDouble() ?? 1.5,
      letterSpacing: json['letterSpacing']?.toDouble() ?? 0.0,
    );
  }
  final String fontFamily;
  final double headerFontSize;
  final double bodyFontSize;
  final double captionFontSize;
  final FontWeight headerFontWeight;
  final FontWeight bodyFontWeight;
  final double lineHeight;
  final double letterSpacing;

  TemplateTypography copyWith({
    String? fontFamily,
    double? headerFontSize,
    double? bodyFontSize,
    double? captionFontSize,
    FontWeight? headerFontWeight,
    FontWeight? bodyFontWeight,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return TemplateTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      headerFontSize: headerFontSize ?? this.headerFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      captionFontSize: captionFontSize ?? this.captionFontSize,
      headerFontWeight: headerFontWeight ?? this.headerFontWeight,
      bodyFontWeight: bodyFontWeight ?? this.bodyFontWeight,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'headerFontSize': headerFontSize,
      'bodyFontSize': bodyFontSize,
      'captionFontSize': captionFontSize,
      'headerFontWeight': headerFontWeight.index,
      'bodyFontWeight': bodyFontWeight.index,
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
    };
  }
}
