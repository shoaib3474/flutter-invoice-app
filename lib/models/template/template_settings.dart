class TemplateSettings {
  final bool showHeader;
  final bool showFooter;
  final bool showWatermark;
  final bool showPageNumbers;
  final bool showBorder;
  final bool showCompanyLogo;
  final bool showTermsAndConditions;
  final String? watermarkText;
  final String? footerText;
  final String? termsAndConditions;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  const TemplateSettings({
    this.showHeader = true,
    this.showFooter = true,
    this.showWatermark = false,
    this.showPageNumbers = true,
    this.showBorder = true,
    this.showCompanyLogo = true,
    this.showTermsAndConditions = true,
    this.watermarkText,
    this.footerText,
    this.termsAndConditions,
    this.marginTop = 20.0,
    this.marginBottom = 20.0,
    this.marginLeft = 20.0,
    this.marginRight = 20.0,
  });

  factory TemplateSettings.defaultSettings() {
    return const TemplateSettings(
      footerText: 'Thank you for your business!',
      termsAndConditions: 'Terms and conditions apply.',
    );
  }

  TemplateSettings copyWith({
    bool? showHeader,
    bool? showFooter,
    bool? showWatermark,
    bool? showPageNumbers,
    bool? showBorder,
    bool? showCompanyLogo,
    bool? showTermsAndConditions,
    String? watermarkText,
    String? footerText,
    String? termsAndConditions,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
  }) {
    return TemplateSettings(
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
      showWatermark: showWatermark ?? this.showWatermark,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      showBorder: showBorder ?? this.showBorder,
      showCompanyLogo: showCompanyLogo ?? this.showCompanyLogo,
      showTermsAndConditions: showTermsAndConditions ?? this.showTermsAndConditions,
      watermarkText: watermarkText ?? this.watermarkText,
      footerText: footerText ?? this.footerText,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      marginTop: marginTop ?? this.marginTop,
      marginBottom: marginBottom ?? this.marginBottom,
      marginLeft: marginLeft ?? this.marginLeft,
      marginRight: marginRight ?? this.marginRight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showHeader': showHeader,
      'showFooter': showFooter,
      'showWatermark': showWatermark,
      'showPageNumbers': showPageNumbers,
      'showBorder': showBorder,
      'showCompanyLogo': showCompanyLogo,
      'showTermsAndConditions': showTermsAndConditions,
      'watermarkText': watermarkText,
      'footerText': footerText,
      'termsAndConditions': termsAndConditions,
      'marginTop': marginTop,
      'marginBottom': marginBottom,
      'marginLeft': marginLeft,
      'marginRight': marginRight,
    };
  }

  factory TemplateSettings.fromJson(Map<String, dynamic> json) {
    return TemplateSettings(
      showHeader: json['showHeader'] ?? true,
      showFooter: json['showFooter'] ?? true,
      showWatermark: json['showWatermark'] ?? false,
      showPageNumbers: json['showPageNumbers'] ?? true,
      showBorder: json['showBorder'] ?? true,
      showCompanyLogo: json['showCompanyLogo'] ?? true,
      showTermsAndConditions: json['showTermsAndConditions'] ?? true,
      watermarkText: json['watermarkText'],
      footerText: json['footerText'],
      termsAndConditions: json['termsAndConditions'],
      marginTop: json['marginTop']?.toDouble() ?? 20.0,
      marginBottom: json['marginBottom']?.toDouble() ?? 20.0,
      marginLeft: json['marginLeft']?.toDouble() ?? 20.0,
      marginRight: json['marginRight']?.toDouble() ?? 20.0,
    );
  }
}
