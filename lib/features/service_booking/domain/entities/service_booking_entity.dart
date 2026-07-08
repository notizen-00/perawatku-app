class ServiceBookingEntity {
  const ServiceBookingEntity({
    required this.id,
    required this.bookingCode,
    required this.serviceId,
    required this.assignedPartnerUserId,
    required this.patientMemberId,
    required this.patientAddressId,
    required this.serviceName,
    required this.patientMemberName,
    required this.partnerName,
    required this.scheduledAt,
    required this.notes,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.snapToken,
    required this.paymentReference,
    required this.matchmaking,
  });

  final int id;
  final String bookingCode;
  final int? serviceId;
  final int? assignedPartnerUserId;
  final int? patientMemberId;
  final int? patientAddressId;
  final String? serviceName;
  final String? patientMemberName;
  final String? partnerName;
  final String? scheduledAt;
  final String? notes;
  final String status;
  final String? totalAmount;
  final String? paymentStatus;
  final String? snapToken;
  final String? paymentReference;
  final ServiceBookingMatchmakingEntity? matchmaking;

  bool get isPaid {
    final normalized = paymentStatus?.toLowerCase().trim() ?? '';
    return normalized == 'paid' ||
        normalized == 'success' ||
        normalized == 'settlement' ||
        normalized == 'capture' ||
        normalized == 'completed';
  }

  bool get canContinueAfterPayment {
    final normalizedStatus = status.toLowerCase().trim();
    return isPaid ||
        normalizedStatus == 'confirmed' ||
        normalizedStatus == 'scheduled' ||
        normalizedStatus == 'on_the_way' ||
        normalizedStatus == 'completed';
  }
}

class ServiceBookingMatchmakingEntity {
  const ServiceBookingMatchmakingEntity({
    required this.partnerServiceId,
    required this.partnerUserId,
    required this.distanceKm,
    required this.matchScore,
    required this.qualityScore,
  });

  final int? partnerServiceId;
  final int? partnerUserId;
  final double? distanceKm;
  final double? matchScore;
  final double? qualityScore;
}
