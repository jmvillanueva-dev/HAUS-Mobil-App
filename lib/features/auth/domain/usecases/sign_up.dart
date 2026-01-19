import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignUp implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      role: params.role,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String role;

  SignUpParams({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    required this.role,
  });

  /// Nombre completo para compatibilidad
  String? get displayName {
    if (firstName != null || lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return null;
  }
}
