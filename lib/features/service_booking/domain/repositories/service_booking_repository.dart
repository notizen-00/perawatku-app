import '../entities/service_booking_entity.dart';
import '../entities/service_booking_service_entity.dart';
import '../entities/service_booking_tracking_entity.dart';

abstract class ServiceBookingRepository {
  Future<List<ServiceBookingServiceEntity>> getServices({
    int? categoryId,
    String? category,
    String? search,
    int? perPage,
  });

  Future<ServiceBookingEntity> createBooking({
    required int serviceId,
    int? patientMemberId,
    int? patientAddressId,
    String? scheduledAt,
    String? visitPlan,
    String? recurrence,
    int? visitCount,
    String? careMode,
    String? locationType,
    String? notes,
    String? promoCode,
  });

  Future<Map<String, dynamic>> checkPromoCode({
    required String code,
    required int serviceId,
  });

  Future<ServiceBookingEntity> getBooking(int bookingId);

  Future<ServiceBookingTrackingEntity> getTracking(int bookingId);

  Future<ServiceBookingEntity> payBooking(int bookingId, {String? notes});

  Future<ServiceBookingEntity> rematchBooking(int bookingId, {String? notes});

  Future<ServiceBookingEntity> confirmCompletion(
    int bookingId, {
    String? notes,
  });

  Future<ServiceBookingEntity> cancelBooking(int bookingId, {String? reason});
}
