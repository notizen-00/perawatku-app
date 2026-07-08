class ActivityRecordEntity {
  const ActivityRecordEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateTime,
    required this.amountLabel,
    required this.reference,
    required this.consultationId,
    required this.partnerUserId,
    required this.doctorName,
    required this.specialization,
    required this.doctorPhotoUrl,
  });

  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String status;
  final DateTime? dateTime;
  final String amountLabel;
  final String reference;
  final int? consultationId;
  final int? partnerUserId;
  final String? doctorName;
  final String? specialization;
  final String? doctorPhotoUrl;

  bool get canOpenConsultation =>
      category == 'consultation' && consultationId != null;

  bool get canOpenServiceBooking =>
      category == 'other' && int.tryParse(id) != null;

  bool get canOpenChat {
    if (!canOpenConsultation) {
      return false;
    }

    final normalized = status.toLowerCase();
    return normalized == 'paid' ||
        normalized == 'settlement' ||
        normalized == 'capture' ||
        normalized == 'success' ||
        normalized == 'confirmed' ||
        normalized == 'completed' ||
        normalized == 'done' ||
        normalized == 'approved' ||
        normalized == 'active' ||
        normalized == 'ongoing' ||
        normalized == 'opened';
  }

  bool get isActiveOrder {
    final normalized = status.toLowerCase();

    if (normalized == 'completed' ||
        normalized == 'delivered' ||
        normalized == 'done' ||
        normalized == 'closed' ||
        normalized == 'cancel' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'deny' ||
        normalized == 'expired' ||
        normalized == 'failed') {
      return false;
    }

    return normalized == 'active' ||
        normalized == 'confirmed' ||
        normalized == 'ongoing' ||
        normalized == 'opened' ||
        normalized == 'pending' ||
        normalized == 'processing' ||
        normalized == 'scheduled' ||
        normalized == 'paid' ||
        normalized == 'settlement' ||
        normalized == 'capture' ||
        normalized == 'success' ||
        normalized == 'approved';
  }
}
