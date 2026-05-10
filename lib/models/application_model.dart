/**
 * Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
 * Student Names  : [TO BE FILLED BY GROUP MEMBERS]
 * Question: Application Model
 */

class ApplicationModel {
  final String? id;
  final String? studentId;
  final String studentNumber;
  final String fullName;
  final int yearOfStudy;
  final String module1Level;
  final String module1Name;
  final String? module2Level;
  final String? module2Name;
  final bool meetsRequirements;
  final String? documentUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApplicationModel({
    this.id,
    this.studentId,
    required this.studentNumber,
    required this.fullName,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.meetsRequirements,
    this.documentUrl,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this model with updated fields
  ApplicationModel copyWith({
    String? id,
    String? studentId,
    String? studentNumber,
    String? fullName,
    int? yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
    bool? meetsRequirements,
    String? documentUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentNumber: studentNumber ?? this.studentNumber,
      fullName: fullName ?? this.fullName,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Name: module1Name ?? this.module1Name,
      module2Level: module2Level ?? this.module2Level,
      module2Name: module2Name ?? this.module2Name,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts model to Map for Supabase insert/update
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_number': studentNumber,
      'full_name': fullName,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'module2_level': module2Level,
      'module2_name': module2Name,
      'meets_requirements': meetsRequirements,
      'document_url': documentUrl,
      'status': status,
    };
  }

  /// Creates model from Supabase Map response
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id']?.toString(),
      studentId: map['student_id']?.toString(),
      studentNumber: map['student_number'] ?? '',
      fullName: map['full_name'] ?? '',
      yearOfStudy: map['year_of_study'] ?? 1,
      module1Level: map['module1_level'] ?? '',
      module1Name: map['module1_name'] ?? '',
      module2Level: map['module2_level'],
      module2Name: map['module2_name'],
      meetsRequirements: map['meets_requirements'] ?? false,
      documentUrl: map['document_url'],
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }
}