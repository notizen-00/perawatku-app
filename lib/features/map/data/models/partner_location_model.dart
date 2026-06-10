import '../../domain/entities/partner_location.dart';

/// Model untuk serialisasi/deserialisasi PartnerLocation
class PartnerLocationModel extends PartnerLocation {
  PartnerLocationModel({
    required String id,
    required String partnerId,
    required PartnerType partnerType,
    required String name,
    String? photoUrl,
    required double latitude,
    required double longitude,
    String? address,
    required bool isOnline,
    DateTime? lastUpdate,
  }) : super(
         id: id,
         partnerId: partnerId,
         partnerType: partnerType,
         name: name,
         photoUrl: photoUrl,
         latitude: latitude,
         longitude: longitude,
         address: address,
         isOnline: isOnline,
         lastUpdate: lastUpdate,
       );

  factory PartnerLocationModel.fromJson(Map<String, dynamic> json) {
    return PartnerLocationModel(
      id: json['id'] ?? '',
      partnerId: json['partner_id'] ?? '',
      partnerType: json['partner_type'] == 'doctor'
          ? PartnerType.doctor
          : PartnerType.nurse,
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'],
      isOnline: json['is_online'] ?? false,
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_id': partnerId,
      'partner_type': partnerType == PartnerType.doctor ? 'doctor' : 'nurse',
      'name': name,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_online': isOnline,
      'last_update': lastUpdate?.toIso8601String(),
    };
  }

  /// Membuat PartnerLocationModel dari data dokter
  factory PartnerLocationModel.fromDoctor(Map<String, dynamic> doctorJson) {
    return PartnerLocationModel(
      id: doctorJson['id'] ?? '',
      partnerId: doctorJson['id'] ?? '',
      partnerType: PartnerType.doctor,
      name: doctorJson['name'] ?? '',
      photoUrl: doctorJson['photo_url'],
      latitude: (doctorJson['latitude'] ?? -6.2088)
          .toDouble(), // Default Jakarta
      longitude: (doctorJson['longitude'] ?? 106.8456).toDouble(),
      address: doctorJson['address'],
      isOnline: doctorJson['is_online'] ?? true,
      lastUpdate: DateTime.now(),
    );
  }

  /// Membuat PartnerLocationModel dari data perawat
  factory PartnerLocationModel.fromNurse(Map<String, dynamic> nurseJson) {
    return PartnerLocationModel(
      id: nurseJson['id'] ?? '',
      partnerId: nurseJson['id'] ?? '',
      partnerType: PartnerType.nurse,
      name: nurseJson['name'] ?? '',
      photoUrl: nurseJson['photo_url'],
      latitude: (nurseJson['latitude'] ?? -6.2088).toDouble(),
      longitude: (nurseJson['longitude'] ?? 106.8456).toDouble(),
      address: nurseJson['address'],
      isOnline: nurseJson['is_online'] ?? true,
      lastUpdate: DateTime.now(),
    );
  }
}
