class NursePartnerProfileModel {
  const NursePartnerProfileModel({
    required this.id,
    required this.userId,
    required this.profession,
    this.photoUrl,
    required this.specialization,
    required this.licenseNumber,
    required this.workLocation,
    required this.latitude,
    required this.longitude,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.isAvailable,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NursePartnerProfileModel.fromJson(Map<String, dynamic> json) {
    return NursePartnerProfileModel(
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

  final int id;
  final int userId;
  final String profession;
  final String? photoUrl;
  final String specialization;
  final String licenseNumber;
  final String workLocation;
  final String latitude;
  final String longitude;
  final int yearsOfExperience;
  final String consultationFee;
  final bool isAvailable;
  final String bio;
  final String createdAt;
  final String updatedAt;

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
