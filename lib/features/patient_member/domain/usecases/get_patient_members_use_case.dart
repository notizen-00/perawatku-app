import '../entities/patient_member_entity.dart';
import '../repositories/patient_member_repository.dart';

class GetPatientMembersUseCase {
  const GetPatientMembersUseCase(this._repository);

  final PatientMemberRepository _repository;

  Future<List<PatientMemberEntity>> call({
    String? relationship,
    String? search,
    int? perPage,
  }) {
    return _repository.getMembers(
      relationship: relationship,
      search: search,
      perPage: perPage,
    );
  }
}
