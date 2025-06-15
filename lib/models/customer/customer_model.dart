// ignore_for_file: avoid_unused_constructor_parameters

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 5)
enum CustomerType {
  @HiveField(0)
  regular,
  @HiveField(1)
  wholesale,
  @HiveField(2)
  retail,
  @HiveField(3)
  distributor,
}

@HiveType(typeId: 1)
class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    this.mobile,
    this.email,
    this.address,
    this.gstin,
    this.panNumber,
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      address: json['address'],
      gstin: json['gstin'],
      panNumber: json['panNumber'],
      type: CustomerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CustomerType.regular,
      ),
      creditLimit: json['creditLimit']?.toDouble() ?? 0.0,
      currentBalance: json['currentBalance']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      phone: '',
      city: '',
      state: '',
      pincode: '',
    );
  }

  factory Customer.create({
    required String name,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? panNumber,
    CustomerType type = CustomerType.regular,
    double creditLimit = 0.0,
    double currentBalance = 0.0,
  }) {
    final now = DateTime.now();
    return Customer(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      gstin: gstin,
      panNumber: panNumber,
      type: type,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      createdAt: now,
      updatedAt: now,
      phone: '',
      city: '',
      state: '',
      pincode: '',
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? mobile;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String? gstin;

  @HiveField(6)
  final String? panNumber;

  @HiveField(7)
  final CustomerType type;

  @HiveField(8)
  final double creditLimit;

  @HiveField(9)
  final double currentBalance;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        email,
        address,
        gstin,
        panNumber,
        type,
        creditLimit,
        currentBalance,
        createdAt,
        updatedAt,
      ];

  Customer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? panNumber,
    CustomerType? type,
    double? creditLimit,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      panNumber: panNumber ?? this.panNumber,
      type: type ?? this.type,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      phone: '',
      city: '',
      state: '',
      pincode: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'gstin': gstin,
      'panNumber': panNumber,
      'type': type.name,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Customer? fromMap(Map<String, dynamic> customerData) {
    return null;
  }
}

extension CustomerTypeExtension on CustomerType {
  String get displayName {
    switch (this) {
      case CustomerType.regular:
        return 'Regular';
      case CustomerType.wholesale:
        return 'Wholesale';
      case CustomerType.retail:
        return 'Retail';
      case CustomerType.distributor:
        return 'Distributor';
    }
  }
}
