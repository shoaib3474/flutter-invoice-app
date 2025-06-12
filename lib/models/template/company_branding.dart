class CompanyBranding {
  final String companyName;
  final String? logoPath;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? gstin;
  final String? pan;
  final bool showLogo;
  final bool showAddress;
  final bool showContact;

  const CompanyBranding({
    required this.companyName,
    this.logoPath,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.gstin,
    this.pan,
    this.showLogo = true,
    this.showAddress = true,
    this.showContact = true,
  });

  factory CompanyBranding.defaultBranding() {
    return const CompanyBranding(
      companyName: 'Your Company Name',
      address: 'Your Company Address',
      phone: '+91 XXXXXXXXXX',
      email: 'info@yourcompany.com',
      website: 'www.yourcompany.com',
    );
  }

  CompanyBranding copyWith({
    String? companyName,
    String? logoPath,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? gstin,
    String? pan,
    bool? showLogo,
    bool? showAddress,
    bool? showContact,
  }) {
    return CompanyBranding(
      companyName: companyName ?? this.companyName,
      logoPath: logoPath ?? this.logoPath,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      showLogo: showLogo ?? this.showLogo,
      showAddress: showAddress ?? this.showAddress,
      showContact: showContact ?? this.showContact,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'logoPath': logoPath,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'gstin': gstin,
      'pan': pan,
      'showLogo': showLogo,
      'showAddress': showAddress,
      'showContact': showContact,
    };
  }

  factory CompanyBranding.fromJson(Map<String, dynamic> json) {
    return CompanyBranding(
      companyName: json['companyName'] ?? 'Your Company Name',
      logoPath: json['logoPath'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      gstin: json['gstin'],
      pan: json['pan'],
      showLogo: json['showLogo'] ?? true,
      showAddress: json['showAddress'] ?? true,
      showContact: json['showContact'] ?? true,
    );
  }
}
