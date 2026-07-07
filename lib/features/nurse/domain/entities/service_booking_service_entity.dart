class ServiceBookingServiceEntity {
  const ServiceBookingServiceEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.serviceType,
    required this.description,
    required this.price,
    required this.estimatedDuration,
  });

  final int id;
  final String name;
  final String? category;
  final String? serviceType;
  final String? description;
  final String? price;
  final String? estimatedDuration;
}
