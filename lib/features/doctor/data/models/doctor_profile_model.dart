import '../../domain/entities/doctor_profile_entity.dart';

class DoctorProfileModel extends DoctorProfileEntity {
  const DoctorProfileModel({
    required super.id,
    required super.userId,
    required super.profession,
    required super.photoUrl,
    required super.specialization,
    required super.licenseNumber,
    required super.workLocation,
    required super.latitude,
    required super.longitude,
    required super.yearsOfExperience,
    required super.consultationFee,
    required super.isAvailable,
    required super.bio,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      profession: json['profession'] as String? ?? '',
      photoUrl: _readPhotoUrl(json),
      specialization: json['specialization'] as String? ?? '',
      licenseNumber: json['license_number'] as String? ?? '',
      workLocation: json['work_location'] as String? ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      consultationFee: json['consultation_fee']?.toString() ?? '',
      isAvailable: json['is_available'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  static String? _readPhotoUrl(Map<String, dynamic> json) {
    const keys = [
      'photo_url',
      'photo',
      'image_url',
      'image',
      'avatar_url',
      'avatar',
      'profile_photo_url',
      'profile_picture',
    ];

    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}
