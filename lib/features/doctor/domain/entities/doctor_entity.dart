import 'doctor_profile_entity.dart';

class DoctorEntity {
  const DoctorEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.distanceKm,
    required this.profile,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final double? distanceKm;
  final DoctorProfileEntity? profile;
}
