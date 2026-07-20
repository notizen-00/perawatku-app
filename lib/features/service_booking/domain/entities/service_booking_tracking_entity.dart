class ServiceBookingTrackingEntity {
  const ServiceBookingTrackingEntity({
    required this.serviceBookingId,
    required this.bookingCode,
    required this.status,
    required this.assignedPartnerUserId,
    required this.partner,
    required this.partnerLocation,
    required this.destination,
    required this.channel,
    required this.event,
  });

  final int serviceBookingId;
  final String? bookingCode;
  final String status;
  final int? assignedPartnerUserId;
  final ServiceBookingTrackingPartnerEntity? partner;
  final ServiceBookingTrackingLocationEntity? partnerLocation;
  final ServiceBookingTrackingDestinationEntity? destination;
  final String? channel;
  final String? event;

  bool get hasRouteCoordinates {
    return partnerLocation?.latitude != null &&
        partnerLocation?.longitude != null &&
        destination?.latitude != null &&
        destination?.longitude != null;
  }
}

class ServiceBookingTrackingPartnerEntity {
  const ServiceBookingTrackingPartnerEntity({
    required this.id,
    required this.name,
    required this.phone,
  });

  final int? id;
  final String? name;
  final String? phone;
}

class ServiceBookingTrackingLocationEntity {
  const ServiceBookingTrackingLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.heading,
    required this.speedMps,
    required this.updatedAt,
  });

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? heading;
  final double? speedMps;
  final DateTime? updatedAt;
}

class ServiceBookingTrackingDestinationEntity {
  const ServiceBookingTrackingDestinationEntity({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final int? id;
  final String? label;
  final String? address;
  final double? latitude;
  final double? longitude;
}
