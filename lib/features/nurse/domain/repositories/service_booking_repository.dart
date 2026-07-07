import '../entities/service_booking_entity.dart';
import '../entities/service_booking_service_entity.dart';

abstract class ServiceBookingRepository {
  Future<List<ServiceBookingServiceEntity>> getServices({
    String? category,
    String? search,
    int? perPage,
  });

  Future<ServiceBookingEntity> createBooking({
    required int serviceId,
    required int patientAddressId,
    String? scheduledAt,
    String? notes,
    String? promoCode,
  });

  Future<ServiceBookingEntity> getBooking(int bookingId);
}
