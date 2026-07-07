import '../entities/service_booking_entity.dart';
import '../repositories/service_booking_repository.dart';

class CreateServiceBookingUseCase {
  CreateServiceBookingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingEntity> call({
    required int serviceId,
    required int patientAddressId,
    String? scheduledAt,
    String? notes,
    String? promoCode,
  }) {
    return _repository.createBooking(
      serviceId: serviceId,
      patientAddressId: patientAddressId,
      scheduledAt: scheduledAt,
      notes: notes,
      promoCode: promoCode,
    );
  }
}
