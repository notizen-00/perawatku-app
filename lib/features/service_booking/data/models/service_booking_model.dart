import '../../domain/entities/service_booking_entity.dart';

class ServiceBookingModel extends ServiceBookingEntity {
  const ServiceBookingModel({
    required super.id,
    required super.bookingCode,
    required super.serviceId,
    required super.assignedPartnerUserId,
    required super.patientMemberId,
    required super.patientAddressId,
    required super.serviceName,
    required super.patientMemberName,
    required super.partnerName,
    required super.scheduledAt,
    required super.notes,
    required super.status,
    required super.totalAmount,
    required super.paymentStatus,
    required super.snapToken,
    required super.paymentReference,
    required super.matchmaking,
    required super.patientLatitude,
    required super.patientLongitude,
    required super.partnerLatitude,
    required super.partnerLongitude,
    required super.partnerLastUpdate,
    required super.acceptedAt,
    required super.startedAt,
    required super.completedAt,
    required super.partnerBalanceTransactionId,
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
    final service =
        _readMap(booking['service']) ??
        _readMap(data?['service']) ??
        _readMap(root['service']) ??
        <String, dynamic>{};
    final patientMember =
        _readMap(booking['patient_member']) ??
        _readMap(data?['patient_member']) ??
        _readMap(root['patient_member']) ??
        <String, dynamic>{};
    final address =
        _readMap(booking['address']) ??
        _readMap(booking['patient_address']) ??
        _readMap(data?['address']) ??
        _readMap(data?['patient_address']) ??
        _readMap(root['address']) ??
        _readMap(root['patient_address']) ??
        <String, dynamic>{};
    final partner =
        _readMap(booking['assigned_partner']) ??
        _readMap(booking['partner']) ??
        _readMap(data?['assigned_partner']) ??
        _readMap(data?['partner']) ??
        _readMap(root['assigned_partner']) ??
        _readMap(root['partner']) ??
        <String, dynamic>{};
    final partnerProfile =
        _readMap(partner['partner_profile']) ??
        _readMap(partner['profile']) ??
        _readMap(booking['assigned_partner_profile']) ??
        _readMap(data?['assigned_partner_profile']) ??
        _readMap(root['assigned_partner_profile']) ??
        <String, dynamic>{};

    return ServiceBookingModel(
      id: _readInt(booking['id']) ?? 0,
      bookingCode:
          _readString(booking['booking_code'] ?? booking['code']) ??
          'Booking #${booking['id'] ?? '-'}',
      serviceId: _readInt(booking['service_id']),
      assignedPartnerUserId: _readInt(
        booking['assigned_partner_user_id'] ?? booking['partner_user_id'],
      ),
      patientMemberId: _readInt(booking['patient_member_id']),
      patientAddressId: _readInt(booking['patient_address_id']),
      serviceName: _readString(
        service['name'] ?? booking['service_name'] ?? data?['service_name'],
      ),
      patientMemberName: _readString(
        patientMember['name'] ??
            booking['patient_member_name'] ??
            data?['patient_member_name'],
      ),
      partnerName: _readString(
        partner['name'] ?? booking['partner_name'] ?? data?['partner_name'],
      ),
      scheduledAt: _readString(
        booking['scheduled_at'] ??
            booking['schedule_start_at'] ??
            data?['scheduled_at'],
      ),
      notes: _readString(booking['notes'] ?? data?['notes']),
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
      patientLatitude: _readDouble(
        address['latitude'] ??
            patientMember['latitude'] ??
            booking['patient_latitude'] ??
            data?['patient_latitude'],
      ),
      patientLongitude: _readDouble(
        address['longitude'] ??
            patientMember['longitude'] ??
            booking['patient_longitude'] ??
            data?['patient_longitude'],
      ),
      partnerLatitude: _readDouble(
        partner['latitude'] ??
            partnerProfile['latitude'] ??
            booking['partner_latitude'] ??
            data?['partner_latitude'],
      ),
      partnerLongitude: _readDouble(
        partner['longitude'] ??
            partnerProfile['longitude'] ??
            booking['partner_longitude'] ??
            data?['partner_longitude'],
      ),
      partnerLastUpdate: _readDateTime(
        partner['last_update'] ??
            partner['location_updated_at'] ??
            partnerProfile['last_update'] ??
            partnerProfile['updated_at'] ??
            booking['partner_location_updated_at'] ??
            data?['partner_location_updated_at'],
      ),
      acceptedAt: _readString(booking['accepted_at'] ?? data?['accepted_at']),
      startedAt: _readString(booking['started_at'] ?? data?['started_at']),
      completedAt: _readString(
        booking['completed_at'] ?? data?['completed_at'],
      ),
      partnerBalanceTransactionId: _readInt(
        booking['partner_balance_transaction_id'] ??
            payment['partner_balance_transaction_id'] ??
            data?['partner_balance_transaction_id'],
      ),
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

  static DateTime? _readDateTime(dynamic value) {
    final text = _readString(value);
    if (text == null) {
      return null;
    }

    return DateTime.tryParse(text);
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
