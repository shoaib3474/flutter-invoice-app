extension CustomerExtensions on Customer {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'gstin': gstin,
      'panNumber': panNumber,
      'type': type.toString(),
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'],
      address: map['address'],
      gstin: map['gstin'],
      panNumber: map['panNumber'],
      type: CustomerType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => CustomerType.regular,
      ),
      creditLimit: (map['creditLimit'] ?? 0).toDouble(),
      currentBalance: (map['currentBalance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
