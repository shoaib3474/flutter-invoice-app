enum TemplateStyle {
  classic,
  modern,
  minimal,
  professional,
  creative,
}

enum TemplateLayout {
  standard,
  compact,
  detailed,
  itemFocused,
}

class TemplateColors {
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color headerColor;
  final Color borderColor;

  const TemplateColors({
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.headerColor,
    required this.borderColor,
  });

  static const TemplateColors defaultColors = TemplateColors(
    primaryColor: Color(0xFF2196F3),
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    headerColor: Color(0xFFF5F5F5),
    borderColor: Color(0xFFE0E0E0),
  );
}

class TemplateTypography {
  final double headerFontSize;
  final double titleFontSize;
  final double bodyFontSize;
  final double captionFontSize;
  final FontWeight headerFontWeight;
  final FontWeight titleFontWeight;

  const TemplateTypography({
    required this.headerFontSize,
    required this.titleFontSize,
    required this.bodyFontSize,
    required this.captionFontSize,
    required this.headerFontWeight,
    required this.titleFontWeight,
  });

  static const TemplateTypography defaultTypography = TemplateTypography(
    headerFontSize: 24,
    titleFontSize: 18,
    bodyFontSize: 14,
    captionFontSize: 12,
    headerFontWeight: FontWeight.bold,
    titleFontWeight: FontWeight.w600,
  );
}

class TemplateSettings {
  final bool showLogo;
  final bool showCompanyAddress;
  final bool showGstDetails;
  final bool showTermsAndConditions;
  final bool enableQrCode;

  const TemplateSettings({
    this.showLogo = true,
    this.showCompanyAddress = true,
    this.showGstDetails = true,
    this.showTermsAndConditions = true,
    this.enableQrCode = false,
  });
}

class CompanyBranding {
  final String companyName;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final String gstin;
  final String pan;
  final String email;
  final String phone;
  final String website;
  final String? tagline;

  const CompanyBranding({
    required this.companyName,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.gstin,
    required this.pan,
    required this.email,
    required this.phone,
    required this.website,
    this.tagline,
  });
}
