import '../../domain/entities/consultation_payment_entity.dart';

class ConsultationPaymentModel extends ConsultationPaymentEntity {
  const ConsultationPaymentModel({
    required super.snapToken,
    required super.redirectUrl,
    required super.paymentStatus,
    required super.orderId,
  });

  factory ConsultationPaymentModel.fromJson(Map<String, dynamic> json) {
    final transaction =
        json['transaction'] is Map<String, dynamic>
            ? json['transaction'] as Map<String, dynamic>
            : <String, dynamic>{};

    final payment =
        json['payment'] is Map<String, dynamic>
            ? json['payment'] as Map<String, dynamic>
            : <String, dynamic>{};

    return ConsultationPaymentModel(
      snapToken: _readRequiredString(
        json['snap_token'] ??
            json['token'] ??
            json['payment_token'] ??
            transaction['snap_token'] ??
            payment['snap_token'],
      ),
      redirectUrl: _readString(
        json['redirect_url'] ??
            json['payment_url'] ??
            transaction['redirect_url'] ??
            payment['redirect_url'],
      ),
      paymentStatus:
          _readString(
            json['payment_status'] ??
                json['transaction_status'] ??
                transaction['payment_status'] ??
                payment['payment_status'],
          ) ??
          '',
      orderId: _readString(
        json['order_id'] ??
            json['midtrans_order_id'] ??
            transaction['order_id'] ??
            payment['order_id'],
      ),
    );
  }

  static String _readRequiredString(dynamic value) {
    final result = _readString(value);
    if (result == null) {
      throw const FormatException('Snap token tidak ditemukan pada response.');
    }

    return result;
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
