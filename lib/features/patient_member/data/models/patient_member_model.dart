import '../../domain/entities/patient_member_entity.dart';

class PatientMemberModel extends PatientMemberEntity {
  const PatientMemberModel({
    required super.id,
    required super.patientUserId,
    required super.name,
    required super.relationship,
    required super.dateOfBirth,
    required super.age,
    required super.gender,
    required super.phone,
    required super.bloodType,
    required super.emergencyContactName,
    required super.emergencyContactPhone,
    required super.allergies,
    required super.medicalNotes,
    required super.addressLabel,
    required super.recipientName,
    required super.recipientPhone,
    required super.address,
    required super.province,
    required super.city,
    required super.district,
    required super.postalCode,
    required super.latitude,
    required super.longitude,
    required super.isPrimary,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PatientMemberModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrapData(json);

    return PatientMemberModel(
      id: _asInt(data['id']),
      patientUserId: _asInt(data['patient_user_id'] ?? data['user_id']),
      name: data['name'] as String? ?? '',
      relationship: data['relationship'] as String? ?? '',
      dateOfBirth: data['date_of_birth'] as String? ?? '',
      age: data['age'] == null ? null : _asInt(data['age']),
      gender: data['gender'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      bloodType: data['blood_type'] as String? ?? '',
      emergencyContactName: data['emergency_contact_name'] as String? ?? '',
      emergencyContactPhone: data['emergency_contact_phone'] as String? ?? '',
      allergies: data['allergies'] as String? ?? '',
      medicalNotes: data['medical_notes'] as String? ?? '',
      addressLabel: data['address_label'] as String? ?? '',
      recipientName: data['recipient_name'] as String? ?? '',
      recipientPhone: data['recipient_phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      province: data['province'] as String? ?? '',
      city: data['city'] as String? ?? '',
      district: data['district'] as String? ?? '',
      postalCode: data['postal_code'] as String? ?? '',
      latitude: _asDouble(data['latitude']),
      longitude: _asDouble(data['longitude']),
      isPrimary: data['is_primary'] == true || data['is_primary'] == 1,
      createdAt: data['created_at'] as String? ?? '',
      updatedAt: data['updated_at'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return json;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
