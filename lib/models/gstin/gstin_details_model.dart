import 'jurisdiction_model.dart';

class GstinAddress {
  final String building;
  final String floor;
  final String street;
  final String location;
  final String city;
  final String district;
  final String state;
  final String pincode;

  GstinAddress({
    required this.building,
    required this.floor,
    required this.street,
    required this.location,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
  });

  factory GstinAddress.fromJson(Map<String, dynamic> json) {
    return GstinAddress(
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      street: json['street'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building': building,
      'floor': floor,
      'street': street,
      'location': location,
      'city': city,
      'district': district,
      'state': state,
      'pincode': pincode,
    };
  }
}

class GstinDetailsModel {
  final String gstin;
  final String legalName;
  final String tradeName;
  final String pan;
  final String status;
  final String registrationDate;
  final String businessType;
  final String taxpayerType;
  final GstinAddress address;
  final JurisdictionModel jurisdiction;

  GstinDetailsModel({
    required this.gstin,
    required this.legalName,
    required this.tradeName,
    required this.pan,
    required this.status,
    required this.registrationDate,
    required this.businessType,
    required this.taxpayerType,
    required this.address,
    required this.jurisdiction,
  });

  factory GstinDetailsModel.fromJson(Map<String, dynamic> json) {
    return GstinDetailsModel(
      gstin: json['gstin'] ?? '',
      legalName: json['legalName'] ?? '',
      tradeName: json['tradeName'] ?? '',
      pan: json['pan'] ?? '',
      status: json['status'] ?? '',
      registrationDate: json['registrationDate'] ?? '',
      businessType: json['businessType'] ?? '',
      taxpayerType: json['taxpayerType'] ?? '',
      address: GstinAddress.fromJson(json['address'] ?? {}),
      jurisdiction: JurisdictionModel.fromJson(json['jurisdiction'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'legalName': legalName,
      'tradeName': tradeName,
      'pan': pan,
      'status': status,
      'registrationDate': registrationDate,
      'businessType': businessType,
      'taxpayerType': taxpayerType,
      'address': address.toJson(),
      'jurisdiction': jurisdiction.toJson(),
    };
  }
}
