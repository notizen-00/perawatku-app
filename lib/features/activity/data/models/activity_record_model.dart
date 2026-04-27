import '../../domain/entities/activity_record_entity.dart';

class ActivityRecordModel extends ActivityRecordEntity {
  const ActivityRecordModel({
    required super.id,
    required super.category,
    required super.title,
    required super.subtitle,
    required super.status,
    required super.dateTime,
    required super.amountLabel,
    required super.reference,
    required super.consultationId,
    required super.partnerUserId,
    required super.doctorName,
    required super.specialization,
    required super.doctorPhotoUrl,
  });

  factory ActivityRecordModel.fromConsultationJson(Map<String, dynamic> json) {
    final doctor =
        json['doctor'] is Map<String, dynamic>
            ? json['doctor'] as Map<String, dynamic>
            : json['partner'] is Map<String, dynamic>
            ? json['partner'] as Map<String, dynamic>
            : <String, dynamic>{};

    final doctorName =
        doctor['name']?.toString().trim().isNotEmpty == true
            ? doctor['name'].toString().trim()
            : json['doctor_name']?.toString().trim().isNotEmpty == true
            ? json['doctor_name'].toString().trim()
            : 'Dokter';

    final amount =
        json['total_amount'] ??
        json['amount'] ??
        json['gross_amount'] ??
        json['consultation_fee'];
    final consultationCode =
        _readString(
          json['consultation_code'] ?? json['code'] ?? json['reference_code'],
        ) ??
        'Konsultasi #${json['id'] ?? '-'}';
    final specialization =
        doctor['partner_profile'] is Map<String, dynamic>
            ? (doctor['partner_profile']['specialization']?.toString() ?? '')
            : doctor['doctor_profile'] is Map<String, dynamic>
            ? (doctor['doctor_profile']['specialization']?.toString() ?? '')
            : json['specialization']?.toString() ?? '';

    return ActivityRecordModel(
      id: (json['id'] ?? '').toString(),
      category: 'consultation',
      title: consultationCode,
      subtitle:
          specialization.trim().isEmpty
              ? doctorName
              : '$doctorName · ${specialization.trim()}',
      status: _resolveConsultationStatus(json),
      dateTime: _parseDateTime(
        json['created_at'] ?? json['updated_at'] ?? json['consultation_date'],
      ),
      amountLabel: _formatAmount(amount),
      reference:
          json['order_id']?.toString() ??
          json['midtrans_order_id']?.toString() ??
          consultationCode,
      consultationId: _parseInt(json['id']),
      partnerUserId: _parseInt(
        json['partner_user_id'] ??
            json['doctor_user_id'] ??
            doctor['id'] ??
            doctor['user_id'],
      ),
      doctorName: doctorName,
      specialization: specialization.trim().isEmpty ? null : specialization.trim(),
      doctorPhotoUrl: _readString(
        doctor['partner_profile']?['photo_url'] ??
            doctor['doctor_profile']?['photo_url'] ??
            doctor['photo_url'] ??
            json['doctor_photo_url'],
      ),
    );
  }

  factory ActivityRecordModel.fromMap(Map<String, dynamic> json) {
    return ActivityRecordModel(
      id: json['id'].toString(),
      category: json['category']?.toString() ?? 'other',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dateTime: _parseDateTime(json['date_time']),
      amountLabel: json['amount_label']?.toString() ?? '-',
      reference: json['reference']?.toString() ?? '-',
      consultationId: _parseInt(json['consultation_id']),
      partnerUserId: _parseInt(json['partner_user_id']),
      doctorName: json['doctor_name']?.toString(),
      specialization: json['specialization']?.toString(),
      doctorPhotoUrl: json['doctor_photo_url']?.toString(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String _resolveConsultationStatus(Map<String, dynamic> json) {
    final consultationStatus = json['status']?.toString().toLowerCase() ?? '';
    final payment =
        json['payment'] is Map<String, dynamic>
            ? json['payment'] as Map<String, dynamic>
            : <String, dynamic>{};
    final paymentStatus =
        json['payment_status']?.toString().toLowerCase() ??
        json['transaction_status']?.toString().toLowerCase() ??
        payment['status']?.toString().toLowerCase() ??
        '';

    if (consultationStatus == 'active' ||
        consultationStatus == 'confirmed' ||
        consultationStatus == 'ongoing' ||
        consultationStatus == 'opened' ||
        consultationStatus == 'pending' ||
        consultationStatus == 'scheduled' ||
        consultationStatus == 'processing') {
      return consultationStatus;
    }

    if (consultationStatus == 'completed' ||
        consultationStatus == 'done' ||
        consultationStatus == 'closed' ||
        consultationStatus == 'cancelled' ||
        consultationStatus == 'canceled' ||
        consultationStatus == 'failed') {
      return consultationStatus;
    }

    if (paymentStatus.isNotEmpty) {
      return paymentStatus;
    }

    if (consultationStatus.isNotEmpty) {
      return consultationStatus;
    }

    return 'unknown';
  }

  static String _formatAmount(dynamic value) {
    final digits = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (digits.isEmpty) {
      return '-';
    }

    final number = int.tryParse(digits);
    if (number == null) {
      return '-';
    }

    final raw = number.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < raw.length; index++) {
      final reverseIndex = raw.length - index;
      buffer.write(raw[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
