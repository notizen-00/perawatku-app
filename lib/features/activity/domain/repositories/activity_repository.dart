import '../entities/activity_record_entity.dart';

abstract class ActivityRepository {
  Future<List<ActivityRecordEntity>> getConsultationActivities();

  Future<List<ActivityRecordEntity>> getMedicinePurchaseActivities();

  Future<List<ActivityRecordEntity>> getOtherActivities();
}
