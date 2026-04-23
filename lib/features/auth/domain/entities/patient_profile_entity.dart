class PatientProfileEntity {
  const PatientProfileEntity({
    required this.id,
    required this.userId,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.bloodType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.allergies,
    required this.medicalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String allergies;
  final String medicalNotes;
  final String createdAt;
  final String updatedAt;
}
