import 'dart:convert';

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
    required super.subtotal,
    required super.discountAmount,
    required super.transportFee,
    required super.mealFee,
    required super.extraFeeTotal,
    required super.extraFeeApplied,
    required super.feeMessages,
    required super.visitPlan,
    required super.recurrence,
    required super.visitCount,
    required super.careMode,
    required super.locationType,
    required super.distanceKm,
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
    final pricing =
        _readMap(booking['pricing']) ??
        _readMap(data?['pricing']) ??
        _readMap(root['pricing']) ??
        <String, dynamic>{};
    final feePolicySnapshot =
        _readMap(booking['fee_policy_snapshot']) ??
        _readMap(booking['service_booking_fee_snapshot']) ??
        _readMap(booking['service_booking_fee']) ??
        _readMap(data?['fee_policy_snapshot']) ??
        _readMap(data?['service_booking_fee_snapshot']) ??
        _readMap(data?['service_booking_fee']) ??
        _readMap(pricing['fee_policy_snapshot']) ??
        _readMap(pricing['service_booking_fee_snapshot']) ??
        _readMap(pricing['service_booking_fee']) ??
        _readMap(root['fee_policy_snapshot']) ??
        _readMap(root['service_booking_fee_snapshot']) ??
        _readMap(root['service_booking_fee']) ??
        (pricing.isEmpty ? null : pricing) ??
        <String, dynamic>{};
    final extraFees =
        _readMap(pricing['extra_fees']) ??
        _readMap(booking['extra_fees']) ??
        _readMap(data?['extra_fees']) ??
        _readMap(root['extra_fees']) ??
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
    final visitPlan = _readString(booking['visit_plan'] ?? data?['visit_plan']);
    final recurrence = _readString(booking['recurrence'] ?? data?['recurrence']);
    final visitCount = _readInt(
      booking['visit_count'] ?? pricing['visit_count'] ?? data?['visit_count'],
    );
    final careMode = _readString(booking['care_mode'] ?? data?['care_mode']);
    final distanceKm = _readDouble(
      booking['distance_km'] ??
          data?['distance_km'] ??
          pricing['distance_km'] ??
          matchmakingJson?['distance_km'],
    );
    final transportFee = _resolveTransportFee(
      explicitTransportFee:
          booking['transport_fee'] ?? pricing['transport_fee'],
      extraFees: extraFees,
      feePolicySnapshot: feePolicySnapshot,
      distanceKm: distanceKm,
      visitCount: visitCount,
      careMode: careMode,
    );
    final extraTransportFee = _readExtraTransportFee(extraFees);
    final feeMessages = _resolveFeeMessages(
      explicitMessages: pricing['fee_messages'] ??
          booking['fee_messages'] ??
          data?['fee_messages'],
      extraFees: extraFees,
    );

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
            pricing['total_amount'] ??
            booking['grand_total'] ??
            booking['amount'] ??
            payment['amount'],
      ),
      subtotal: _readString(booking['subtotal'] ?? pricing['subtotal']),
      discountAmount: _readString(
        booking['discount_amount'] ?? pricing['discount_amount'],
      ),
      transportFee: transportFee,
      mealFee: _readString(booking['meal_fee'] ?? pricing['meal_fee']),
      extraFeeTotal: _readString(
        pricing['extra_fee_total'] ??
            booking['extra_fee_total'] ??
            data?['extra_fee_total'] ??
            extraTransportFee,
      ),
      extraFeeApplied: _readBool(
        pricing['extra_fee_applied'] ??
            booking['extra_fee_applied'] ??
            data?['extra_fee_applied'],
      ) ||
          (extraTransportFee != null && extraTransportFee > 0),
      feeMessages: feeMessages,
      visitPlan: visitPlan,
      recurrence: recurrence,
      visitCount: visitCount,
      careMode: careMode,
      locationType: _readString(
        booking['location_type'] ?? data?['location_type'],
      ),
      distanceKm: distanceKm,
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
      acceptedAt: _readString(
        booking['accepted_at'] ??
            booking['acceptedAt'] ??
            booking['partner_accepted_at'] ??
            data?['accepted_at'] ??
            data?['acceptedAt'] ??
            data?['partner_accepted_at'],
      ),
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

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
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

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim())
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = _readString(value);
    if (text == null) {
      return const <String>[];
    }
    return <String>[text];
  }

  static List<String> _resolveFeeMessages({
    required dynamic explicitMessages,
    required Map<String, dynamic> extraFees,
  }) {
    final messages = _readStringList(explicitMessages).toList();
    final transport = _readMap(extraFees['transport']);
    final transportMessage = _readString(transport?['message']);
    if (transportMessage != null && !messages.contains(transportMessage)) {
      messages.add(transportMessage);
    }

    final meal = _readMap(extraFees['meal']);
    final mealMessage = _readString(meal?['message']);
    if (mealMessage != null && !messages.contains(mealMessage)) {
      messages.add(mealMessage);
    }
    return messages;
  }

  static String? _resolveTransportFee({
    required dynamic explicitTransportFee,
    required Map<String, dynamic> extraFees,
    required Map<String, dynamic> feePolicySnapshot,
    required double? distanceKm,
    required int? visitCount,
    required String? careMode,
  }) {
    final explicit = _readDouble(explicitTransportFee);
    final extraTransport = _readExtraTransportFee(extraFees);
    if ((explicit == null || explicit <= 0) &&
        extraTransport != null &&
        extraTransport > 0) {
      return extraTransport.toStringAsFixed(2);
    }

    final computed = _computeTransportFeeFromPolicy(
      feePolicySnapshot: feePolicySnapshot,
      distanceKm: distanceKm,
      visitCount: visitCount,
      careMode: careMode,
    );

    if ((explicit == null || explicit <= 0) &&
        computed != null &&
        computed > 0) {
      return computed.toStringAsFixed(2);
    }

    return _readString(explicitTransportFee);
  }

  static double? _readExtraTransportFee(Map<String, dynamic> extraFees) {
    final transport = _readMap(extraFees['transport']);
    if (transport == null) {
      return null;
    }

    final applied = _readBool(transport['applied']);
    final amount = _readDouble(transport['amount']);
    if (applied && amount != null && amount > 0) {
      return amount;
    }
    return null;
  }

  static double? _computeTransportFeeFromPolicy({
    required Map<String, dynamic> feePolicySnapshot,
    required double? distanceKm,
    required int? visitCount,
    required String? careMode,
  }) {
    if (feePolicySnapshot.isEmpty || distanceKm == null) {
      return null;
    }

    final normalizedCareMode = careMode?.toLowerCase().trim();
    if (normalizedCareMode == 'live_in') {
      return null;
    }

    final transportPolicy = _readMap(feePolicySnapshot['transport']) ??
        _readMap(feePolicySnapshot['transport_fee']) ??
        _readMap(feePolicySnapshot['service_booking_fee']) ??
        _readMap(feePolicySnapshot['fees']) ??
        feePolicySnapshot;
    final thresholdKm = _readFirstDouble(transportPolicy, const [
      'transport_distance_threshold_km',
      'transport_free_distance_km',
      'transport_threshold_km',
      'distance_threshold_km',
      'max_distance_without_transport_km',
      'free_distance_km',
      'threshold_km',
      'max_distance_km',
      'transport_min_distance_km',
      'minimum_transport_distance_km',
      'min_distance_km',
    ]);
    final feePerVisit = _readFirstDouble(transportPolicy, const [
      'transport_fee_per_visit',
      'transport_fee_amount',
      'transport_fee_after_threshold',
      'additional_transport_fee',
      'additional_fee',
      'transport_amount',
      'fee_per_visit',
      'fee',
      'amount',
      'price',
    ]);

    if (thresholdKm == null ||
        feePerVisit == null ||
        distanceKm <= thresholdKm) {
      return null;
    }

    return feePerVisit * (visitCount ?? 1);
  }

  static double? _readFirstDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readDouble(json[key]);
      if (value != null) {
        return value;
      }
    }
    return null;
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
