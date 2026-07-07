import '../../domain/entities/service_booking_service_entity.dart';

class ServiceBookingServiceModel extends ServiceBookingServiceEntity {
  const ServiceBookingServiceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.serviceType,
    required super.description,
    required super.price,
    required super.estimatedDuration,
  });

  factory ServiceBookingServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingServiceModel(
      id: _readInt(json['id']) ?? 0,
      name: _readString(json['name'] ?? json['title']) ?? 'Layanan medis',
      category: _readString(json['category'] ?? json['service_category']),
      serviceType: _readString(json['service_type'] ?? json['type']),
      description: _readString(json['description']),
      price: _readString(
        json['price'] ?? json['fee'] ?? json['base_price'] ?? json['amount'],
      ),
      estimatedDuration: _readString(
        json['estimated_duration'] ?? json['duration'],
      ),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _readString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}
