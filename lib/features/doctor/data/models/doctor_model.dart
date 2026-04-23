import '../../domain/entities/doctor_entity.dart';
import 'doctor_profile_model.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.phone,
    required super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.distanceKm,
    required super.profile,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      distanceKm: _parseDistance(json['distance_km']),
      profile: json['partner_profile'] is Map<String, dynamic>
          ? DoctorProfileModel.fromJson(
              json['partner_profile'] as Map<String, dynamic>,
            )
          : json['doctor_profile'] is Map<String, dynamic>
              ? DoctorProfileModel.fromJson(
                  json['doctor_profile'] as Map<String, dynamic>,
                )
              : null,
    );
  }

  static double? _parseDistance(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}
