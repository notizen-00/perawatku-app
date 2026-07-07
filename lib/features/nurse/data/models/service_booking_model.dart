import '../../domain/entities/service_booking_entity.dart';

class ServiceBookingModel extends ServiceBookingEntity {
  const ServiceBookingModel({
    required super.id,
    required super.bookingCode,
    required super.serviceId,
    required super.assignedPartnerUserId,
    required super.patientAddressId,
    required super.status,
    required super.totalAmount,
    required super.paymentStatus,
    required super.snapToken,
    required super.paymentReference,
    required super.matchmaking,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    final root = Map<String, dynamic>.from(json);
    final data = _readMap(root['data']);
    final booking =
        _readMap(data?['service_booking']) ??
        _readMap(root['service_booking']) ??
        _readMap(data?['booking']) ??
        _readMap(root['booking']) ??
        _readMap(data?['serviceBooking']) ??
        (data != null && _looksLikeBooking(data) ? data : root);
    final payment =
        _readMap(booking['payment']) ??
        _readMap(data?['payment']) ??
        _readMap(root['payment']) ??
        <String, dynamic>{};
    final transaction =
        _readMap(booking['transaction']) ??
        _readMap(data?['transaction']) ??
        _readMap(root['transaction']) ??
        <String, dynamic>{};
    final midtrans =
        _readMap(data?['midtrans']) ??
        _readMap(root['midtrans']) ??
        _readMap(payment['midtrans']) ??
        <String, dynamic>{};
    final matchmakingJson =
        _readMap(root['matchmaking']) ??
        _readMap(data?['matchmaking']) ??
        _readMap(booking['matchmaking']);

    return ServiceBookingModel(
      id: _readInt(booking['id']) ?? 0,
      bookingCode:
          _readString(booking['booking_code'] ?? booking['code']) ??
          'Booking #${booking['id'] ?? '-'}',
      serviceId: _readInt(booking['service_id']),
      assignedPartnerUserId: _readInt(
        booking['assigned_partner_user_id'] ?? booking['partner_user_id'],
      ),
      patientAddressId: _readInt(booking['patient_address_id']),
      status: _readString(booking['status']) ?? 'pending',
      totalAmount: _readString(
        booking['total_amount'] ??
            booking['grand_total'] ??
            booking['amount'] ??
            payment['amount'],
      ),
      paymentStatus: _readString(
        booking['payment_status'] ??
            booking['transaction_status'] ??
            payment['status'] ??
            payment['payment_status'] ??
            transaction['status'] ??
            transaction['transaction_status'],
      ),
      snapToken: _readString(
        booking['snap_token'] ??
            booking['payment_token'] ??
            payment['snap_token'] ??
            payment['payment_token'] ??
            transaction['snap_token'] ??
            midtrans['snap_token'] ??
            midtrans['token'],
      ),
      paymentReference: _readString(
        booking['payment_reference'] ??
            booking['payment_code'] ??
            payment['order_id'] ??
            payment['payment_code'] ??
            transaction['order_id'] ??
            midtrans['order_id'],
      ),
      matchmaking: matchmakingJson == null
          ? null
          : ServiceBookingMatchmakingModel.fromJson(matchmakingJson),
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static bool _looksLikeBooking(Map<String, dynamic> json) {
    return json.containsKey('id') ||
        json.containsKey('booking_code') ||
        json.containsKey('service_id');
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
}

class ServiceBookingMatchmakingModel extends ServiceBookingMatchmakingEntity {
  const ServiceBookingMatchmakingModel({
    required super.partnerServiceId,
    required super.partnerUserId,
    required super.distanceKm,
    required super.matchScore,
    required super.qualityScore,
  });

  factory ServiceBookingMatchmakingModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingMatchmakingModel(
      partnerServiceId: ServiceBookingModel._readInt(
        json['partner_service_id'],
      ),
      partnerUserId: ServiceBookingModel._readInt(json['partner_user_id']),
      distanceKm: ServiceBookingModel._readDouble(json['distance_km']),
      matchScore: ServiceBookingModel._readDouble(json['match_score']),
      qualityScore: ServiceBookingModel._readDouble(json['quality_score']),
    );
  }
}
