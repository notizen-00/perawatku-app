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
    required this.subtotal,
    required this.discountAmount,
    required this.transportFee,
    required this.mealFee,
    required this.extraFeeTotal,
    required this.extraFeeApplied,
    required this.feeMessages,
    required this.visitPlan,
    required this.recurrence,
    required this.visitCount,
    required this.careMode,
    required this.locationType,
    required this.distanceKm,
    required this.paymentStatus,
    required this.snapToken,
    required this.paymentReference,
    required this.matchmakingStatus,
    required this.matchmaking,
    required this.patientLatitude,
    required this.patientLongitude,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.partnerLastUpdate,
    required this.acceptedAt,
    required this.startedAt,
    required this.completedAt,
    required this.partnerBalanceTransactionId,
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
  final String? subtotal;
  final String? discountAmount;
  final String? transportFee;
  final String? mealFee;
  final String? extraFeeTotal;
  final bool extraFeeApplied;
  final List<String> feeMessages;
  final String? visitPlan;
  final String? recurrence;
  final int? visitCount;
  final String? careMode;
  final String? locationType;
  final double? distanceKm;
  final String? paymentStatus;
  final String? snapToken;
  final String? paymentReference;
  final String? matchmakingStatus;
  final ServiceBookingMatchmakingEntity? matchmaking;
  final double? patientLatitude;
  final double? patientLongitude;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final DateTime? partnerLastUpdate;
  final String? acceptedAt;
  final String? startedAt;
  final String? completedAt;
  final int? partnerBalanceTransactionId;

  bool get isPaid {
    final normalized = paymentStatus?.toLowerCase().trim() ?? '';
    return normalized == 'paid' ||
        normalized == 'success' ||
        normalized == 'settlement' ||
        normalized == 'capture' ||
        normalized == 'completed';
  }

  bool get isAcceptedByPartner {
    final normalizedStatus = status.toLowerCase().trim();
    final hasAcceptedAt = acceptedAt != null && acceptedAt!.trim().isNotEmpty;
    return hasAcceptedAt ||
        normalizedStatus == 'confirmed' ||
        normalizedStatus == 'scheduled' ||
        normalizedStatus == 'on_the_way' ||
        normalizedStatus == 'completed';
  }

  bool get isWaitingPartnerAcceptance {
    final normalizedStatus = status.toLowerCase().trim();
    final normalizedMatchmakingStatus =
        matchmakingStatus?.toLowerCase().trim() ?? '';
    return !isAcceptedByPartner &&
        normalizedStatus == 'pending' &&
        (assignedPartnerUserId != null ||
            normalizedMatchmakingStatus == 'waiting_partner_acceptance' ||
            normalizedMatchmakingStatus == 'rematched' ||
            normalizedMatchmakingStatus ==
                'rematched_waiting_partner_acceptance');
  }

  bool get isSearchingReplacementPartner {
    final normalizedStatus = status.toLowerCase().trim();
    final normalizedMatchmakingStatus =
        matchmakingStatus?.toLowerCase().trim() ?? '';
    return !isAcceptedByPartner &&
        normalizedStatus == 'pending' &&
        assignedPartnerUserId == null &&
        normalizedMatchmakingStatus != 'waiting_partner_acceptance' &&
        normalizedMatchmakingStatus != 'rematched' &&
        normalizedMatchmakingStatus !=
            'rematched_waiting_partner_acceptance';
  }

  bool get shouldRequestPartnerRematch {
    final normalizedMatchmakingStatus =
        matchmakingStatus?.toLowerCase().trim() ?? '';
    return isSearchingReplacementPartner ||
        normalizedMatchmakingStatus == 'waiting_partner_available';
  }

  bool get canContinueAfterPayment {
    final normalizedStatus = status.toLowerCase().trim();
    return isPaid ||
        normalizedStatus == 'confirmed' ||
        normalizedStatus == 'scheduled' ||
        normalizedStatus == 'on_the_way' ||
        normalizedStatus == 'completed';
  }

  bool get isOnTheWay => status.toLowerCase().trim() == 'on_the_way';

  bool get isCompleted => status.toLowerCase().trim() == 'completed';

  bool get needsPatientCompletionConfirmation {
    return isPaid &&
        isCompleted &&
        assignedPartnerUserId != null &&
        partnerBalanceTransactionId == null;
  }

  bool get canConfirmCompletion {
    final normalizedStatus = status.toLowerCase().trim();
    return isPaid &&
        assignedPartnerUserId != null &&
        (normalizedStatus == 'confirmed' ||
            normalizedStatus == 'scheduled' ||
            normalizedStatus == 'on_the_way' ||
            normalizedStatus == 'completed');
  }

  bool get canCancelBeforePartnerFound {
    final normalizedStatus = status.toLowerCase().trim();
    final hasBeenAccepted = acceptedAt != null && acceptedAt!.trim().isNotEmpty;
    final isRunningOrAcceptedStatus =
        normalizedStatus == 'accepted' ||
        normalizedStatus == 'on_the_way' ||
        normalizedStatus == 'in_progress' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'cancelled';

    return !isPaid &&
        !hasBeenAccepted &&
        !isRunningOrAcceptedStatus &&
        (normalizedStatus == 'pending' ||
            normalizedStatus == 'scheduled' ||
            normalizedStatus == 'confirmed');
  }

  bool get hasTrackingCoordinates {
    return patientLatitude != null &&
        patientLongitude != null &&
        partnerLatitude != null &&
        partnerLongitude != null;
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
