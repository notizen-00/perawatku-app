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
    String? category,
    String? search,
    int? perPage,
  }) {
    return _remoteDataSource.getServices(
      category: category,
      search: search,
      perPage: perPage,
    );
  }

  @override
  Future<ServiceBookingEntity> createBooking({
    required int serviceId,
    required int patientAddressId,
    String? scheduledAt,
    String? notes,
    String? promoCode,
  }) {
    return _remoteDataSource.createBooking(
      serviceId: serviceId,
      patientAddressId: patientAddressId,
      scheduledAt: scheduledAt,
      notes: notes,
      promoCode: promoCode,
    );
  }

  @override
  Future<ServiceBookingEntity> getBooking(int bookingId) {
    return _remoteDataSource.getBooking(bookingId);
  }
}
