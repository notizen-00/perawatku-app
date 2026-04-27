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
}
