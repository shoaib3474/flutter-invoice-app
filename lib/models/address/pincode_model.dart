class PostOffice {
  final String name;
  final String? description;
  final String branchType;
  final String deliveryStatus;
  final String circle;
  final String district;
  final String division;
  final String region;
  final String block;
  final String state;
  final String country;
  final String pincode;

  PostOffice({
    required this.name,
    this.description,
    required this.branchType,
    required this.deliveryStatus,
    required this.circle,
    required this.district,
    required this.division,
    required this.region,
    required this.block,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory PostOffice.fromJson(Map<String, dynamic> json) {
    return PostOffice(
      name: json['Name'] ?? '',
      description: json['Description'],
      branchType: json['BranchType'] ?? '',
      deliveryStatus: json['DeliveryStatus'] ?? '',
      circle: json['Circle'] ?? '',
      district: json['District'] ?? '',
      division: json['Division'] ?? '',
      region: json['Region'] ?? '',
      block: json['Block'] ?? '',
      state: json['State'] ?? '',
      country: json['Country'] ?? 'India',
      pincode: json['Pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'BranchType': branchType,
      'DeliveryStatus': deliveryStatus,
      'Circle': circle,
      'District': district,
      'Division': division,
      'Region': region,
      'Block': block,
      'State': state,
      'Country': country,
      'Pincode': pincode,
    };
  }
}

class AddressInfo {
  final String city;
  final String state;
  final String district;
  final String pincode;
  final List<PostOffice> postOffices;

  AddressInfo({
    required this.city,
    required this.state,
    required this.district,
    required this.pincode,
    required this.postOffices,
  });

  factory AddressInfo.fromPostOffices(List<PostOffice> postOffices) {
    if (postOffices.isEmpty) {
      throw Exception('No post offices provided');
    }

    final firstOffice = postOffices.first;
    return AddressInfo(
      city: firstOffice.district,
      state: firstOffice.state,
      district: firstOffice.district,
      pincode: firstOffice.pincode,
      postOffices: postOffices,
    );
  }
}
