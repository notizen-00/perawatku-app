import '../entities/activity_record_entity.dart';
import '../repositories/activity_repository.dart';

class GetConsultationActivitiesUseCase {
  GetConsultationActivitiesUseCase(this._repository);

  final ActivityRepository _repository;

  Future<List<ActivityRecordEntity>> call() {
    return _repository.getConsultationActivities();
  }
}
