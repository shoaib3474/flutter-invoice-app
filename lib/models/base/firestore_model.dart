import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  
  FirestoreModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });
  
  Map<String, dynamic> toMap();
  
  Map<String, dynamic> toFirestore() {
    final map = toMap();
    map['created_at'] = Timestamp.fromDate(createdAt);
    map['updated_at'] = Timestamp.fromDate(updatedAt);
    map['created_by'] = createdBy;
    return map;
  }
  
  static DateTime timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }
}
