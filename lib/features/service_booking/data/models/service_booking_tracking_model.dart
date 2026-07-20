import '../../domain/entities/service_booking_tracking_entity.dart';

class ServiceBookingTrackingModel extends ServiceBookingTrackingEntity {
  const ServiceBookingTrackingModel({
    required super.serviceBookingId,
    required super.bookingCode,
    required super.status,
    required super.assignedPartnerUserId,
    required super.partner,
    required super.partnerLocation,
    required super.destination,
    required super.channel,
    required super.event,
  });

  factory ServiceBookingTrackingModel.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']) ?? json;
    return ServiceBookingTrackingModel(
      serviceBookingId: _readInt(data['service_booking_id']) ?? 0,
      bookingCode: _readString(data['booking_code']),
      status: _readString(data['status']) ?? 'pending',
      assignedPartnerUserId: _readInt(data['assigned_partner_user_id']),
      partner: ServiceBookingTrackingPartnerModel.fromJsonOrNull(
        _readMap(data['partner']),
      ),
      partnerLocation: ServiceBookingTrackingLocationModel.fromJsonOrNull(
        _readMap(data['partner_location']) ?? _readMap(data['location']),
      ),
      destination: ServiceBookingTrackingDestinationModel.fromJsonOrNull(
        _readMap(data['destination']),
      ),
      channel: _readString(data['channel']),
      event: _readString(data['event']),
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static DateTime? _readDateTime(dynamic value) {
    final text = _readString(value);
    if (text == null) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}

class ServiceBookingTrackingPartnerModel
    extends ServiceBookingTrackingPartnerEntity {
  const ServiceBookingTrackingPartnerModel({
    required super.id,
    required super.name,
    required super.phone,
  });

  static ServiceBookingTrackingPartnerModel? fromJsonOrNull(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return null;
    }

    return ServiceBookingTrackingPartnerModel(
      id: ServiceBookingTrackingModel._readInt(json['id']),
      name: ServiceBookingTrackingModel._readString(json['name']),
      phone: ServiceBookingTrackingModel._readString(json['phone']),
    );
  }
}

class ServiceBookingTrackingLocationModel
    extends ServiceBookingTrackingLocationEntity {
  const ServiceBookingTrackingLocationModel({
    required super.latitude,
    required super.longitude,
    required super.accuracyMeters,
    required super.heading,
    required super.speedMps,
    required super.updatedAt,
  });

  static ServiceBookingTrackingLocationModel? fromJsonOrNull(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return null;
    }

    return ServiceBookingTrackingLocationModel(
      latitude: ServiceBookingTrackingModel._readDouble(json['latitude']),
      longitude: ServiceBookingTrackingModel._readDouble(json['longitude']),
      accuracyMeters: ServiceBookingTrackingModel._readDouble(
        json['accuracy_meters'],
      ),
      heading: ServiceBookingTrackingModel._readDouble(json['heading']),
      speedMps: ServiceBookingTrackingModel._readDouble(json['speed_mps']),
      updatedAt: ServiceBookingTrackingModel._readDateTime(json['updated_at']),
    );
  }
}

class ServiceBookingTrackingDestinationModel
    extends ServiceBookingTrackingDestinationEntity {
  const ServiceBookingTrackingDestinationModel({
    required super.id,
    required super.label,
    required super.address,
    required super.latitude,
    required super.longitude,
  });

  static ServiceBookingTrackingDestinationModel? fromJsonOrNull(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return null;
    }

    return ServiceBookingTrackingDestinationModel(
      id: ServiceBookingTrackingModel._readInt(json['id']),
      label: ServiceBookingTrackingModel._readString(json['label']),
      address: ServiceBookingTrackingModel._readString(json['address']),
      latitude: ServiceBookingTrackingModel._readDouble(json['latitude']),
      longitude: ServiceBookingTrackingModel._readDouble(json['longitude']),
    );
  }
}
