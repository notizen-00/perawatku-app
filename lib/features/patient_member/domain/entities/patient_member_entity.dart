class PatientMemberEntity {
  const PatientMemberEntity({
    required this.id,
    required this.patientUserId,
    required this.name,
    required this.relationship,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.phone,
    required this.bloodType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.allergies,
    required this.medicalNotes,
    required this.addressLabel,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.province,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int patientUserId;
  final String name;
  final String relationship;
  final String dateOfBirth;
  final int? age;
  final String gender;
  final String phone;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String allergies;
  final String medicalNotes;
  final String addressLabel;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String province;
  final String city;
  final String district;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final String createdAt;
  final String updatedAt;
}
