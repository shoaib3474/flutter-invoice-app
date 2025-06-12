enum FavoriteItemType {
  gstrReturn,
  reconciliation,
  report,
  dashboard,
  contact,
}

class FavoriteItem {
  final String id;
  final String name;
  final FavoriteItemType type;
  final String? description;
  final String route;
  final Map<String, dynamic>? parameters;
  final DateTime createdAt;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.route,
    this.parameters,
    required this.createdAt,
  });

  factory FavoriteItem.create({
    required String name,
    required FavoriteItemType type,
    String? description,
    required String route,
    Map<String, dynamic>? parameters,
  }) {
    return FavoriteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      description: description,
      route: route,
      parameters: parameters,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'description': description,
      'route': route,
      'parameters': parameters != null ? _encodeParameters(parameters!) : null,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'],
      name: map['name'],
      type: FavoriteItemType.values[map['type']],
      description: map['description'],
      route: map['route'],
      parameters: map['parameters'] != null ? _decodeParameters(map['parameters']) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  static String _encodeParameters(Map<String, dynamic> parameters) {
    return parameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }

  static Map<String, dynamic> _decodeParameters(String encoded) {
    final result = <String, dynamic>{};
    final pairs = encoded.split('&');
    
    for (final pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        result[keyValue[0]] = keyValue[1];
      }
    }
    
    return result;
  }

  String getTypeDisplayName() {
    switch (type) {
      case FavoriteItemType.gstrReturn:
        return 'GST Return';
      case FavoriteItemType.reconciliation:
        return 'Reconciliation';
      case FavoriteItemType.report:
        return 'Report';
      case FavoriteItemType.dashboard:
        return 'Dashboard';
      case FavoriteItemType.contact:
        return 'Contact';
    }
  }

  String getIconName() {
    switch (type) {
      case FavoriteItemType.gstrReturn:
        return 'description';
      case FavoriteItemType.reconciliation:
        return 'compare_arrows';
      case FavoriteItemType.report:
        return 'assessment';
      case FavoriteItemType.dashboard:
        return 'dashboard';
      case FavoriteItemType.contact:
        return 'person';
    }
  }
}
