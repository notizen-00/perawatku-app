import '../entities/patient_member_entity.dart';
import '../entities/patient_member_payload.dart';

abstract class PatientMemberRepository {
  Future<List<PatientMemberEntity>> getMembers({
    String? relationship,
    String? search,
    int? perPage,
  });

  Future<PatientMemberEntity> getMember(int memberId);

  Future<PatientMemberEntity> createMember(PatientMemberPayload payload);

  Future<PatientMemberEntity> updateMember(
    int memberId,
    PatientMemberPayload payload,
  );

  Future<PatientMemberEntity> setPrimary(int memberId);

  Future<void> deleteMember(int memberId);
}
