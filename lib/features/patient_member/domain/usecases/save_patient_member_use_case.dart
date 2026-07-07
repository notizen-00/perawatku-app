import '../entities/patient_member_entity.dart';
import '../entities/patient_member_payload.dart';
import '../repositories/patient_member_repository.dart';

class SavePatientMemberUseCase {
  const SavePatientMemberUseCase(this._repository);

  final PatientMemberRepository _repository;

  Future<PatientMemberEntity> call({
    int? memberId,
    required PatientMemberPayload payload,
  }) {
    if (memberId == null || memberId == 0) {
      return _repository.createMember(payload);
    }

    return _repository.updateMember(memberId, payload);
  }
}
