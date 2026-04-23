class NursePartnerProfileEntity {
  const NursePartnerProfileEntity({
    required this.id,
    required this.userId,
    required this.profession,
    required this.photoUrl,
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
}
