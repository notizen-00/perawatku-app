/// Entity yang merepresentasikan lokasi mitra (dokter/perawat) di peta
class PartnerLocation {
  final String id;
  final String partnerId;
  final PartnerType partnerType;
  final String name;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isOnline;
  final DateTime? lastUpdate;

  PartnerLocation({
    required this.id,
    required this.partnerId,
    required this.partnerType,
    required this.name,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.isOnline,
    this.lastUpdate,
  });
}

enum PartnerType { doctor, nurse }

extension PartnerTypeExtension on PartnerType {
  String get displayName {
    switch (this) {
      case PartnerType.doctor:
        return 'Dokter';
      case PartnerType.nurse:
        return 'Perawat';
    }
  }
}
