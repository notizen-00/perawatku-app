import '../../domain/entities/auth_user_entity.dart';
import 'patient_profile_model.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.phone,
    required super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.patientProfile,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      patientProfile: json['patient_profile'] is Map<String, dynamic>
          ? PatientProfileModel.fromJson(
              json['patient_profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'patient_profile': patientProfile is PatientProfileModel
          ? (patientProfile as PatientProfileModel).toJson()
          : null,
    };
  }
}
