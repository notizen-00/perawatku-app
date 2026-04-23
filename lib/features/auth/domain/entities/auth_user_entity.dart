import 'patient_profile_entity.dart';

class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.patientProfile,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final PatientProfileEntity? patientProfile;
}
