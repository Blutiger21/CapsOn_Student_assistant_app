/// Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
/// Student Names  : [TO BE FILLED BY GROUP MEMBERS]
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