import '../../domain/entities/patient_member_entity.dart';
import '../../domain/entities/patient_member_payload.dart';
import '../../domain/repositories/patient_member_repository.dart';
import '../datasources/patient_member_remote_data_source.dart';

class PatientMemberRepositoryImpl implements PatientMemberRepository {
  PatientMemberRepositoryImpl({
    required PatientMemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PatientMemberRemoteDataSource _remoteDataSource;

  @override
  Future<List<PatientMemberEntity>> getMembers({
    String? relationship,
    String? search,
    int? perPage,
  }) {
    return _remoteDataSource.getMembers(
      relationship: relationship,
      search: search,
      perPage: perPage,
    );
  }

  @override
  Future<PatientMemberEntity> getMember(int memberId) {
    return _remoteDataSource.getMember(memberId);
  }

  @override
  Future<PatientMemberEntity> createMember(PatientMemberPayload payload) {
    return _remoteDataSource.createMember(payload);
  }

  @override
  Future<PatientMemberEntity> updateMember(
    int memberId,
    PatientMemberPayload payload,
  ) {
    return _remoteDataSource.updateMember(memberId, payload);
  }

  @override
  Future<PatientMemberEntity> setPrimary(int memberId) {
    return _remoteDataSource.setPrimary(memberId);
  }

  @override
  Future<void> deleteMember(int memberId) {
    return _remoteDataSource.deleteMember(memberId);
  }
}
