// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });

  // Convert UserModel to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create UserModel from JSON (from Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // Copy with method (untuk update data)
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt)';
  }
}