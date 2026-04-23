import 'nurse_partner_profile_model.dart';

class NurseModel {
  const NurseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.distanceKm,
    required this.partnerProfile,
  });

  factory NurseModel.fromJson(Map<String, dynamic> json) {
    return NurseModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      distanceKm: _parseDistance(json['distance_km']),
      partnerProfile: json['partner_profile'] is Map<String, dynamic>
          ? NursePartnerProfileModel.fromJson(
              json['partner_profile'] as Map<String, dynamic>,
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

  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final double? distanceKm;
  final NursePartnerProfileModel? partnerProfile;
}
