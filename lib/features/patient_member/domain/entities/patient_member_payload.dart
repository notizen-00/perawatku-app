class PatientMemberPayload {
  const PatientMemberPayload({
    required this.name,
    this.relationship,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.phone,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.allergies,
    this.medicalNotes,
    this.addressLabel,
    this.recipientName,
    this.recipientPhone,
    this.address,
    this.province,
    this.city,
    this.district,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isPrimary,
  });

  final String name;
  final String? relationship;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? phone;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? allergies;
  final String? medicalNotes;
  final String? addressLabel;
  final String? recipientName;
  final String? recipientPhone;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool? isPrimary;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      if (_hasValue(relationship)) 'relationship': relationship!.trim(),
      if (_hasValue(dateOfBirth)) 'date_of_birth': dateOfBirth!.trim(),
      if (age != null) 'age': age,
      if (_hasValue(gender)) 'gender': gender!.trim(),
      if (_hasValue(phone)) 'phone': phone!.trim(),
      if (_hasValue(bloodType)) 'blood_type': bloodType!.trim(),
      if (_hasValue(emergencyContactName))
        'emergency_contact_name': emergencyContactName!.trim(),
      if (_hasValue(emergencyContactPhone))
        'emergency_contact_phone': emergencyContactPhone!.trim(),
      if (_hasValue(allergies)) 'allergies': allergies!.trim(),
      if (_hasValue(medicalNotes)) 'medical_notes': medicalNotes!.trim(),
      if (_hasValue(addressLabel)) 'address_label': addressLabel!.trim(),
      if (_hasValue(recipientName)) 'recipient_name': recipientName!.trim(),
      if (_hasValue(recipientPhone)) 'recipient_phone': recipientPhone!.trim(),
      if (_hasValue(address)) 'address': address!.trim(),
      if (_hasValue(province)) 'province': province!.trim(),
      if (_hasValue(city)) 'city': city!.trim(),
      if (_hasValue(district)) 'district': district!.trim(),
      if (_hasValue(postalCode)) 'postal_code': postalCode!.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isPrimary != null) 'is_primary': isPrimary,
    };
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
