import '../../domain/entities/service_booking_entity.dart';
import '../../domain/entities/service_booking_service_entity.dart';
import '../../domain/repositories/service_booking_repository.dart';
import '../datasources/service_booking_remote_data_source.dart';

class ServiceBookingRepositoryImpl implements ServiceBookingRepository {
  ServiceBookingRepositoryImpl({
    required ServiceBookingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ServiceBookingRemoteDataSource _remoteDataSource;

  @override
  Future<List<ServiceBookingServiceEntity>> getServices({
    int? categoryId,
    String? category,
    String? search,
    int? perPage,
  }) {
    return _remoteDataSource.getServices(
      categoryId: categoryId,
      category: category,
      search: search,
      perPage: perPage,
    );
  }

  @override
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
  }) {
    return _remoteDataSource.createBooking(
      serviceId: serviceId,
      patientMemberId: patientMemberId,
      patientAddressId: patientAddressId,
      scheduledAt: scheduledAt,
      visitPlan: visitPlan,
      recurrence: recurrence,
      visitCount: visitCount,
      careMode: careMode,
      locationType: locationType,
      notes: notes,
      promoCode: promoCode,
    );
  }

  @override
  Future<ServiceBookingEntity> getBooking(int bookingId) {
    return _remoteDataSource.getBooking(bookingId);
  }

  @override
  Future<ServiceBookingEntity> payBooking(int bookingId, {String? notes}) {
    return _remoteDataSource.payBooking(bookingId, notes: notes);
  }

  @override
  Future<ServiceBookingEntity> confirmCompletion(
    int bookingId, {
    String? notes,
  }) {
    return _remoteDataSource.confirmCompletion(bookingId, notes: notes);
  }

  @override
  Future<ServiceBookingEntity> cancelBooking(int bookingId, {String? reason}) {
    return _remoteDataSource.cancelBooking(bookingId, reason: reason);
  }

  @override
  Future<Map<String, dynamic>> checkPromoCode({
    required String code,
    required int serviceId,
  }) {
    return _remoteDataSource.checkPromoCode(code: code, serviceId: serviceId);
  }
}
