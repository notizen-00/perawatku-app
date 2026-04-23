import '../../domain/entities/patient_profile_entity.dart';

class PatientProfileModel extends PatientProfileEntity {
  const PatientProfileModel({
    required super.id,
    required super.userId,
    required super.dateOfBirth,
    required super.gender,
    required super.address,
    required super.bloodType,
    required super.emergencyContactName,
    required super.emergencyContactPhone,
    required super.allergies,
    required super.medicalNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      bloodType: json['blood_type'] as String? ?? '',
      emergencyContactName: json['emergency_contact_name'] as String? ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] as String? ?? '',
      allergies: json['allergies'] as String? ?? '',
      medicalNotes: json['medical_notes'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'blood_type': bloodType,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'allergies': allergies,
      'medical_notes': medicalNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
