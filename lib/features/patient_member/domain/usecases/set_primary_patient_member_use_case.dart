import '../entities/patient_member_entity.dart';
import '../repositories/patient_member_repository.dart';

class SetPrimaryPatientMemberUseCase {
  const SetPrimaryPatientMemberUseCase(this._repository);

  final PatientMemberRepository _repository;

  Future<PatientMemberEntity> call(int memberId) {
    return _repository.setPrimary(memberId);
  }
}
