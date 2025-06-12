import 'package:json_annotation/json_annotation.dart';

import 'template_colors.dart';
import 'template_typography.dart';
import 'company_branding.dart';
import 'template_settings.dart';

part 'invoice_template_model.g.dart';

@JsonSerializable()
class InvoiceTemplate {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> templateData;
  final TemplateColors colors;
  final TemplateTypography typography;
  final CompanyBranding branding;
  final TemplateSettings settings;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.templateData,
    required this.colors,
    required this.typography,
    required this.branding,
    required this.settings,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceTemplate.fromJson(Map<String, dynamic> json) =>
      _$InvoiceTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceTemplateToJson(this);

  InvoiceTemplate copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? templateData,
    TemplateColors? colors,
    TemplateTypography? typography,
    CompanyBranding? branding,
    TemplateSettings? settings,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      templateData: templateData ?? this.templateData,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      branding: branding ?? this.branding,
      settings: settings ?? this.settings,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
