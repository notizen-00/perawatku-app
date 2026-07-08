import '../../domain/entities/service_booking_service_entity.dart';

class ServiceBookingServiceModel extends ServiceBookingServiceEntity {
  const ServiceBookingServiceModel({
    required super.id,
    required super.bookingServiceId,
    required super.name,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.category,
    required super.serviceType,
    required super.serviceMode,
    required super.description,
    required super.price,
    required super.estimatedDuration,
    required super.requiresAddress,
    required super.requiresSchedule,
    required super.requiresMatchmaking,
  });

  factory ServiceBookingServiceModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : <String, dynamic>{};
    final serviceCategory = (json['service_category'] ??
            service['service_category']) is Map<String, dynamic>
        ? (json['service_category'] ?? service['service_category'])
            as Map<String, dynamic>
        : <String, dynamic>{};
    final nestedServiceId = _readInt(service['id']);
    final explicitServiceId = _readInt(
      json['service_id'] ??
          json['serviceId'] ??
          json['serviceID'] ??
          json['service']?['id'],
    );
    final rowId = _readInt(json['id']) ?? 0;
    final bookingServiceId = explicitServiceId ?? nestedServiceId ?? rowId;

    return ServiceBookingServiceModel(
      id: rowId,
      bookingServiceId: bookingServiceId,
      name: _readString(
            service['name'] ??
                json['service_name'] ??
                json['serviceName'] ??
                json['name'] ??
                json['title'] ??
                json['label'],
          ) ??
          'Layanan medis',
      categoryId: _readInt(
        json['service_category_id'] ??
            service['service_category_id'] ??
            serviceCategory['id'],
      ),
      categoryName: _readString(
        serviceCategory['name'] ??
            service['category'] ??
            json['category'] ??
            json['service_category_name'],
      ),
      categoryIcon: _readString(serviceCategory['icon'] ?? json['category_icon']),
      category: _readString(
        service['category'] ?? json['category'] ?? json['service_category'],
      ),
      serviceType: _readString(
        service['service_type'] ?? json['service_type'] ?? json['type'],
      ),
      serviceMode: _readString(service['service_mode'] ?? json['service_mode']),
      description: _readString(service['description'] ?? json['description']),
      price: _readString(
        service['base_price'] ??
            json['base_price'] ??
            json['price'] ??
            json['fee'] ??
            json['amount'],
      ),
      estimatedDuration: _readString(
        service['duration_minutes'] ??
            json['duration_minutes'] ??
            json['estimated_duration'] ??
            json['duration'],
      ),
      requiresAddress: _readBool(
        service['requires_address'] ?? json['requires_address'],
      ),
      requiresSchedule: _readBool(
        service['requires_schedule'] ?? json['requires_schedule'],
      ),
      requiresMatchmaking: _readBool(
        service['requires_matchmaking'] ?? json['requires_matchmaking'],
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

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
