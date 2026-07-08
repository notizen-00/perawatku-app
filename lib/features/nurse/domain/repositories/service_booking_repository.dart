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
    int? patientMemberId,
    int? patientAddressId,
    String? scheduledAt,
    String? notes,
    String? promoCode,
  });

  Future<Map<String, dynamic>> checkPromoCode({
    required String code,
    required int serviceId,
  });

  Future<ServiceBookingEntity> getBooking(int bookingId);

  Future<ServiceBookingEntity> payBooking(int bookingId, {String? notes});
}
