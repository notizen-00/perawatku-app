class ServiceBookingServiceEntity {
  const ServiceBookingServiceEntity({
    required this.id,
    required this.bookingServiceId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.category,
    required this.serviceType,
    required this.serviceMode,
    required this.description,
    required this.image,
    required this.price,
    required this.estimatedDuration,
    required this.requiresAddress,
    required this.requiresSchedule,
    required this.requiresMatchmaking,
  });

  final int id;
  final int bookingServiceId;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? category;
  final String? serviceType;
  final String? serviceMode;
  final String? description;
  final String? image;
  final String? price;
  final String? estimatedDuration;
  final bool requiresAddress;
  final bool requiresSchedule;
  final bool requiresMatchmaking;
}
