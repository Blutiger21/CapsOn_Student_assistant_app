
/**
 *223038085 BF MOTSEKI
 *223040545 FB AMATEBELLE
 *223051025 LD MOKHETI
 *223007530 A JARA
 *223020021 B MBINGA
 * 221034577 ML MWENDA
 *222033434 KD TSOLO
 *224020157 KP MOLELEKENG
 *223005893 TV THABISI
 */

/// Question: User Model
library;

class UserModel {
  final String id;
  final String email;
  final String role; // 'student' or 'admin'
  final String? fullName;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      fullName: map['full_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'full_name': fullName,
    };
  }
}