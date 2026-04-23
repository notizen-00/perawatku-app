import 'auth_user_entity.dart';

class LoginResultEntity {
  const LoginResultEntity({
    required this.message,
    required this.user,
    required this.token,
  });

  final String message;
  final AuthUserEntity user;
  final String token;
}
