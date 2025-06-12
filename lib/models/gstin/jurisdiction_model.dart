class GstJurisdiction {
  final String gstinOrPan;
  final String stateCode;
  final String stateName;
  final String centerJurisdiction;
  final String stateJurisdiction;
  final String taxPayerType;
  final String constitutionOfBusiness;
  
  GstJurisdiction({
    required this.gstinOrPan,
    required this.stateCode,
    required this.stateName,
    required this.centerJurisdiction,
    required this.stateJurisdiction,
    required this.taxPayerType,
    required this.constitutionOfBusiness,
  });
  
  // Convert to and from Map without external JSON libraries
  Map<String, dynamic> toMap() {
    return {
      'gstinOrPan': gstinOrPan,
      'stateCode': stateCode,
      'stateName': stateName,
      'centerJurisdiction': centerJurisdiction,
      'stateJurisdiction': stateJurisdiction,
      'taxPayerType': taxPayerType,
      'constitutionOfBusiness': constitutionOfBusiness,
    };
  }
  
  factory GstJurisdiction.fromMap(Map<String, dynamic> map) {
    return GstJurisdiction(
      gstinOrPan: map['gstinOrPan'],
      stateCode: map['stateCode'],
      stateName: map['stateName'],
      centerJurisdiction: map['centerJurisdiction'],
      stateJurisdiction: map['stateJurisdiction'],
      taxPayerType: map['taxPayerType'],
      constitutionOfBusiness: map['constitutionOfBusiness'],
    );
  }
}

class JurisdictionModel {
  final String centerJurisdiction;
  final String stateJurisdiction;
  final String division;
  final String commissionerate;
  final String range;
  final String ward;

  JurisdictionModel({
    required this.centerJurisdiction,
    required this.stateJurisdiction,
    required this.division,
    required this.commissionerate,
    required this.range,
    required this.ward,
  });

  factory JurisdictionModel.fromJson(Map<String, dynamic> json) {
    return JurisdictionModel(
      centerJurisdiction: json['centerJurisdiction'] ?? '',
      stateJurisdiction: json['stateJurisdiction'] ?? '',
      division: json['division'] ?? '',
      commissionerate: json['commissionerate'] ?? '',
      range: json['range'] ?? '',
      ward: json['ward'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerJurisdiction': centerJurisdiction,
      'stateJurisdiction': stateJurisdiction,
      'division': division,
      'commissionerate': commissionerate,
      'range': range,
      'ward': ward,
    };
  }
}
