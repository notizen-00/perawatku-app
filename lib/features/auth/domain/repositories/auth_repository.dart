import '../entities/login_result_entity.dart';

abstract class AuthRepository {
  Future<LoginResultEntity> login({
    required String email,
    required String password,
  });
}
