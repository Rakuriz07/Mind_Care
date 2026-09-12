import 'package:cloud_firestore/cloud_firestore.dart';

DateTime dateTimeFromJson(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

Timestamp dateTimeToJson(DateTime value) => Timestamp.fromDate(value);

class UserModelFirebase {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModelFirebase({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) {
    return UserModelFirebase(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: dateTimeFromJson(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': dateTimeToJson(createdAt),
    };
  }
}
