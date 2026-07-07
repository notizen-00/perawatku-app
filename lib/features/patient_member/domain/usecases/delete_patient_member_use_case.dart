import '../repositories/patient_member_repository.dart';

class DeletePatientMemberUseCase {
  const DeletePatientMemberUseCase(this._repository);

  final PatientMemberRepository _repository;

  Future<void> call(int memberId) {
    return _repository.deleteMember(memberId);
  }
}
