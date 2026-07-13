import '../entities/service_booking_entity.dart';
import '../repositories/service_booking_repository.dart';

class CreateServiceBookingUseCase {
  CreateServiceBookingUseCase(this._repository);

  final ServiceBookingRepository _repository;

  Future<ServiceBookingEntity> call({
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
    return _repository.createBooking(
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
}
