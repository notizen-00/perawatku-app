import '../../domain/entities/activity_record_entity.dart';
import '../../../../core/helpers/currency_formatter.dart';

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
    final doctor = json['doctor'] is Map<String, dynamic>
        ? json['doctor'] as Map<String, dynamic>
        : json['partner'] is Map<String, dynamic>
        ? json['partner'] as Map<String, dynamic>
        : <String, dynamic>{};

    final doctorName = doctor['name']?.toString().trim().isNotEmpty == true
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
    final specialization = doctor['partner_profile'] is Map<String, dynamic>
        ? (doctor['partner_profile']['specialization']?.toString() ?? '')
        : doctor['doctor_profile'] is Map<String, dynamic>
        ? (doctor['doctor_profile']['specialization']?.toString() ?? '')
        : json['specialization']?.toString() ?? '';

    return ActivityRecordModel(
      id: (json['id'] ?? '').toString(),
      category: 'consultation',
      title: consultationCode,
      subtitle: specialization.trim().isEmpty
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
      specialization: specialization.trim().isEmpty
          ? null
          : specialization.trim(),
      doctorPhotoUrl: _readString(
        doctor['partner_profile']?['photo_url'] ??
            doctor['doctor_profile']?['photo_url'] ??
            doctor['photo_url'] ??
            json['doctor_photo_url'],
      ),
    );
  }

  factory ActivityRecordModel.fromOrderJson(Map<String, dynamic> json) {
    final apotik = json['apotik'] is Map<String, dynamic>
        ? json['apotik'] as Map<String, dynamic>
        : json['pharmacy'] is Map<String, dynamic>
        ? json['pharmacy'] as Map<String, dynamic>
        : <String, dynamic>{};
    final code =
        _readString(json['order_code'] ?? json['code'] ?? json['reference']) ??
        'Pesanan #${json['id'] ?? '-'}';
    final apotikName =
        _readString(
          apotik['name'] ?? json['apotik_name'] ?? json['pharmacy_name'],
        ) ??
        'Apotik';

    return ActivityRecordModel(
      id: (json['id'] ?? code).toString(),
      category: 'medicine',
      title: code,
      subtitle: apotikName,
      status: json['status']?.toString() ?? 'unknown',
      dateTime: _parseDateTime(json['created_at'] ?? json['updated_at']),
      amountLabel: _formatAmount(
        json['total_amount'] ?? json['grand_total'] ?? json['amount'],
      ),
      reference:
          _readString(json['order_id'] ?? json['reference'] ?? code) ?? code,
      consultationId: null,
      partnerUserId: _parseInt(
        json['apotik_user_id'] ?? apotik['user_id'] ?? apotik['id'],
      ),
      doctorName: null,
      specialization: null,
      doctorPhotoUrl: null,
    );
  }

  factory ActivityRecordModel.fromServiceBookingJson(
    Map<String, dynamic> json,
  ) {
    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : <String, dynamic>{};
    final partner = json['assigned_partner'] is Map<String, dynamic>
        ? json['assigned_partner'] as Map<String, dynamic>
        : json['partner'] is Map<String, dynamic>
        ? json['partner'] as Map<String, dynamic>
        : <String, dynamic>{};
    final code =
        _readString(
          json['booking_code'] ?? json['code'] ?? json['reference'],
        ) ??
        'Pesanan #${json['id'] ?? '-'}';
    final serviceName =
        _readString(service['name'] ?? json['service_name']) ?? 'Layanan medis';
    final partnerName =
        _readString(partner['name'] ?? json['partner_name']) ?? 'Mitra medis';

    return ActivityRecordModel(
      id: (json['id'] ?? code).toString(),
      category: 'other',
      title: serviceName,
      subtitle: partnerName,
      status: json['status']?.toString() ?? 'unknown',
      dateTime: _parseDateTime(
        json['scheduled_at'] ?? json['created_at'] ?? json['updated_at'],
      ),
      amountLabel: _formatAmount(
        json['total_amount'] ?? json['grand_total'] ?? json['amount'],
      ),
      reference: code,
      consultationId: null,
      partnerUserId: _parseInt(
        json['assigned_partner_user_id'] ??
            json['partner_user_id'] ??
            partner['user_id'] ??
            partner['id'],
      ),
      doctorName: partnerName,
      specialization: serviceName,
      doctorPhotoUrl: _readString(
        partner['photo_url'] ?? json['partner_photo_url'],
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
    final payment = json['payment'] is Map<String, dynamic>
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
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return '-';
    }

    if (value is num) {
      return CurrencyFormatter.formatRupiah(value);
    }

    return CurrencyFormatter.formatRupiahFromString(raw, emptyValue: '-');
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
